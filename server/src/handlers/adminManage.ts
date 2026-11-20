/**
 * The VYBE team's admin panel (site/admin/index.html): overview, members,
 * bookings, meeting spots, reports, reels, app settings and the activity log.
 * Every action needs the admin secret (see router.ts) and every change is
 * written to `admin_audit` with the name of the person who made it.
 */
import { randomUUID } from "node:crypto";

import { z } from "zod";

import {
  appConfigSchema,
  clearAppConfigCache,
  defaultAppConfig,
} from "../config/appConfig";
import { ACTIVE_STATUSES } from "../domain/booking";
import { uidSchema } from "../shared/callable";
import { asJson, num, type Sql } from "../shared/db";
import { appError, ErrorCodes } from "../shared/errorCodes";
import { deleteAccountLogic } from "./account";
import type { AdminDeps } from "./admin";
import { releaseSlot } from "./booking";
import { splitStoragePath } from "./deps";
import { notify } from "./push";

const LINK_SECONDS = 15 * 60;
const DAY_MS = 86_400_000;

const page = {
  limit: z.number().int().min(1).max(100).default(50),
  offset: z.number().int().min(0).max(100_000).default(0),
};
const searchText = z.string().trim().max(100).optional();

/** "%text%" for ilike, with the wildcard characters in the text taken literally. */
const likePattern = (text: string) =>
  `%${text.replace(/[\\%_]/g, (c) => `\\${c}`)}%`;
const isUuid = (text: string) => uidSchema.safeParse(text).success;

async function audit(
  deps: AdminDeps,
  tx: Sql,
  action: string,
  details: Record<string, unknown>,
) {
  await tx`
    insert into admin_audit (action, actor, details, at)
    values (${action}, ${deps.actor}, ${tx.json(asJson(details))}, ${deps.now()})`;
}

async function signed(
  deps: AdminDeps,
  path: string | null | undefined,
): Promise<string | null> {
  if (!path) return null;
  try {
    return await deps.signUrl(path, LINK_SECONDS);
  } catch {
    return null;
  }
}

// ---------- adminOverview ----------

export const adminOverviewInput = z.object({});

export async function adminOverviewLogic(deps: AdminDeps) {
  const now = deps.now();
  const weekAgo = new Date(now.getTime() - 7 * DAY_MS);
  const monthAgo = new Date(now.getTime() - 30 * DAY_MS);
  const tz = deps.config.launchCity.timezone;
  const [counts] = await deps.sql`
    select
      (select count(*) from users where account_type = 'member')::int as members,
      (select count(*) from users where account_type = 'member' and verification_status = 'approved'
        and account_status = 'active')::int as verified,
      (select count(*) from users where account_status = 'active'
        and verification_steps ->> 'id' = 'in_review')::int as waiting_review,
      (select count(*) from users where account_status = 'banned')::int as banned,
      (select count(*) from users where account_type = 'member' and created_at >= ${weekAgo})::int as new_members_7d,
      (select count(*) from bookings where status in ${deps.sql(ACTIVE_STATUSES)} and end_at >= ${now})::int as upcoming,
      (select count(*) from bookings where status = 'requested' and end_at >= ${now})::int as awaiting_answer,
      (select count(*) from bookings where created_at >= ${weekAgo})::int as bookings_7d,
      (select count(*) from bookings where status in ('checked_in', 'completed')
        and start_at >= ${monthAgo})::int as meetups_30d,
      (select count(*) from reports where status = 'open')::int as open_reports,
      (select count(*) from reports where status = 'open'
        and (context_type = 'meetup' or reason = 'safety_concern'))::int as open_safety_reports,
      (select count(*) from reels)::int as reels,
      (select count(*) from reels where created_at >= ${weekAgo})::int as reels_7d,
      (select count(*) from venues where is_listed and verification_status = 'verified')::int as spots_listed,
      (select count(*) from venues where not is_listed)::int as spots_hidden,
      (select count(*) from venues where featured)::int as spots_featured,
      (select count(*) from venues where source = 'admin')::int as spots_added,
      (select count(*) from purchases where verified_at >= ${monthAgo})::int as purchases_30d,
      (select coalesce(sum(credits), 0) from purchases where verified_at >= ${monthAgo})::int as credits_sold_30d,
      (select count(*) from subscriptions where tier <> 'free' and status = 'active'
        and current_period_end > ${now})::int as paid_plans`;
  const days = await deps.sql<
    { day: string; signups: number; bookings: number }[]
  >`
    select to_char(g.d, 'YYYY-MM-DD') as day,
      (select count(*) from users u where u.account_type = 'member'
        and (u.created_at at time zone ${tz})::date = g.d::date)::int as signups,
      (select count(*) from bookings b where (b.created_at at time zone ${tz})::date = g.d::date)::int as bookings
    from generate_series(
      ((${now}::timestamptz at time zone ${tz})::date - 13)::timestamp,
      (${now}::timestamptz at time zone ${tz})::date::timestamp,
      interval '1 day') as g (d)
    order by g.d`;
  return { counts, days };
}

// ---------- members ----------

export const adminMembersInput = z.object({
  query: searchText,
  filter: z
    .enum(["all", "verified", "waiting", "unverified", "banned"])
    .default("all"),
  ...page,
});

export async function adminMembersLogic(
  deps: AdminDeps,
  input: z.infer<typeof adminMembersInput>,
) {
  const { sql } = deps;
  const q = input.query?.trim() ?? "";
  const filter = {
    all: sql``,
    verified: sql`and u.verification_status = 'approved' and u.account_status = 'active'`,
    waiting: sql`and u.account_status = 'active' and u.verification_steps ->> 'id' = 'in_review'`,
    unverified: sql`and u.verification_status <> 'approved' and u.account_status = 'active'`,
    banned: sql`and u.account_status = 'banned'`,
  }[input.filter];
  const search = !q
    ? sql``
    : isUuid(q)
      ? sql`and u.id = ${q}`
      : sql`and (u.display_name ilike ${likePattern(q)} or p.email ilike ${likePattern(q)} or p.phone_e164 ilike ${likePattern(q)})`;
  const rows = await sql`
    select u.id as uid, u.display_name, u.account_status, u.verification_status, u.verification_steps ->> 'id' as id_step,
      u.age_years, u.created_at, p.email, p.phone_e164 as phone, coalesce(c.balance, 0)::int as credits,
      coalesce(s.tier, 'free') as plan, count(*) over ()::int as total
    from users u
    left join private_profiles p on p.id = u.id
    left join credit_accounts c on c.uid = u.id
    left join subscriptions s on s.uid = u.id
    where u.account_type = 'member' ${filter} ${search}
    order by u.created_at desc
    limit ${input.limit} offset ${input.offset}`;
  return {
    total: rows[0]?.total ?? 0,
    items: rows.map(({ total: _total, ...row }) => row),
  };
}

export const adminMemberInput = z.object({ uid: uidSchema });

/** Everything the team may need about one member, with short-lived photo links. */
export async function adminMemberLogic(
  deps: AdminDeps,
  input: z.infer<typeof adminMemberInput>,
) {
  const { sql } = deps;
  const [user] = await sql<
    {
      uid: string;
      display_name: string | null;
      account_type: string;
      account_status: string;
      verification_status: string;
      verification_steps: Record<string, string>;
      verification_reason: string | null;
      age_years: number | null;
      photo_paths: string[];
      created_at: Date;
      email: string | null;
      phone: string | null;
      date_of_birth: string | null;
      has_trusted_contact: boolean;
      phones_registered: number;
      gender: string | null;
      about: string | null;
      plan_types: string[] | null;
      credits: number;
      plan: string;
      plan_ends: Date | null;
      strikes: number;
    }[]
  >`
    select u.id as uid, u.display_name, u.account_type, u.account_status, u.verification_status, u.verification_steps,
      u.verification_reason, u.age_years, u.photo_paths, u.created_at, p.email, p.phone_e164 as phone, p.date_of_birth,
      (p.trusted_contact is not null) as has_trusted_contact, cardinality(coalesce(p.fcm_tokens, '{}'))::int as phones_registered,
      pr.gender, cp.about, cp.plan_types, coalesce(c.balance, 0)::int as credits, coalesce(s.tier, 'free') as plan,
      s.current_period_end as plan_ends, coalesce(ms.count, 0)::int as strikes
    from users u
    left join private_profiles p on p.id = u.id
    left join preferences pr on pr.uid = u.id
    left join companion_profiles cp on cp.uid = u.id
    left join credit_accounts c on c.uid = u.id
    left join subscriptions s on s.uid = u.id
    left join moderation_strikes ms on ms.uid = u.id
    where u.id = ${input.uid}`;
  if (!user) throw appError(ErrorCodes.notFound, "No such member.");

  const [bookings, reportsAgainst, reportsFiled, ledger, reels, purchases] =
    await Promise.all([
      sql`
      select id, seeker_uid, seeker_name, companion_uid, companion_name, venue_name, start_at, status, status_reason
      from bookings where ${input.uid}::uuid = any (participants)
      order by start_at desc limit 20`,
      sql`
      select r.id, r.context_type, r.reason, r.details, r.source, r.status, r.resolution, r.created_at,
        ru.display_name as reporter_name
      from reports r left join users ru on ru.id = r.reporter_uid
      where r.reported_uid = ${input.uid} order by r.created_at desc limit 20`,
      sql`select count(*)::int as n from reports where reporter_uid = ${input.uid}`,
      sql`
      select delta, balance_after, reason, created_at from credit_ledger
      where uid = ${input.uid} order by created_at desc limit 15`,
      sql`select count(*)::int as n from reels where uid = ${input.uid}`,
      sql`
      select product_id, kind, status, credits, verified_at, refunded_at from purchases
      where uid = ${input.uid} order by verified_at desc limit 10`,
    ]);
  const photoUrls = (
    await Promise.all((user.photo_paths ?? []).map((p) => signed(deps, p)))
  ).filter(Boolean);
  const { photo_paths: _paths, ...rest } = user;
  return {
    member: { ...rest, photoUrls },
    bookings,
    reportsAgainst,
    reportsFiled: reportsFiled[0].n as number,
    reels: reels[0].n as number,
    ledger,
    purchases,
  };
}

/** Cancels a booking inside [tx] and frees its table. Returns who to tell. */
async function cancelInside(
  tx: Sql,
  bookingId: string,
  reason: string,
  now: Date,
) {
  const [booking] = await tx<
    {
      seeker_uid: string;
      companion_uid: string;
      status: string;
      venue_id: string;
      slot_id: string;
      venue_name: string;
      start_at: Date;
    }[]
  >`
    select seeker_uid, companion_uid, status, venue_id, slot_id, venue_name, start_at
    from bookings where id = ${bookingId} for update`;
  if (!booking) throw appError(ErrorCodes.notFound, "Booking not found.");
  if (!(ACTIVE_STATUSES as readonly string[]).includes(booking.status)) {
    throw appError(
      ErrorCodes.invalidInput,
      `This booking is already ${booking.status}.`,
    );
  }
  await releaseSlot(tx, booking.venue_id, booking.slot_id);
  await tx`
    update bookings set status = 'cancelled', status_reason = ${reason}, updated_at = ${now}
    where id = ${bookingId}`;
  return booking;
}

const cancelledMessage = (venueName: string) => ({
  title: "Meetup cancelled",
  body: `Your meetup at ${venueName} was cancelled by the VYBE team.`,
  route: "/bookings",
});

export const adminSetBanInput = z.object({
  uid: uidSchema,
  banned: z.boolean(),
  reason: z.string().trim().max(300).optional(),
});

/**
 * Bans or un-bans a member. A ban hides them everywhere at once (discovery,
 * reels, chat), cancels their open meetups (the other person is told the
 * meetup was cancelled, not why) and closes their chats.
 */
export async function adminSetBanLogic(
  deps: AdminDeps,
  input: z.infer<typeof adminSetBanInput>,
) {
  const now = deps.now();
  const toTell: { uid: string; venueName: string }[] = [];
  const result = await deps.sql.begin(async (tx) => {
    const [user] = await tx<{ account_status: string; account_type: string }[]>`
      select account_status, account_type from users where id = ${input.uid} for update`;
    if (!user) throw appError(ErrorCodes.notFound, "No such member.");
    let cancelledBookings = 0;
    if (input.banned) {
      await tx`update users set account_status = 'banned', updated_at = ${now} where id = ${input.uid}`;
      const open = await tx<{ id: string }[]>`
        select id from bookings where ${input.uid}::uuid = any (participants) and status in ${tx(ACTIVE_STATUSES)}`;
      for (const { id } of open) {
        const booking = await cancelInside(tx, id, "member_banned", now);
        const other =
          booking.seeker_uid === input.uid
            ? booking.companion_uid
            : booking.seeker_uid;
        toTell.push({ uid: other, venueName: booking.venue_name });
      }
      cancelledBookings = open.length;
      await tx`
        update chats set status = 'closed_banned', closed_at = ${now}
        where ${input.uid}::uuid = any (participants) and status = 'open'`;
    } else {
      await tx`update users set account_status = 'active', updated_at = ${now} where id = ${input.uid}`;
    }
    await audit(deps, tx, input.banned ? "member_ban" : "member_unban", {
      uid: input.uid,
      reason: input.reason ?? null,
      cancelledBookings,
    });
    return {
      accountStatus: input.banned ? "banned" : "active",
      cancelledBookings,
    };
  });
  for (const { uid, venueName } of toTell)
    await notify(deps, uid, cancelledMessage(venueName));
  return result;
}

export const adminAdjustCreditsInput = z.object({
  uid: uidSchema,
  delta: z
    .number()
    .int()
    .min(-10_000)
    .max(10_000)
    .refine((n) => n !== 0, "Enter a number other than 0."),
  reason: z.string().trim().min(3, "Say why (for the log).").max(200),
});

/** Gives or takes credits (goodwill, mistakes, refunds outside Play). The balance never goes below 0. */
export async function adminAdjustCreditsLogic(
  deps: AdminDeps,
  input: z.infer<typeof adminAdjustCreditsInput>,
) {
  const now = deps.now();
  return deps.sql.begin(async (tx) => {
    const [user] = await tx`select 1 from users where id = ${input.uid}`;
    if (!user) throw appError(ErrorCodes.notFound, "No such member.");
    await tx`insert into credit_accounts (uid, balance, updated_at) values (${input.uid}, 0, ${now}) on conflict (uid) do nothing`;
    const [account] = await tx<
      { balance: number }[]
    >`select balance from credit_accounts where uid = ${input.uid} for update`;
    const balance = account.balance + input.delta;
    if (balance < 0)
      throw appError(
        ErrorCodes.invalidInput,
        `They only have ${account.balance} credits.`,
      );
    const id = `admin_${randomUUID()}`;
    await tx`update credit_accounts set balance = ${balance}, updated_at = ${now} where uid = ${input.uid}`;
    await tx`
      insert into credit_ledger (id, uid, delta, balance_after, reason, ref_type, ref_id, idempotency_key, created_at)
      values (${id}, ${input.uid}, ${input.delta}, ${balance}, 'admin_adjustment', 'admin', ${deps.actor}, ${id}, ${now})`;
    await audit(deps, tx, "credits_adjust", {
      uid: input.uid,
      delta: input.delta,
      balance,
      reason: input.reason,
    });
    return { balance };
  });
}

export const adminDeleteMemberInput = z.object({
  uid: uidSchema,
  reason: z.string().trim().min(3).max(300),
});

/** Deletes a member exactly as "Delete account" in the app does (deletion requests sent by email). */
export async function adminDeleteMemberLogic(
  deps: AdminDeps,
  input: z.infer<typeof adminDeleteMemberInput>,
) {
  const [user] = await deps.sql<
    { display_name: string | null }[]
  >`select display_name from users where id = ${input.uid}`;
  if (!user) throw appError(ErrorCodes.notFound, "No such member.");
  await deleteAccountLogic(
    { sql: deps.sql, authAdmin: deps.authAdmin, now: deps.now },
    { uid: input.uid, phoneNumber: undefined },
  );
  await audit(deps, deps.sql, "member_delete", {
    uid: input.uid,
    name: user.display_name,
    reason: input.reason,
  });
  return { deleted: true };
}

export const adminMessageMemberInput = z.object({
  uid: uidSchema,
  title: z.string().trim().min(1).max(60),
  body: z.string().trim().min(1).max(200),
});

/** Sends one member a notification from the team. */
export async function adminMessageMemberLogic(
  deps: AdminDeps,
  input: z.infer<typeof adminMessageMemberInput>,
) {
  const [row] = await deps.sql<{ n: number }[]>`
    select cardinality(coalesce(fcm_tokens, '{}'))::int as n from private_profiles where id = ${input.uid}`;
  if (!row) throw appError(ErrorCodes.notFound, "No such member.");
  if (row.n === 0)
    throw appError(
      ErrorCodes.invalidInput,
      "This member has notifications turned off or has not opened the app yet.",
    );
  await notify(deps, input.uid, {
    title: input.title,
    body: input.body,
    route: "/discover",
  });
  await audit(deps, deps.sql, "member_message", {
    uid: input.uid,
    title: input.title,
    body: input.body,
  });
  return { sent: true };
}

// ---------- bookings ----------

export const adminBookingsInput = z.object({
  view: z
    .enum(["upcoming", "needs_answer", "past", "cancelled", "all"])
    .default("upcoming"),
  query: searchText,
  ...page,
});

export async function adminBookingsLogic(
  deps: AdminDeps,
  input: z.infer<typeof adminBookingsInput>,
) {
  const { sql } = deps;
  const now = deps.now();
  const q = input.query?.trim() ?? "";
  const view = {
    upcoming: {
      where: sql`and status in ${sql(ACTIVE_STATUSES)} and end_at >= ${now}`,
      order: sql`start_at asc`,
    },
    needs_answer: {
      where: sql`and status = 'requested' and end_at >= ${now}`,
      order: sql`start_at asc`,
    },
    past: {
      where: sql`and start_at < ${now} and status not in ('cancelled', 'declined')`,
      order: sql`start_at desc`,
    },
    cancelled: {
      where: sql`and status in ('cancelled', 'declined')`,
      order: sql`updated_at desc`,
    },
    all: { where: sql``, order: sql`created_at desc` },
  }[input.view];
  const search = !q
    ? sql``
    : isUuid(q)
      ? sql`and ${q}::uuid = any (participants)`
      : sql`and (id = ${q} or seeker_name ilike ${likePattern(q)} or companion_name ilike ${likePattern(q)}
          or venue_name ilike ${likePattern(q)})`;
  const rows = await sql`
    select id, seeker_uid, seeker_name, companion_uid, companion_name, venue_id, venue_name, venue_category,
      start_at, end_at, plan_type, kind, status, status_reason, created_at, credit_cost,
      cardinality(checked_in_uids)::int as checked_in, cardinality(feedback_uids)::int as feedback,
      count(*) over ()::int as total
    from bookings
    where true ${view.where} ${search}
    order by ${view.order}
    limit ${input.limit} offset ${input.offset}`;
  return {
    total: rows[0]?.total ?? 0,
    items: rows.map(({ total: _total, ...row }) => row),
  };
}

export const adminBookingInput = z.object({
  bookingId: z.string().min(1).max(200),
});

/** One booking with the private "How did it go?" answers and any reports about it. */
export async function adminBookingLogic(
  deps: AdminDeps,
  input: z.infer<typeof adminBookingInput>,
) {
  const { sql } = deps;
  const [booking] = await sql`
    select b.*, v.address_line as venue_address, v.lat as venue_lat, v.lng as venue_lng
    from bookings b left join venues v on v.id = b.venue_id where b.id = ${input.bookingId}`;
  if (!booking) throw appError(ErrorCodes.notFound, "Booking not found.");
  const [feedback, reports] = await Promise.all([
    sql`
      select f.uid, u.display_name as name, f.felt, f.note, f.created_at
      from meet_feedback f left join users u on u.id = f.uid where f.booking_id = ${input.bookingId}`,
    sql`
      select id, reporter_uid, reported_uid, reason, details, status, created_at from reports
      where context_ref_id = ${input.bookingId} order by created_at`,
  ]);
  return { booking, feedback, reports };
}

export const adminCancelBookingInput = z.object({
  bookingId: z.string().min(1).max(200),
  reason: z.string().trim().max(300).optional(),
});

/** Cancels a meetup (table freed, no credits involved) and tells both people. */
export async function adminCancelBookingLogic(
  deps: AdminDeps,
  input: z.infer<typeof adminCancelBookingInput>,
) {
  const now = deps.now();
  const booking = await deps.sql.begin(async (tx) => {
    const booking = await cancelInside(
      tx,
      input.bookingId,
      "admin_cancelled",
      now,
    );
    await audit(deps, tx, "booking_cancel", {
      bookingId: input.bookingId,
      reason: input.reason ?? null,
    });
    return booking;
  });
  for (const uid of [booking.seeker_uid, booking.companion_uid])
    await notify(deps, uid, cancelledMessage(booking.venue_name));
  return { status: "cancelled" };
}

// ---------- meeting spots (venues) ----------

const PLAN_TYPES = ["coffee", "movie", "event", "walk", "dinner"] as const;
export const VENUE_CATEGORIES = [
  "cafe",
  "restaurant",
  "food_court",
  "cinema",
  "mall",
  "open_park",
  "theatre",
] as const;

export const adminVenuesInput = z.object({
  query: searchText,
  filter: z
    .enum(["all", "listed", "hidden", "featured", "added"])
    .default("all"),
  /** Only spots within [km] of this point, nearest first. */
  near: z
    .object({
      lat: z.number().min(-90).max(90),
      lng: z.number().min(-180).max(180),
      km: z.number().min(0.1).max(100),
    })
    .optional(),
  ...page,
});

export async function adminVenuesLogic(
  deps: AdminDeps,
  input: z.infer<typeof adminVenuesInput>,
) {
  const { sql } = deps;
  const now = deps.now();
  const q = input.query?.trim() ?? "";
  const filter = {
    all: sql``,
    listed: sql`and v.is_listed`,
    hidden: sql`and not v.is_listed`,
    featured: sql`and v.featured`,
    added: sql`and v.source = 'admin'`,
  }[input.filter];
  const search = q
    ? sql`and (v.id = ${q} or v.name ilike ${likePattern(q)} or v.address_line ilike ${likePattern(q)})`
    : sql``;
  const near = input.near;
  const dLat = near ? near.km / 111.32 : 0;
  const dLng = near
    ? near.km / (111.32 * Math.max(Math.cos((near.lat * Math.PI) / 180), 0.01))
    : 0;
  const box = near
    ? sql`and v.lat between ${near.lat - dLat} and ${near.lat + dLat} and v.lng between ${near.lng - dLng} and ${near.lng + dLng}`
    : sql``;
  const order = near
    ? sql`(v.lat - ${near.lat}) ^ 2 + ((v.lng - ${near.lng}) * ${Math.cos((near.lat * Math.PI) / 180)}) ^ 2`
    : sql`v.featured desc, v.name`;
  const rows = await sql`
    with found as (
      select v.*, count(*) over ()::int as total from venues v
      where true ${filter} ${search} ${box}
      order by ${order}
      limit ${input.limit} offset ${input.offset}
    )
    select f.id, f.name, f.category, f.address_line, f.lat, f.lng, f.plan_types, f.perk ->> 'text' as perk,
      f.is_listed, f.featured, f.source, f.verification_status, f.admin_note, f.owner_uid, f.updated_at, f.total,
      (select count(*) from bookings b where b.venue_id = f.id and b.status in ${sql(ACTIVE_STATUSES)}
        and b.end_at >= ${now})::int as upcoming_bookings,
      (select count(*) from bookings b where b.venue_id = f.id)::int as all_bookings
    from found f`;
  // The CTE keeps its order only by chance; sort again the same way.
  const items = rows.map(({ total: _total, ...row }) => row);
  if (near) {
    const k = Math.cos((near.lat * Math.PI) / 180);
    const d = (v: { lat: number; lng: number }) =>
      (v.lat - near.lat) ** 2 + ((v.lng - near.lng) * k) ** 2;
    items.sort((a, b) => d(a as never) - d(b as never));
  } else {
    items.sort(
      (a, b) =>
        Number(b.featured) - Number(a.featured) ||
        String(a.name).localeCompare(String(b.name)),
    );
  }
  return { total: rows[0]?.total ?? 0, items };
}

export const adminSaveVenueInput = z.object({
  /** Missing: a new spot. */
  venueId: z.string().min(1).max(200).optional(),
  name: z.string().trim().min(2).max(80),
  category: z.enum(VENUE_CATEGORIES),
  addressLine: z.string().trim().max(200),
  lat: z.number().min(-90).max(90),
  lng: z.number().min(-180).max(180),
  planTypes: z.array(z.enum(PLAN_TYPES)).min(1, "Pick at least one plan."),
  perk: z.string().trim().max(140).nullable().optional(),
  listed: z.boolean(),
  featured: z.boolean(),
  note: z.string().trim().max(300).nullable().optional(),
});

/**
 * Adds a meeting spot or corrects one. A corrected public place becomes a
 * team spot, so the monthly map refresh keeps the correction.
 */
export async function adminSaveVenueLogic(
  deps: AdminDeps,
  input: z.infer<typeof adminSaveVenueInput>,
) {
  const now = deps.now();
  const perk = input.perk ? { text: input.perk } : null;
  const note = input.note || null;
  return deps.sql.begin(async (tx) => {
    if (!input.venueId) {
      const id = `adm_${randomUUID()}`;
      await tx`
        insert into venues (id, owner_uid, name, category, address_line, lat, lng, plan_types, verification_status,
          is_listed, featured, perk, admin_note, source, updated_at)
        values (${id}, null, ${input.name}, ${input.category}, ${input.addressLine}, ${input.lat}, ${input.lng},
          ${input.planTypes}, 'verified', ${input.listed}, ${input.featured}, ${perk ? tx.json(perk) : null}, ${note},
          'admin', ${now})`;
      await audit(deps, tx, "spot_add", { venueId: id, name: input.name });
      return { venueId: id, source: "admin" };
    }
    const [venue] = await tx<
      {
        source: string;
        name: string;
        category: string;
        address_line: string;
        lat: number;
        lng: number;
        plan_types: string[];
      }[]
    >`select source, name, category, address_line, lat, lng, plan_types from venues where id = ${input.venueId} for update`;
    if (!venue) throw appError(ErrorCodes.notFound, "Spot not found.");
    const placeChanged =
      venue.name !== input.name ||
      venue.category !== input.category ||
      venue.address_line !== input.addressLine ||
      Math.abs(venue.lat - input.lat) > 1e-7 ||
      Math.abs(venue.lng - input.lng) > 1e-7 ||
      [...venue.plan_types].sort().join() !==
        [...input.planTypes].sort().join();
    const source =
      venue.source === "osm" && placeChanged ? "admin" : venue.source;
    await tx`
      update venues set name = ${input.name}, category = ${input.category}, address_line = ${input.addressLine},
        lat = ${input.lat}, lng = ${input.lng}, plan_types = ${input.planTypes}, is_listed = ${input.listed},
        featured = ${input.featured}, perk = ${perk ? tx.json(perk) : null}, admin_note = ${note}, source = ${source},
        updated_at = ${now}
      where id = ${input.venueId}`;
    await audit(deps, tx, "spot_edit", {
      venueId: input.venueId,
      name: input.name,
      listed: input.listed,
      featured: input.featured,
    });
    return { venueId: input.venueId, source };
  });
}

export const adminSetVenueFlagsInput = z.object({
  venueId: z.string().min(1).max(200),
  listed: z.boolean().optional(),
  featured: z.boolean().optional(),
});

/** Hides/shows or features/unfeatures a spot. Meetups already booked there stay booked. */
export async function adminSetVenueFlagsLogic(
  deps: AdminDeps,
  input: z.infer<typeof adminSetVenueFlagsInput>,
) {
  const now = deps.now();
  return deps.sql.begin(async (tx) => {
    const [venue] = await tx<
      { is_listed: boolean; featured: boolean; name: string }[]
    >`
      select is_listed, featured, name from venues where id = ${input.venueId} for update`;
    if (!venue) throw appError(ErrorCodes.notFound, "Spot not found.");
    const listed = input.listed ?? venue.is_listed;
    const featured = input.featured ?? venue.featured;
    await tx`update venues set is_listed = ${listed}, featured = ${featured}, updated_at = ${now} where id = ${input.venueId}`;
    await audit(deps, tx, "spot_flags", {
      venueId: input.venueId,
      name: venue.name,
      listed,
      featured,
    });
    const [upcoming] = await tx<{ n: number }[]>`
      select count(*)::int as n from bookings
      where venue_id = ${input.venueId} and status in ${tx(ACTIVE_STATUSES)} and end_at >= ${now}`;
    return { listed, featured, upcomingBookings: upcoming.n };
  });
}

export const adminDeleteVenueInput = z.object({
  venueId: z.string().min(1).max(200),
});

/** Deletes a spot the team added by mistake. Spots with any booking can only be hidden. */
export async function adminDeleteVenueLogic(
  deps: AdminDeps,
  input: z.infer<typeof adminDeleteVenueInput>,
) {
  return deps.sql.begin(async (tx) => {
    const [venue] = await tx<{ source: string; name: string }[]>`
      select source, name from venues where id = ${input.venueId} for update`;
    if (!venue) throw appError(ErrorCodes.notFound, "Spot not found.");
    if (venue.source !== "admin")
      throw appError(
        ErrorCodes.invalidInput,
        "Only spots the team added can be deleted. Hide this one instead.",
      );
    const [used] =
      await tx`select 1 from bookings where venue_id = ${input.venueId} limit 1`;
    if (used)
      throw appError(
        ErrorCodes.invalidInput,
        "This spot has bookings. Hide it instead.",
      );
    await tx`delete from venues where id = ${input.venueId}`;
    await audit(deps, tx, "spot_delete", {
      venueId: input.venueId,
      name: venue.name,
    });
    return { deleted: true };
  });
}

// ---------- reports ----------

export const adminReportsInput = z.object({
  status: z.enum(["open", "closed", "all"]).default("open"),
  ...page,
});

/**
 * Reports with what is needed to decide: who and why, earlier reports about
 * the same person, the private meetup answer, the reported reel, or the last
 * messages of a reported chat.
 */
export async function adminReportsLogic(
  deps: AdminDeps,
  input: z.infer<typeof adminReportsInput>,
) {
  const { sql } = deps;
  const where = {
    open: sql`where r.status = 'open'`,
    closed: sql`where r.status <> 'open'`,
    all: sql``,
  }[input.status];
  const rows = await sql<
    {
      id: string;
      reporter_uid: string | null;
      reporter_name: string | null;
      reported_uid: string;
      reported_name: string | null;
      reported_status: string | null;
      context_type: string;
      context_ref_id: string | null;
      reason: string;
      details: string | null;
      source: string;
      status: string;
      resolution: string | null;
      resolution_note: string | null;
      created_at: Date;
      resolved_at: Date | null;
      reports_about_them: number;
      total: number;
    }[]
  >`
    select r.id, r.reporter_uid, ru.display_name as reporter_name, r.reported_uid, u.display_name as reported_name,
      u.account_status as reported_status, r.context_type, r.context_ref_id, r.reason, r.details, r.source, r.status,
      r.resolution, r.resolution_note, r.created_at, r.resolved_at,
      (select count(*) from reports x where x.reported_uid = r.reported_uid)::int as reports_about_them,
      count(*) over ()::int as total
    from reports r
    left join users ru on ru.id = r.reporter_uid
    left join users u on u.id = r.reported_uid
    ${where}
    order by (r.context_type = 'meetup' or r.reason = 'safety_concern') desc, r.created_at ${input.status === "open" ? sql`asc` : sql`desc`}
    limit ${input.limit} offset ${input.offset}`;

  const items = await Promise.all(
    rows.map(async ({ total: _total, ...row }) => {
      let context: Record<string, unknown> | null = null;
      if (
        row.context_type === "meetup" &&
        row.context_ref_id &&
        row.reporter_uid
      ) {
        const [answer] = await sql`
          select felt, note from meet_feedback where booking_id = ${row.context_ref_id} and uid = ${row.reporter_uid}`;
        const [booking] =
          await sql`select venue_name, start_at, status from bookings where id = ${row.context_ref_id}`;
        context = {
          kind: "meetup",
          answer: answer ?? null,
          booking: booking ?? null,
        };
      } else if (
        row.context_type === "reel" &&
        row.context_ref_id &&
        isUuid(row.context_ref_id)
      ) {
        const [reel] = await sql<
          { id: string; caption: string; video_path: string }[]
        >`
          select id, caption, video_path from reels where id = ${row.context_ref_id}`;
        context = reel
          ? {
              kind: "reel",
              reelId: reel.id,
              caption: reel.caption,
              videoUrl: await signed(deps, reel.video_path),
            }
          : { kind: "reel", deleted: true };
      } else if (row.context_type === "chat" && row.context_ref_id) {
        const messages = await sql`
          select sender_uid, type, text, created_at from messages
          where chat_id = ${row.context_ref_id} and type = 'text'
          order by created_at desc limit 30`;
        context = { kind: "chat", messages: messages.reverse() };
      } else if (row.context_type === "booking" && row.context_ref_id) {
        const [booking] =
          await sql`select venue_name, start_at, status from bookings where id = ${row.context_ref_id}`;
        context = { kind: "booking", booking: booking ?? null };
      }
      return { ...row, context };
    }),
  );
  return { total: rows[0]?.total ?? 0, items };
}

export const adminResolveReportInput = z.object({
  reportId: z.string().uuid(),
  resolution: z.enum(["dismissed", "actioned"]),
  note: z.string().trim().max(500).optional(),
});

export async function adminResolveReportLogic(
  deps: AdminDeps,
  input: z.infer<typeof adminResolveReportInput>,
) {
  const now = deps.now();
  return deps.sql.begin(async (tx) => {
    const [report] =
      await tx`select 1 from reports where id = ${input.reportId} for update`;
    if (!report) throw appError(ErrorCodes.notFound, "Report not found.");
    await tx`
      update reports set status = 'closed', resolution = ${input.resolution}, resolution_note = ${input.note || null},
        resolved_at = ${now}
      where id = ${input.reportId}`;
    await audit(deps, tx, `report_${input.resolution}`, {
      reportId: input.reportId,
      note: input.note ?? null,
    });
    return { status: "closed" };
  });
}

// ---------- reels ----------

export const adminReelsInput = z.object({
  /** Only reels someone reported. */
  reportedOnly: z.boolean().default(false),
  authorUid: uidSchema.optional(),
  ...page,
});

export async function adminReelsLogic(
  deps: AdminDeps,
  input: z.infer<typeof adminReelsInput>,
) {
  const { sql } = deps;
  const rows = await sql<
    {
      id: string;
      uid: string;
      author: string | null;
      caption: string;
      video_path: string;
      created_at: Date;
      reports: number;
      total: number;
    }[]
  >`
    select r.id, r.uid, u.display_name as author, r.caption, r.video_path, r.created_at,
      (select count(*) from reports x where x.context_type = 'reel' and x.context_ref_id = r.id::text)::int as reports,
      count(*) over ()::int as total
    from reels r left join users u on u.id = r.uid
    where true
      ${input.authorUid ? sql`and r.uid = ${input.authorUid}` : sql``}
      ${input.reportedOnly ? sql`and exists (select 1 from reports x where x.context_type = 'reel' and x.context_ref_id = r.id::text)` : sql``}
    order by r.created_at desc
    limit ${input.limit} offset ${input.offset}`;
  const items = await Promise.all(
    rows.map(async ({ total: _total, video_path, ...row }) => ({
      ...row,
      videoUrl: await signed(deps, video_path),
    })),
  );
  return { total: rows[0]?.total ?? 0, items };
}

export const adminDeleteReelInput = z.object({
  reelId: z.string().uuid(),
  reason: z.string().trim().max(300).optional(),
});

/** Removes a reel and its video, closes its reports and tells the author. */
export async function adminDeleteReelLogic(
  deps: AdminDeps,
  input: z.infer<typeof adminDeleteReelInput>,
) {
  const now = deps.now();
  const reel = await deps.sql.begin(async (tx) => {
    const [reel] = await tx<
      { uid: string; video_path: string; caption: string }[]
    >`
      select uid, video_path, caption from reels where id = ${input.reelId} for update`;
    if (!reel)
      throw appError(ErrorCodes.notFound, "Reel not found (already deleted?).");
    await tx`delete from reels where id = ${input.reelId}`;
    await tx`
      update reports set status = 'closed', resolution = 'actioned', resolution_note = 'Reel removed', resolved_at = ${now}
      where context_type = 'reel' and context_ref_id = ${input.reelId} and status = 'open'`;
    await audit(deps, tx, "reel_delete", {
      reelId: input.reelId,
      uid: reel.uid,
      caption: reel.caption,
      reason: input.reason ?? null,
    });
    return reel;
  });
  const { bucket, name } = splitStoragePath(reel.video_path);
  try {
    await deps.authAdmin.deleteFiles(bucket, [name]);
  } catch (error) {
    console.warn(
      `Reel video ${reel.video_path} could not be deleted: ${String(error)}`,
    );
  }
  await notify(deps, reel.uid, {
    title: "Your reel was removed",
    body: "It broke the VYBE community rules.",
    route: "/reels",
  });
  return { deleted: true };
}

// ---------- app settings ----------

export const adminGetConfigInput = z.object({});

export async function adminGetConfigLogic(deps: AdminDeps) {
  const [row] = await deps.sql<
    { overrides: Record<string, unknown>; updated_at: Date }[]
  >`
    select overrides, updated_at from app_config where id = 1`;
  // Settings that no longer exist are left out, so saving drops them.
  const overrides = Object.fromEntries(
    Object.entries(row?.overrides ?? {}).filter(
      ([key]) => key in defaultAppConfig || MARKER_KEYS.has(key),
    ),
  );
  return {
    overrides,
    updatedAt: row?.updated_at ?? null,
    defaults: defaultAppConfig,
  };
}

export const adminSaveConfigInput = z.object({
  overrides: z.record(z.string(), z.unknown()),
});

/** Overrides that are not app settings: `environment` marks the live project (the seed script refuses to run on it). */
const MARKER_KEYS = new Set(["environment"]);

/**
 * Replaces the settings overrides. Every key must be a known setting and the
 * result must be valid, so a typo can never switch the app back to defaults.
 */
export async function adminSaveConfigLogic(
  deps: AdminDeps,
  input: z.infer<typeof adminSaveConfigInput>,
) {
  const unknown = Object.keys(input.overrides).filter(
    (key) => !(key in defaultAppConfig) && !MARKER_KEYS.has(key),
  );
  if (unknown.length)
    throw appError(
      ErrorCodes.invalidInput,
      `Unknown setting: ${unknown.join(", ")}.`,
    );
  const settings = Object.fromEntries(
    Object.entries(input.overrides).filter(([key]) => !MARKER_KEYS.has(key)),
  );
  const parsed = appConfigSchema.safeParse({
    ...defaultAppConfig,
    ...settings,
  });
  if (!parsed.success) {
    const issue = parsed.error.issues[0];
    throw appError(
      ErrorCodes.invalidInput,
      `${issue.path.join(".") || "settings"}: ${issue.message}`,
    );
  }
  const now = deps.now();
  await deps.sql.begin(async (tx) => {
    const [before] = await tx<
      { overrides: Record<string, unknown> }[]
    >`select overrides from app_config where id = 1 for update`;
    await tx`update app_config set overrides = ${tx.json(asJson(input.overrides))}, updated_at = ${now} where id = 1`;
    const keys = new Set([
      ...Object.keys(before?.overrides ?? {}),
      ...Object.keys(input.overrides),
    ]);
    const changed = [...keys].filter(
      (key) =>
        JSON.stringify(before?.overrides?.[key]) !==
        JSON.stringify(input.overrides[key]),
    );
    await audit(deps, tx, "settings_save", { changed });
  });
  clearAppConfigCache();
  return { saved: true };
}

// ---------- activity log ----------

export const adminAuditInput = z.object({ ...page });

export async function adminAuditLogic(
  deps: AdminDeps,
  input: z.infer<typeof adminAuditInput>,
) {
  const rows = await deps.sql`
    select id, action, actor, details, at, count(*) over ()::int as total
    from admin_audit order by at desc, id desc
    limit ${input.limit} offset ${input.offset}`;
  return {
    total: num(rows[0]?.total),
    items: rows.map(({ total: _total, ...row }) => ({
      ...row,
      id: num(row.id),
    })),
  };
}
