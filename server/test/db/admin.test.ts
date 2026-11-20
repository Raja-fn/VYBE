import { handleApiRequest, type ApiContext } from "../../src/api/router";
import { loadAppConfig } from "../../src/config/appConfig";
import type { AdminDeps } from "../../src/handlers/admin";
import {
  adminAdjustCreditsLogic,
  adminAuditLogic,
  adminBookingLogic,
  adminBookingsLogic,
  adminCancelBookingLogic,
  adminDeleteMemberLogic,
  adminDeleteReelLogic,
  adminDeleteVenueLogic,
  adminGetConfigLogic,
  adminMemberLogic,
  adminMembersLogic,
  adminMessageMemberLogic,
  adminOverviewLogic,
  adminReelsLogic,
  adminReportsLogic,
  adminResolveReportLogic,
  adminSaveConfigLogic,
  adminSaveVenueLogic,
  adminSetBanLogic,
  adminSetVenueFlagsLogic,
  adminVenuesLogic,
} from "../../src/handlers/adminManage";
import { ensureDefaultSlots } from "../../src/handlers/places";
import type { AuthAdmin } from "../../src/services/auth/authAdmin";
import { createServices } from "../../src/services/factory";
import { FakePushService } from "../../src/services/push/pushService";
import {
  addPerson,
  addVenue,
  connect,
  expectAppError,
  makeDeps,
  People,
  reset,
} from "./helpers";

const NOW = new Date("2026-11-20T10:00:00Z");
const sql = connect();
let people: People;
let push: FakePushService;
let deletedFiles: [string, string[]][];

const authAdmin: AuthAdmin = {
  createPhoneUser: async () => "",
  createSignInToken: async () => "",
  deleteUser: async (uid) => {
    await sql`delete from auth.users where id = ${uid}`;
  },
  deleteFiles: async (bucket, names) => {
    deletedFiles.push([bucket, names]);
  },
};

function deps(): AdminDeps {
  const base = makeDeps(sql, {}, NOW);
  base.services.push = push;
  return {
    ...base,
    signUrl: async (path) => `https://signed.example/${path}`,
    authAdmin,
    actor: "Riya",
  };
}

const uid = (name: string) => people.uid(name);
const at = (hours: number) => new Date(NOW.getTime() + hours * 3_600_000);

async function booking(
  id: string,
  seeker: string,
  companion: string,
  status: string,
  startInHours: number,
) {
  await sql`
    insert into bookings (id, seeker_uid, seeker_name, companion_uid, companion_name, venue_id, venue_name, venue_category,
      venue_owner_uid, slot_id, day_key, start_at, end_at, plan_type, kind, status, credit_cost, participants, created_at)
    values (${id}, ${uid(seeker)}, ${seeker}, ${uid(companion)}, ${companion}, 'cafe', 'Blue Tokai', 'cafe', ${uid("owner")},
      's1', '2026-11-20', ${at(startInHours)}, ${at(startInHours + 1)}, 'coffee', 'scheduled', ${status}, 0,
      ${[uid(seeker), uid(companion)]}::uuid[], ${NOW})`;
  if (["requested", "accepted", "checked_in"].includes(status)) {
    await sql`update venue_slots set booked = booked + 1 where venue_id = 'cafe' and id = 's1'`;
  }
}

const tokens = async (name: string, ...list: string[]) =>
  sql`update private_profiles set fcm_tokens = ${list} where id = ${uid(name)}`;
const sentTo = (token: string) =>
  push.sent.filter((s) => s.tokens.includes(token)).map((s) => s.message);
const lastAudit = async () =>
  (
    await sql`select action, actor, details from admin_audit order by id desc limit 1`
  )[0];

beforeEach(async () => {
  await reset(sql);
  people = new People();
  push = new FakePushService();
  deletedFiles = [];
  await addPerson(sql, {
    uid: uid("aarav"),
    name: "Aarav",
    gender: "man",
    credits: 10,
  });
  await addPerson(sql, {
    uid: uid("neha"),
    name: "Neha",
    gender: "woman",
    companion: { planTypes: ["coffee"] },
  });
  await addPerson(sql, {
    uid: uid("new"),
    name: "Kabir",
    gender: "man",
    verified: false,
  });
  await addVenue(
    sql,
    {
      id: "cafe",
      ownerUid: uid("owner"),
      name: "Blue Tokai",
      at: { lat: 19.06, lng: 72.83 },
    },
    [
      {
        id: "s1",
        dayKey: "2026-11-20",
        startAt: at(2),
        endAt: at(3),
        capacity: 3,
      },
    ],
  );
});

describe("overview", () => {
  it("counts members, meetups, reports and the last 14 days", async () => {
    await booking("b1", "aarav", "neha", "requested", 5);
    await sql`insert into reports (reporter_uid, reported_uid, context_type, reason, source) values
      (${uid("neha")}, ${uid("aarav")}, 'meetup', 'safety_concern', 'feedback')`;
    const { counts, days } = await adminOverviewLogic(deps());
    expect(counts).toMatchObject({
      members: 3,
      verified: 2,
      banned: 0,
      upcoming: 1,
      awaiting_answer: 1,
      open_reports: 1,
      open_safety_reports: 1,
      spots_listed: 1,
    });
    expect(days).toHaveLength(14);
    expect(days.at(-1)).toEqual({
      day: "2026-11-20",
      signups: expect.any(Number),
      bookings: 1,
    });
  });
});

describe("members", () => {
  it("searches by name, email or id and filters by state", async () => {
    expect(
      (
        await adminMembersLogic(deps(), {
          query: "neh",
          filter: "all",
          limit: 50,
          offset: 0,
        })
      ).items.map((m) => m.uid),
    ).toEqual([uid("neha")]);
    expect(
      (
        await adminMembersLogic(deps(), {
          query: uid("aarav"),
          filter: "all",
          limit: 50,
          offset: 0,
        })
      ).total,
    ).toBe(1);
    expect(
      (
        await adminMembersLogic(deps(), {
          query: "100%",
          filter: "all",
          limit: 50,
          offset: 0,
        })
      ).total,
    ).toBe(0);
    const unverified = await adminMembersLogic(deps(), {
      filter: "unverified",
      limit: 50,
      offset: 0,
    });
    expect(unverified.items.map((m) => m.display_name)).toEqual(["Kabir"]);
  });

  it("shows one member with their meetups, reports and credits", async () => {
    await booking("b1", "aarav", "neha", "accepted", 5);
    const { member, bookings, ledger, reportsFiled } = await adminMemberLogic(
      deps(),
      { uid: uid("aarav") },
    );
    expect(member).toMatchObject({
      display_name: "Aarav",
      credits: 10,
      plan: "free",
      account_status: "active",
    });
    expect(bookings).toHaveLength(1);
    expect(ledger).toEqual([]);
    expect(reportsFiled).toBe(0);
    await expectAppError(
      adminMemberLogic(deps(), { uid: uid("nobody") }),
      "not_found",
    );
  });

  it("a ban cancels their meetups, frees the table, closes chats and tells the other person", async () => {
    await booking("b1", "aarav", "neha", "accepted", 5);
    await booking("b2", "aarav", "neha", "cancelled", 6);
    await sql`insert into chats (id, participants, seeker_uid, companion_uid, opened_by)
      values ('c1', ${[uid("aarav"), uid("neha")]}::uuid[], ${uid("aarav")}, ${uid("neha")}, ${uid("aarav")})`;
    await tokens("neha", "neha-phone");

    expect(
      await adminSetBanLogic(deps(), {
        uid: uid("aarav"),
        banned: true,
        reason: "Harassment",
      }),
    ).toEqual({
      accountStatus: "banned",
      cancelledBookings: 1,
    });
    expect(
      (
        await sql`select status, status_reason from bookings where id = 'b1'`
      )[0],
    ).toEqual({
      status: "cancelled",
      status_reason: "member_banned",
    });
    expect(
      (await sql`select booked from venue_slots where id = 's1'`)[0].booked,
    ).toBe(0);
    expect(
      (await sql`select status from chats where id = 'c1'`)[0].status,
    ).toBe("closed_banned");
    expect(
      (
        await sql`select banned from companion_index where uid = ${uid("aarav")}`
      )[0]?.banned ?? true,
    ).toBe(true);
    expect(sentTo("neha-phone")).toEqual([
      expect.objectContaining({
        title: "Meetup cancelled",
        route: "/bookings",
      }),
    ]);
    expect(await lastAudit()).toMatchObject({
      action: "member_ban",
      actor: "Riya",
      details: { reason: "Harassment" },
    });

    await adminSetBanLogic(deps(), { uid: uid("aarav"), banned: false });
    expect(
      (
        await sql`select account_status from users where id = ${uid("aarav")}`
      )[0].account_status,
    ).toBe("active");
  });

  it("credits can be given or taken, never below zero, and are in their history", async () => {
    expect(
      await adminAdjustCreditsLogic(deps(), {
        uid: uid("aarav"),
        delta: 5,
        reason: "Sorry for the bug",
      }),
    ).toEqual({ balance: 15 });
    expect(
      await adminAdjustCreditsLogic(deps(), {
        uid: uid("aarav"),
        delta: -15,
        reason: "Mistake",
      }),
    ).toEqual({ balance: 0 });
    await expectAppError(
      adminAdjustCreditsLogic(deps(), {
        uid: uid("aarav"),
        delta: -1,
        reason: "Again",
      }),
      "invalid_input",
    );
    const ledger =
      await sql`select delta, balance_after, reason, ref_id from credit_ledger where uid = ${uid("aarav")} order by created_at, delta desc`;
    expect(ledger).toEqual([
      {
        delta: 5,
        balance_after: 15,
        reason: "admin_adjustment",
        ref_id: "Riya",
      },
      {
        delta: -15,
        balance_after: 0,
        reason: "admin_adjustment",
        ref_id: "Riya",
      },
    ]);
  });

  it("a deletion request removes the account like the app does", async () => {
    await booking("b1", "aarav", "neha", "requested", 5);
    await adminDeleteMemberLogic(deps(), {
      uid: uid("aarav"),
      reason: "Asked by email",
    });
    expect(
      await sql`select 1 from users where id = ${uid("aarav")}`,
    ).toHaveLength(0);
    expect(await lastAudit()).toMatchObject({
      action: "member_delete",
      details: { name: "Aarav", reason: "Asked by email" },
    });
  });

  it("a message needs a phone that allows notifications", async () => {
    await expectAppError(
      adminMessageMemberLogic(deps(), {
        uid: uid("aarav"),
        title: "Hi",
        body: "Hello",
      }),
      "invalid_input",
    );
    await tokens("aarav", "aarav-phone");
    await adminMessageMemberLogic(deps(), {
      uid: uid("aarav"),
      title: "Hi",
      body: "Hello",
    });
    expect(sentTo("aarav-phone")).toEqual([
      { title: "Hi", body: "Hello", route: "/discover" },
    ]);
  });
});

describe("bookings", () => {
  it("lists by view and search, with the private answers in the detail", async () => {
    await booking("b1", "aarav", "neha", "requested", 5);
    await booking("b2", "aarav", "neha", "accepted", -48);
    await booking("b3", "aarav", "neha", "cancelled", 8);
    await sql`insert into meet_feedback (booking_id, uid, about_uid, felt, note) values ('b2', ${uid("neha")}, ${uid("aarav")}, 'okay', 'Late')`;
    const ids = async (
      view: "upcoming" | "needs_answer" | "past" | "cancelled" | "all",
      query?: string,
    ) =>
      (
        await adminBookingsLogic(deps(), { view, query, limit: 50, offset: 0 })
      ).items.map((b) => b.id);
    expect(await ids("upcoming")).toEqual(["b1"]);
    expect(await ids("needs_answer")).toEqual(["b1"]);
    expect(await ids("past")).toEqual(["b2"]);
    expect(await ids("cancelled")).toEqual(["b3"]);
    expect((await ids("all", "tokai")).sort()).toEqual(["b1", "b2", "b3"]);
    expect(await ids("all", "nobody")).toEqual([]);
    const detail = await adminBookingLogic(deps(), { bookingId: "b2" });
    expect(detail.feedback).toEqual([
      expect.objectContaining({ name: "Neha", felt: "okay", note: "Late" }),
    ]);
  });

  it("the team can cancel an open meetup; both people are told", async () => {
    await booking("b1", "aarav", "neha", "accepted", 5);
    await tokens("aarav", "aarav-phone");
    await tokens("neha", "neha-phone");
    await adminCancelBookingLogic(deps(), {
      bookingId: "b1",
      reason: "Venue closed",
    });
    expect(
      (
        await sql`select status, status_reason from bookings where id = 'b1'`
      )[0],
    ).toEqual({
      status: "cancelled",
      status_reason: "admin_cancelled",
    });
    expect(
      (await sql`select booked from venue_slots where id = 's1'`)[0].booked,
    ).toBe(0);
    expect(sentTo("aarav-phone")).toHaveLength(1);
    expect(sentTo("neha-phone")[0].body).toBe(
      "Your meetup at Blue Tokai was cancelled by the VYBE team.",
    );
    await expectAppError(
      adminCancelBookingLogic(deps(), { bookingId: "b1" }),
      "invalid_input",
    );
  });
});

describe("meeting spots", () => {
  const spot = {
    name: "Chai Point",
    category: "cafe" as const,
    addressLine: "Linking Road, Bandra",
    lat: 19.061,
    lng: 72.831,
    planTypes: ["coffee" as const],
    perk: "Free cookie",
    listed: true,
    featured: true,
    note: "Owner said yes",
  };

  it("the team adds a spot; it gets default slots and is featured", async () => {
    const { venueId, source } = await adminSaveVenueLogic(deps(), spot);
    expect(source).toBe("admin");
    await ensureDefaultSlots(
      sql,
      { config: deps().config, now: () => NOW },
      venueId,
      "2026-11-21",
    );
    expect(
      (
        await sql`select count(*)::int as n from venue_slots where venue_id = ${venueId}`
      )[0].n,
    ).toBeGreaterThan(0);
    const list = await adminVenuesLogic(deps(), {
      filter: "featured",
      limit: 50,
      offset: 0,
    });
    expect(list.items).toEqual([
      expect.objectContaining({
        id: venueId,
        perk: "Free cookie",
        admin_note: "Owner said yes",
      }),
    ]);
    const near = await adminVenuesLogic(deps(), {
      filter: "all",
      near: { lat: 19.0601, lng: 72.8301, km: 2 },
      limit: 50,
      offset: 0,
    });
    expect(near.items.map((v) => v.name)).toEqual(["Blue Tokai", "Chai Point"]);
  });

  it("correcting a public place keeps the correction; hiding only changes the flag", async () => {
    await sql`insert into venues (id, name, category, address_line, lat, lng, plan_types, verification_status, is_listed, source)
      values ('osm-1', 'Cafe Typo', 'cafe', 'Road', 19.06, 72.83, '{coffee}', 'verified', true, 'osm')`;
    await adminSetVenueFlagsLogic(deps(), { venueId: "osm-1", listed: false });
    expect(
      (await sql`select source, is_listed from venues where id = 'osm-1'`)[0],
    ).toEqual({ source: "osm", is_listed: false });
    await adminSaveVenueLogic(deps(), {
      ...spot,
      venueId: "osm-1",
      name: "Cafe Right",
      listed: true,
      featured: false,
    });
    expect(
      (await sql`select source, name from venues where id = 'osm-1'`)[0],
    ).toEqual({ source: "admin", name: "Cafe Right" });
    await expectAppError(
      adminDeleteVenueLogic(deps(), { venueId: "cafe" }),
      "invalid_input",
    );
  });

  it("hiding a spot says how many meetups are still booked there", async () => {
    await booking("b1", "aarav", "neha", "accepted", 5);
    expect(
      await adminSetVenueFlagsLogic(deps(), { venueId: "cafe", listed: false }),
    ).toEqual({
      listed: false,
      featured: false,
      upcomingBookings: 1,
    });
  });

  it("a spot added by mistake can be deleted while nobody booked it", async () => {
    const { venueId } = await adminSaveVenueLogic(deps(), spot);
    await adminDeleteVenueLogic(deps(), { venueId });
    expect(await sql`select 1 from venues where id = ${venueId}`).toHaveLength(
      0,
    );
  });
});

describe("reports and reels", () => {
  const reelId = "11111111-1111-4111-8111-111111111111";

  beforeEach(async () => {
    await sql`insert into reels (id, uid, video_path, caption) values (${reelId}, ${uid("aarav")}, ${`reels/${uid("aarav")}/${reelId}.mp4`}, 'Hi')`;
    await sql`insert into reports (reporter_uid, reported_uid, context_type, context_ref_id, reason, source, created_at) values
      (${uid("neha")}, ${uid("aarav")}, 'reel', ${reelId}, 'other', 'user', ${at(-2)}),
      (${uid("aarav")}, ${uid("neha")}, 'profile', null, 'fake_profile', 'user', ${at(-1)})`;
  });

  it("lists open reports with the reported reel", async () => {
    const { items } = await adminReportsLogic(deps(), {
      status: "open",
      limit: 50,
      offset: 0,
    });
    expect(items).toHaveLength(2);
    expect(items[0]).toMatchObject({
      reported_name: "Aarav",
      reporter_name: "Neha",
      context: { kind: "reel", caption: "Hi" },
    });
    expect((items[0].context as { videoUrl: string }).videoUrl).toContain(
      `reels/${uid("aarav")}`,
    );

    await adminResolveReportLogic(deps(), {
      reportId: items[1].id,
      resolution: "dismissed",
      note: "Real person",
    });
    expect(
      (
        await adminReportsLogic(deps(), {
          status: "open",
          limit: 50,
          offset: 0,
        })
      ).items,
    ).toHaveLength(1);
    expect(
      (
        await adminReportsLogic(deps(), {
          status: "closed",
          limit: 50,
          offset: 0,
        })
      ).items[0],
    ).toMatchObject({
      resolution: "dismissed",
      resolution_note: "Real person",
    });
  });

  it("removing a reel deletes the video, closes its reports and tells the author", async () => {
    await tokens("aarav", "aarav-phone");
    expect(
      (
        await adminReelsLogic(deps(), {
          reportedOnly: true,
          limit: 50,
          offset: 0,
        })
      ).items,
    ).toEqual([
      expect.objectContaining({ id: reelId, author: "Aarav", reports: 1 }),
    ]);
    await adminDeleteReelLogic(deps(), { reelId, reason: "Nudity" });
    expect(await sql`select 1 from reels`).toHaveLength(0);
    expect(deletedFiles).toEqual([
      ["reels", [`${uid("aarav")}/${reelId}.mp4`]],
    ]);
    expect(
      (
        await sql`select status, resolution from reports where context_type = 'reel'`
      )[0],
    ).toEqual({
      status: "closed",
      resolution: "actioned",
    });
    expect(sentTo("aarav-phone")[0].title).toBe("Your reel was removed");
  });
});

describe("settings and log", () => {
  it("saves valid settings only, and the app and server pick them up", async () => {
    await expectAppError(
      adminSaveConfigLogic(deps(), { overrides: { showSampleProfile: false } }),
      "invalid_input",
    );
    await expectAppError(
      adminSaveConfigLogic(deps(), { overrides: { emergencyNumber: 112 } }),
      "invalid_input",
    );
    await adminSaveConfigLogic(deps(), {
      overrides: {
        environment: "production",
        grievanceOfficerName: "Riya Sharma",
      },
    });
    expect((await adminGetConfigLogic(deps())).overrides).toEqual({
      environment: "production",
      grievanceOfficerName: "Riya Sharma",
    });
    expect((await loadAppConfig(sql)).grievanceOfficerName).toBe("Riya Sharma");
    const log = await adminAuditLogic(deps(), { limit: 50, offset: 0 });
    expect(log.items[0]).toMatchObject({
      action: "settings_save",
      actor: "Riya",
      details: { changed: ["environment", "grievanceOfficerName"] },
    });
  });
});

describe("over HTTP", () => {
  const ctx: ApiContext = {
    sql,
    resolveCaller: async () => null,
    services: (config) => createServices(config, true),
    authAdmin,
    otpSender: () => ({ send: async () => {} }),
    cronSecret: undefined,
    adminSecret: "right-secret",
    adminEmails: ["owner@example.com", "client@example.com"],
    adminPassword: "right-password",
    // The fake Google check: "google:<email>" is a valid token for that email.
    verifyGoogleIdToken: async (token) =>
      token.startsWith("google:")
        ? { email: token.slice(7), name: "Riya Sharma" }
        : null,
    signStorageUrl: async (path) => `https://signed.example/${path}`,
    now: () => NOW,
  };
  const call = (
    action: string,
    body: unknown,
    headers: Record<string, string> = {},
    ip = "10.1.1.1",
  ) =>
    handleApiRequest(
      new Request(`http://localhost/api/${action}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-forwarded-for": ip,
          ...headers,
        },
        body: JSON.stringify(body),
      }),
      ctx,
    );
  const signIn = async (email: string, ip?: string) =>
    call("adminSignIn", { idToken: `google:${email}` }, {}, ip);

  it("lets only the listed Google accounts in", async () => {
    const ok = await signIn("client@example.com");
    expect(ok.status).toBe(200);
    const body = await ok.json();
    expect(body).toMatchObject({
      email: "client@example.com",
      name: "Riya Sharma",
    });
    expect(
      (await call("adminOverview", {}, { "x-admin-session": body.session }))
        .status,
    ).toBe(200);

    const stranger = await signIn("someone@example.com");
    expect(stranger.status).toBe(403);
    expect((await stranger.json()).error.message).toContain(
      "someone@example.com",
    );
    expect(
      (await call("adminSignIn", { idToken: "forged" })).status,
    ).toBe(403);
  });

  it("lets a listed email in with the shared password", async () => {
    const ok = await call("adminSignIn", {
      email: " Client@Example.com ",
      password: "right-password",
    });
    expect(ok.status).toBe(200);
    const body = await ok.json();
    expect(body.email).toBe("client@example.com");
    expect(
      (await call("adminOverview", {}, { "x-admin-session": body.session }))
        .status,
    ).toBe(200);

    for (const attempt of [
      { email: "client@example.com", password: "wrong" },
      { email: "someone@example.com", password: "right-password" },
      { email: "client@example.com", password: "" },
    ]) {
      const refused = await call("adminSignIn", attempt, {}, "10.3.3.3");
      expect(refused.status).toBe(403);
      expect((await refused.json()).error.message).toBe(
        "Wrong email or password.",
      );
    }
  });

  it("has no password sign-in when no password is set", async () => {
    const response = await handleApiRequest(
      new Request("http://localhost/api/adminSignIn", {
        method: "POST",
        body: JSON.stringify({ email: "owner@example.com", password: "" }),
      }),
      { ...ctx, adminPassword: undefined },
    );
    expect(response.status).toBe(412);
  });

  it("refuses calls without a valid session", async () => {
    expect((await call("adminOverview", {})).status).toBe(401);
    expect(
      (await call("adminOverview", {}, { "x-admin-session": "v1.abc.def" }))
        .status,
    ).toBe(401);
    expect(
      (await call("adminOverview", {}, { "x-admin-secret": "right-secret" }))
        .status,
    ).toBe(401);
    const { session } = await (await signIn("owner@example.com")).json();
    const [v, payload, sig] = session.split(".");
    const tampered = `${v}.${payload.slice(0, -2)}AA.${sig}`;
    expect(
      (await call("adminOverview", {}, { "x-admin-session": tampered }))
        .status,
    ).toBe(401);
  });

  it("ends a session when it expires or the email is removed", async () => {
    const { session } = await (await signIn("owner@example.com")).json();
    const later = await handleApiRequest(
      new Request("http://localhost/api/adminOverview", {
        method: "POST",
        headers: { "x-admin-session": session },
        body: "{}",
      }),
      { ...ctx, now: () => new Date(NOW.getTime() + 13 * 3_600_000) },
    );
    expect(later.status).toBe(401);
    const removed = await handleApiRequest(
      new Request("http://localhost/api/adminOverview", {
        method: "POST",
        headers: { "x-admin-session": session },
        body: "{}",
      }),
      { ...ctx, adminEmails: ["client@example.com"] },
    );
    expect(removed.status).toBe(401);
  });

  it("is off when no emails are set", async () => {
    const response = await handleApiRequest(
      new Request("http://localhost/api/adminSignIn", {
        method: "POST",
        body: JSON.stringify({ idToken: "google:owner@example.com" }),
      }),
      { ...ctx, adminEmails: [] },
    );
    expect(response.status).toBe(403);
  });

  it("logs who did it", async () => {
    const { session } = await (await signIn("owner@example.com")).json();
    const response = await call(
      "adminAdjustCredits",
      { uid: uid("aarav"), delta: 1, reason: "Test" },
      { "x-admin-session": session },
    );
    expect(response.status).toBe(200);
    expect((await lastAudit()).actor).toBe("owner@example.com");
  });

  it("locks an address out after 10 refused sign-ins, even for a listed account", async () => {
    for (let i = 0; i < 10; i++)
      expect((await signIn(`guess-${i}@example.com`)).status).toBe(403);
    expect((await signIn("owner@example.com")).status).toBe(429);
    expect((await signIn("owner@example.com", "10.2.2.2")).status).toBe(200);
  });
});
