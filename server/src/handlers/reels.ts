import { z } from 'zod';

import type { Caller } from '../shared/callable';
import { appError, ErrorCodes } from '../shared/errorCodes';
import { consumeRateLimit } from '../shared/rateLimit';
import type { Deps } from './deps';
import { blockedUids } from './discovery';

/** Reels per page of the feed. */
export const REELS_PAGE_SIZE = 15;
/** Longest caption, in characters (the table allows the same). */
export const REEL_CAPTION_MAX = 150;
/** New reels one person may post per day. */
export const REELS_PER_DAY = 10;

const reelIdSchema = z.string().uuid();

/** Verified, active people may watch and post reels. */
async function requireMember(deps: Deps, uid: string): Promise<void> {
  const [user] = await deps.sql<{ account_status: string; verification_status: string }[]>`
    select account_status, verification_status from users where id = ${uid}`;
  if (!user) throw appError(ErrorCodes.notFound, 'Accept the rules first.');
  if (user.account_status !== 'active') throw appError(ErrorCodes.blocked, 'This account is suspended.');
  if (user.verification_status !== 'approved') throw appError(ErrorCodes.notVerified, 'Finish verification first.');
}

/** Where a reel's video lives: reels/<uid>/<reelId>.mp4 */
export const reelVideoPath = (uid: string, reelId: string) => `reels/${uid}/${reelId}.mp4`;

// ---------- reelFeed ----------

export const reelFeedInput = z.object({
  /** Only reels older than this one (the last reel of the previous page). */
  before: reelIdSchema.nullable().optional(),
  /** Only this person's reels (their profile). */
  authorUid: z.string().uuid().nullable().optional(),
});

export interface ReelDto {
  reelId: string;
  authorUid: string;
  authorName: string;
  authorPhotoPath: string | null;
  /** The author offers meetups, so they can be booked from the reel. */
  authorBookable: boolean;
  videoPath: string;
  caption: string;
  createdAt: string;
  isMine: boolean;
}

interface ReelRow {
  id: string;
  uid: string;
  video_path: string;
  caption: string;
  created_at: Date;
  display_name: string | null;
  photo_paths: string[];
  is_listed: boolean | null;
}

/** Newest reels first, from active, verified people the caller has not blocked (or been blocked by). */
export async function reelFeedLogic(
  deps: Deps,
  caller: Caller,
  input: z.infer<typeof reelFeedInput>,
): Promise<{ reels: ReelDto[]; hasMore: boolean }> {
  const { sql } = deps;
  await requireMember(deps, caller.uid);
  const blocked = [...(await blockedUids(sql, caller.uid))];

  let cursor: { created_at: Date; id: string } | undefined;
  if (input.before) {
    [cursor] = await sql<{ created_at: Date; id: string }[]>`select created_at, id from reels where id = ${input.before}`;
    if (!cursor) return { reels: [], hasMore: false };
  }

  const rows = await sql<ReelRow[]>`
    select r.id, r.uid, r.video_path, r.caption, r.created_at, u.display_name, u.photo_paths, c.is_listed
    from reels r
    join users u on u.id = r.uid
    left join companion_profiles c on c.uid = r.uid
    where u.account_status = 'active' and u.verification_status = 'approved'
      ${blocked.length ? sql`and r.uid not in ${sql(blocked)}` : sql``}
      ${input.authorUid ? sql`and r.uid = ${input.authorUid}` : sql``}
      ${cursor ? sql`and (r.created_at, r.id) < (${cursor.created_at}, ${cursor.id})` : sql``}
    order by r.created_at desc, r.id desc
    limit ${REELS_PAGE_SIZE + 1}`;

  const page = rows.slice(0, REELS_PAGE_SIZE);
  return {
    hasMore: rows.length > REELS_PAGE_SIZE,
    reels: page.map((r) => ({
      reelId: r.id,
      authorUid: r.uid,
      authorName: r.display_name?.trim() || 'VYBE member',
      authorPhotoPath: r.photo_paths?.[0] ?? null,
      authorBookable: r.uid !== caller.uid && r.is_listed === true,
      videoPath: r.video_path,
      caption: r.caption,
      createdAt: r.created_at.toISOString(),
      isMine: r.uid === caller.uid,
    })),
  };
}

// ---------- postReel ----------

export const postReelInput = z.object({
  /** Client-generated id; the video was uploaded to reels/<uid>/<reelId>.mp4. */
  reelId: reelIdSchema,
  caption: z.string().optional(),
});

/** Adds a reel once its video is uploaded. Posting the same id again changes nothing. */
export async function postReelLogic(
  deps: Deps,
  caller: Caller,
  input: z.infer<typeof postReelInput>,
): Promise<{ reelId: string }> {
  const { sql } = deps;
  const now = deps.now();
  await requireMember(deps, caller.uid);
  const caption = (input.caption ?? '').trim().replace(/\s+/g, ' ');
  if (caption.length > REEL_CAPTION_MAX) throw appError(ErrorCodes.invalidInput, 'The caption is too long.');

  const [existing] = await sql<{ uid: string }[]>`select uid from reels where id = ${input.reelId}`;
  if (existing) {
    if (existing.uid !== caller.uid) throw appError(ErrorCodes.invalidInput, 'Use a new reel id.');
    return { reelId: input.reelId };
  }

  const path = reelVideoPath(caller.uid, input.reelId);
  const objectName = path.slice('reels/'.length);
  const [file] = await sql`select 1 from storage.objects where bucket_id = 'reels' and name = ${objectName}`;
  if (!file) throw appError(ErrorCodes.invalidInput, 'Upload the video first.');

  await consumeRateLimit(sql, `${caller.uid}_reels`, REELS_PER_DAY, 86_400_000, now);
  await sql`
    insert into reels (id, uid, video_path, caption, created_at)
    values (${input.reelId}, ${caller.uid}, ${path}, ${caption}, ${now})
    on conflict (id) do nothing`;
  return { reelId: input.reelId };
}

// ---------- deleteReel ----------

export const deleteReelInput = z.object({ reelId: reelIdSchema });

/** Removes the caller's own reel. The app deletes the video file. */
export async function deleteReelLogic(
  deps: Deps,
  caller: Caller,
  input: z.infer<typeof deleteReelInput>,
): Promise<{ deleted: true }> {
  const [row] = await deps.sql<{ uid: string }[]>`select uid from reels where id = ${input.reelId}`;
  if (!row || row.uid !== caller.uid) throw appError(ErrorCodes.notFound, 'Reel not found.');
  await deps.sql`delete from reels where id = ${input.reelId}`;
  return { deleted: true };
}
