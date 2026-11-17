import { randomUUID } from 'node:crypto';

import { deleteReelLogic, postReelLogic, REELS_PAGE_SIZE, REELS_PER_DAY, reelFeedLogic, reelVideoPath } from '../../src/handlers/reels';
import { submitReportLogic } from '../../src/handlers/safety';
import { addPerson, asUser, connect, denied, expectAppError, googleCaller, makeDeps, People, reset } from './helpers';

const sql = connect();
let people: People;
const uid = (name: string) => people.uid(name);
const caller = (name: string) => googleCaller(uid(name));
const deps = () => makeDeps(sql);

async function member(name: string, extra: Partial<Parameters<typeof addPerson>[1]> = {}) {
  await addPerson(sql, { uid: uid(name), name, gender: 'woman', ...extra });
}

/** What the app does: upload the file to the author's folder. */
async function upload(name: string, reelId: string) {
  await sql`insert into storage.objects (bucket_id, name) values ('reels', ${`${uid(name)}/${reelId}.mp4`})`;
}

async function post(name: string, caption = 'Sunday walk', at = new Date()) {
  const reelId = randomUUID();
  await upload(name, reelId);
  await postReelLogic(makeDeps(sql, {}, at), caller(name), { reelId, caption });
  return reelId;
}

beforeEach(async () => {
  await reset(sql);
  people = new People();
  await member('neha', { companion: { planTypes: ['coffee'] } });
  await member('aarav', { gender: 'man' });
  await member('kabir', { gender: 'man' });
});

describe('postReel', () => {
  it('adds the reel once the video is uploaded; posting again changes nothing', async () => {
    const reelId = randomUUID();
    await expectAppError(postReelLogic(deps(), caller('neha'), { reelId }), 'invalid_input');
    await upload('neha', reelId);
    await postReelLogic(deps(), caller('neha'), { reelId, caption: '  Morning   coffee ' });
    await postReelLogic(deps(), caller('neha'), { reelId, caption: 'changed' });
    const rows = await sql`select uid, video_path, caption from reels`;
    expect(rows).toEqual([{ uid: uid('neha'), video_path: reelVideoPath(uid('neha'), reelId), caption: 'Morning coffee' }]);
  });

  it("refuses someone else's video, long captions and unverified people", async () => {
    const reelId = randomUUID();
    await upload('neha', reelId);
    await expectAppError(postReelLogic(deps(), caller('aarav'), { reelId }), 'invalid_input');
    await expectAppError(postReelLogic(deps(), caller('neha'), { reelId, caption: 'x'.repeat(151) }), 'invalid_input');
    await member('new', { verified: false });
    await upload('new', reelId);
    await expectAppError(postReelLogic(deps(), caller('new'), { reelId }), 'not_verified');
  });

  it('allows a limited number of reels a day', async () => {
    for (let i = 0; i < REELS_PER_DAY; i++) await post('neha');
    await expectAppError(post('neha'), 'rate_limited');
  });
});

describe('reelFeed', () => {
  it('lists newest first with the author, and marks my own and bookable reels', async () => {
    const t = Date.now();
    const first = await post('neha', 'one', new Date(t - 60_000));
    const second = await post('aarav', 'two', new Date(t));
    const { reels, hasMore } = await reelFeedLogic(deps(), caller('aarav'), {});
    expect(hasMore).toBe(false);
    expect(reels.map((r) => r.reelId)).toEqual([second, first]);
    expect(reels[0]).toMatchObject({ authorName: 'aarav', isMine: true, authorBookable: false, caption: 'two' });
    expect(reels[1]).toMatchObject({ authorUid: uid('neha'), authorName: 'neha', isMine: false, authorBookable: true });
  });

  it('pages with "before" and filters by author', async () => {
    const t = Date.now();
    for (let i = 0; i < REELS_PAGE_SIZE + 2; i++) {
      await sql`insert into reels (id, uid, video_path, created_at)
        values (${randomUUID()}, ${uid('neha')}, ${`reels/x/${i}.mp4`}, ${new Date(t - i * 1000)})`;
    }
    const page1 = await reelFeedLogic(deps(), caller('aarav'), {});
    expect(page1.reels).toHaveLength(REELS_PAGE_SIZE);
    expect(page1.hasMore).toBe(true);
    const page2 = await reelFeedLogic(deps(), caller('aarav'), { before: page1.reels.at(-1)!.reelId });
    expect(page2.reels).toHaveLength(2);
    expect(page2.hasMore).toBe(false);
    expect((await reelFeedLogic(deps(), caller('aarav'), { authorUid: uid('kabir') })).reels).toEqual([]);
  });

  it('hides blocked and banned people, and needs verification', async () => {
    await post('neha');
    await post('kabir');
    await sql`insert into blocks (blocker_uid, blocked_uid) values (${uid('neha')}, ${uid('aarav')})`;
    await sql`update users set account_status = 'banned' where id = ${uid('kabir')}`;
    expect((await reelFeedLogic(deps(), caller('aarav'), {})).reels).toEqual([]);
    await member('new', { verified: false });
    await expectAppError(reelFeedLogic(deps(), caller('new'), {}), 'not_verified');
  });
});

describe('deleteReel and reports', () => {
  it('only the author can delete', async () => {
    const reelId = await post('neha');
    await expectAppError(deleteReelLogic(deps(), caller('aarav'), { reelId }), 'not_found');
    await deleteReelLogic(deps(), caller('neha'), { reelId });
    expect(await sql`select 1 from reels`).toHaveLength(0);
  });

  it('a reel can be reported', async () => {
    const reelId = await post('neha');
    await submitReportLogic(deps(), caller('aarav'), {
      reportedUid: uid('neha'),
      contextType: 'reel',
      refId: reelId,
      reason: 'other',
    });
    const [report] = await sql`select context_type, context_ref_id from reports`;
    expect(report).toEqual({ context_type: 'reel', context_ref_id: reelId });
  });
});

describe('storage and table access', () => {
  it('people upload only to their own reels folder and cannot read the table directly', async () => {
    await asUser(sql, uid('aarav'), async (tx) => {
      expect(await denied(tx, (sp) => sp`insert into storage.objects (bucket_id, name) values ('reels', ${`${uid('neha')}/a.mp4`}) returning id`)).toBe(true);
      expect(await denied(tx, (sp) => sp`insert into storage.objects (bucket_id, name) values ('reels', ${`${uid('aarav')}/a.mp4`}) returning id`)).toBe(false);
      expect(await denied(tx, (sp) => sp`select * from reels`)).toBe(true);
    });
  });
});
