/**
 * Row-level security: what a signed-in app user can read and write directly.
 * Every statement here runs as the `authenticated` role with the person's id
 * in the JWT, exactly like a request from the app.
 */
import type postgres from 'postgres';

import { addPerson, addVenue, asUser, authUser, connect, denied, People, reset } from './helpers';

const sql = connect();
let people: People;
const uid = (name: string) => people.uid(name);

async function setVerified(name: string, verified: boolean) {
  await sql`update users set verification_status = ${verified ? 'approved' : 'pending'} where id = ${uid(name)}`;
}

beforeEach(async () => {
  await reset(sql);
  people = new People();
  for (const name of ['alice', 'bob', 'carol']) await addPerson(sql, { uid: uid(name), name, gender: 'woman' });
  await addVenue(sql, { id: 'v1', ownerUid: uid('vp'), name: 'Cafe', at: { lat: 19, lng: 72 }, verified: false, listed: false }, [
    { id: 's1', dayKey: '2026-11-10', startAt: new Date('2026-11-10T11:30:00Z'), endAt: new Date('2026-11-10T12:30:00Z'), capacity: 3, booked: 2 },
  ]);
  await addVenue(sql, { id: 'v2', ownerUid: uid('other'), name: 'Other', at: { lat: 19, lng: 72 } });
  await sql`insert into credit_ledger (id, uid, delta, balance_after, reason, ref_type, ref_id, idempotency_key)
    values ('l1', ${uid('alice')}, 20, 20, 'signup_bonus', 'user', ${uid('alice')}, 'l1')`;
  await sql`insert into purchases (id, uid, platform, product_id, kind, store_transaction_id, purchase_token, token_hash, status, verified_at)
    values ('android_txn1', ${uid('alice')}, 'android', 'vybe_credits_10', 'consumable', 'txn1', 'secret-token', 'h', 'granted', now())`;
  await sql`insert into otp_challenges (phone, code_hash, salt, sent_at, expires_at) values ('+919800000001', 'h', 's', now(), now())`;
  await sql`insert into rate_limits (key, window_start, count) values (${`${uid('alice')}_discovery`}, now(), 1)`;
  await sql`insert into bookings (id, seeker_uid, companion_uid, venue_id, venue_name, venue_category, venue_owner_uid, slot_id,
      day_key, start_at, end_at, plan_type, kind, status, credit_cost, participants)
    values ('b1', ${uid('alice')}, ${uid('bob')}, 'v1', 'Cafe', 'cafe', ${uid('vp')}, 's1', '2026-11-10', now(), now(),
      'coffee', 'scheduled', 'requested', 5, ${[uid('alice'), uid('bob')]}::uuid[])`;
  const chat = [uid('alice'), uid('bob')].sort().join('_');
  await sql`insert into chats (id, participants, seeker_uid, companion_uid, opened_by)
    values (${chat}, ${[uid('alice'), uid('bob')]}::uuid[], ${uid('alice')}, ${uid('bob')}, ${uid('alice')})`;
  await sql`insert into messages (chat_id, id, sender_uid, type, text) values (${chat}, 'm1', ${uid('bob')}, 'text', 'hi')`;
  await sql`insert into reports (id, reporter_uid, reported_uid, context_type, reason, source)
    values ('00000000-0000-4000-8000-000000000001', ${uid('alice')}, ${uid('bob')}, 'profile', 'other', 'user')`;
  await sql`insert into blocks (blocker_uid, blocked_uid) values (${uid('alice')}, ${uid('bob')})`;
  await sql`insert into user_locations (uid, lat, lng, accuracy_m) values (${uid('bob')}, 19.06, 72.83, 10)`;
  await sql`insert into companion_profiles (uid, plan_types, is_listed) values (${uid('bob')}, '{coffee}', true)`;
});

const chatId = () => [uid('alice'), uid('bob')].sort().join('_');

describe('users and private data', () => {
  it('lets a user read only their own user row', async () => {
    await asUser(sql, uid('alice'), async (tx) => {
      expect(await tx`select id from users`).toEqual([{ id: uid('alice') }]);
      expect(await tx`select 1 from private_profiles where id = ${uid('bob')}`).toHaveLength(0);
    });
    await asUser(sql, null, async (tx) => {
      expect(await denied(tx, (sp) => sp`select * from users`)).toBe(true);
    });
  });

  it('lets a user change their own name, and nobody else', async () => {
    await asUser(sql, uid('alice'), async (tx) => {
      expect(await denied(tx, (sp) => sp`update users set display_name = 'Ali' where id = ${uid('alice')} returning id`)).toBe(false);
      expect(await denied(tx, (sp) => sp`update users set display_name = 'Bobby' where id = ${uid('bob')} returning id`)).toBe(true);
      expect(await denied(tx, (sp) => sp`update users set display_name = ${'x'.repeat(41)} where id = ${uid('alice')} returning id`)).toBe(true);
    });
  });

  it('blocks switching to companion mode until verified', async () => {
    await setVerified('alice', false);
    await asUser(sql, uid('alice'), async (tx) => {
      expect(await denied(tx, (sp) => sp`update users set active_mode = 'companion' where id = ${uid('alice')} returning id`)).toBe(true);
    });
    await setVerified('alice', true);
    await asUser(sql, uid('alice'), async (tx) => {
      expect(await denied(tx, (sp) => sp`update users set active_mode = 'companion' where id = ${uid('alice')} returning id`)).toBe(false);
    });
  });

  it('blocks writing server-owned user fields', async () => {
    await asUser(sql, uid('alice'), async (tx) => {
      expect(await denied(tx, (sp) => sp`update users set verification_status = 'approved' where id = ${uid('alice')} returning id`)).toBe(true);
      expect(await denied(tx, (sp) => sp`update users set account_type = 'venue_partner' where id = ${uid('alice')} returning id`)).toBe(true);
      expect(await denied(tx, (sp) => sp`update users set age_years = 40 where id = ${uid('alice')} returning id`)).toBe(true);
      expect(await denied(tx, (sp) => sp`delete from users where id = ${uid('alice')} returning id`)).toBe(true);
    });
  });

  it('a banned person cannot edit anything', async () => {
    await sql`update users set account_status = 'banned' where id = ${uid('alice')}`;
    await asUser(sql, uid('alice'), async (tx) => {
      expect(await denied(tx, (sp) => sp`update users set display_name = 'Ali' where id = ${uid('alice')} returning id`)).toBe(true);
      expect(await denied(tx, (sp) => sp`update preferences set show_me = 'men' where uid = ${uid('alice')} returning uid`)).toBe(true);
    });
  });

  it('lets a user set only a valid trusted contact', async () => {
    await asUser(sql, uid('alice'), async (tx) => {
      const set = (contact: object) => (sp: typeof tx) =>
        sp`update private_profiles set trusted_contact = ${sp.json(contact as never)} where id = ${uid('alice')} returning id`;
      expect(await denied(tx, set({ name: 'Mom', phoneE164: '+919811111111' }))).toBe(false);
      expect(await denied(tx, set({ name: 'Mom', phoneE164: '98111' }))).toBe(true);
      expect(await denied(tx, (sp) => sp`update private_profiles set phone_e164 = '+910000000000' where id = ${uid('alice')} returning id`)).toBe(true);
    });
  });
});

describe('preferences', () => {
  it('locks gender once verified', async () => {
    await asUser(sql, uid('alice'), async (tx) => {
      expect(await denied(tx, (sp) => sp`update preferences set gender = 'man' where uid = ${uid('alice')} returning uid`)).toBe(true);
      expect(await denied(tx, (sp) => sp`update preferences set show_me = 'men' where uid = ${uid('alice')} returning uid`)).toBe(false);
    });
    await setVerified('alice', false);
    await asUser(sql, uid('alice'), async (tx) => {
      expect(await denied(tx, (sp) => sp`update preferences set gender = 'man' where uid = ${uid('alice')} returning uid`)).toBe(false);
    });
  });

  it('rejects under-18 ranges and unknown values', async () => {
    await asUser(sql, uid('alice'), async (tx) => {
      expect(await denied(tx, (sp) => sp`update preferences set age_min = 16 where uid = ${uid('alice')} returning uid`)).toBe(true);
      expect(await denied(tx, (sp) => sp`update preferences set show_me = 'nobody' where uid = ${uid('alice')} returning uid`)).toBe(true);
      expect(await denied(tx, (sp) => sp`update preferences set age_min = 40, age_max = 30 where uid = ${uid('alice')} returning uid`)).toBe(true);
    });
  });

  it('a new person can create their own preferences, not someone else\'s', async () => {
    const dan = uid('dan');
    await authUser(sql, dan);
    await sql`insert into users (id) values (${dan})`;
    await asUser(sql, dan, async (tx) => {
      const insert = (who: string) => (sp: typeof tx) =>
        sp`insert into preferences (uid, gender, show_me, who_can_request, show_gender, age_min, age_max)
           values (${who}, 'man', 'everyone', 'everyone', false, 21, 35) returning uid`;
      expect(await denied(tx, insert(dan))).toBe(false);
      expect(await denied(tx, insert(uid('carol')))).toBe(true);
    });
  });
});

describe('saves exactly as the app sends them (PostgREST upserts)', () => {
  it('preferences: insert-or-update works for yourself, never for someone else', async () => {
    const upsert = (who: string, showMe: string) => (sp: postgres.TransactionSql) =>
      sp`insert into preferences (uid, gender, show_me, who_can_request, show_gender, age_min, age_max)
         values (${who}, 'woman', ${showMe}, 'everyone', false, 21, 35)
         on conflict (uid) do update set uid = excluded.uid, gender = excluded.gender, show_me = excluded.show_me,
           who_can_request = excluded.who_can_request, show_gender = excluded.show_gender,
           age_min = excluded.age_min, age_max = excluded.age_max
         returning uid`;
    await asUser(sql, uid('alice'), async (tx) => {
      expect(await denied(tx, upsert(uid('alice'), 'men'))).toBe(false);
      expect(await denied(tx, upsert(uid('bob'), 'men'))).toBe(true);
    });
  });

  it('saving a companion twice keeps one save', async () => {
    const save = (sp: postgres.TransactionSql) =>
      sp`insert into saved_companions (uid, companion_uid) values (${uid('alice')}, ${uid('bob')})
         on conflict (uid, companion_uid) do nothing`;
    await asUser(sql, uid('alice'), async (tx) => {
      expect(await denied(tx, save)).toBe(false);
      await tx.savepoint((sp) => save(sp as unknown as postgres.TransactionSql));
      expect(await tx`select 1 from saved_companions`).toHaveLength(1);
    });
  });
});

describe('profile details and photos', () => {
  it('people fill in their own details with values from the fixed lists only', async () => {
    await asUser(sql, uid('alice'), async (tx) => {
      const save = (who: string, extra: string) => (sp: postgres.TransactionSql) =>
        sp.unsafe(
          `insert into profile_details (uid, city, languages, interests, drinking${extra ? ', fitness' : ''})
           values ($1, 'Mumbai', '{english,hindi}', '{music,coffee}', 'socially'${extra ? `, '${extra}'` : ''})
           on conflict (uid) do update set uid = excluded.uid, city = excluded.city returning uid`,
          [who],
        ) as unknown as Promise<postgres.RowList<postgres.Row[]>>;
      expect(await denied(tx, save(uid('alice'), ''))).toBe(false);
      expect(await denied(tx, save(uid('bob'), ''))).toBe(true);
      expect(await denied(tx, save(uid('alice'), 'extreme'))).toBe(true);
      expect(await denied(tx, (sp) => sp`update profile_details set interests = '{knitting}' where uid = ${uid('alice')} returning uid`)).toBe(true);
      expect(await tx`select uid from profile_details`).toEqual([{ uid: uid('alice') }]);
    });
    await asUser(sql, uid('bob'), async (tx) => expect(await tx`select uid from profile_details`).toHaveLength(0));
  });

  it('profile photos must be your own uploads', async () => {
    await asUser(sql, uid('alice'), async (tx) => {
      const set = (path: string) => (sp: postgres.TransactionSql) =>
        sp`update users set photo_paths = ${[path]} where id = ${uid('alice')} returning id`;
      expect(await denied(tx, set(`photos/${uid('alice')}/1.jpg`))).toBe(false);
      expect(await denied(tx, set(`photos/${uid('bob')}/1.jpg`))).toBe(true);
      expect(await denied(tx, set(`verification/${uid('alice')}/selfie.jpg`))).toBe(true);
    });
  });

  it('unverified people can see their own photos while editing', async () => {
    await sql`insert into storage.objects (bucket_id, name) values ('photos', ${`${uid('alice')}/p.jpg`}), ('photos', ${`${uid('bob')}/p.jpg`})`;
    await setVerified('alice', false);
    await asUser(sql, uid('alice'), async (tx) => {
      expect(await tx`select name from storage.objects`).toEqual([{ name: `${uid('alice')}/p.jpg` }]);
      expect(await denied(tx, (sp) => sp`insert into storage.objects (bucket_id, name) values ('photos', ${`${uid('alice')}/2.jpg`})`)).toBe(false);
    });
  });
});

describe('server-only data', () => {
  it('never lets a client change a credit balance or ledger', async () => {
    await asUser(sql, uid('alice'), async (tx) => {
      expect(await tx`select balance from credit_accounts`).toEqual([{ balance: 20 }]);
      expect(await denied(tx, (sp) => sp`update credit_accounts set balance = 9999 where uid = ${uid('alice')} returning uid`)).toBe(true);
      expect(await denied(tx, (sp) => sp`insert into credit_ledger (id, uid, delta, balance_after, reason, ref_type, ref_id, idempotency_key)
        values ('forged', ${uid('alice')}, 100, 120, 'x', 'x', 'x', 'forged') returning id`)).toBe(true);
    });
  });

  it('lets people read only their own plan, and never change it', async () => {
    await asUser(sql, uid('bob'), async (tx) => {
      expect(await tx`select uid from subscriptions`).toEqual([{ uid: uid('bob') }]);
      expect(await denied(tx, (sp) => sp`update subscriptions set tier = 'premium' where uid = ${uid('bob')} returning uid`)).toBe(true);
    });
  });

  it('keeps purchase records (and their store receipts), login codes, rate limits and the companion index server-only', async () => {
    for (const who of [uid('alice'), uid('bob'), null]) {
      await asUser(sql, who, async (tx) => {
        for (const table of ['purchases', 'otp_challenges', 'rate_limits', 'companion_index', 'phone_logins', 'moderation_strikes']) {
          expect(await denied(tx, (sp) => sp`select * from ${sp(table)}`)).toBe(true);
        }
      });
    }
  });

  it('only shows people their own ledger entries and exact location', async () => {
    await asUser(sql, uid('bob'), async (tx) => {
      expect(await tx`select id from credit_ledger`).toHaveLength(0);
      expect(await tx`select uid from user_locations`).toEqual([{ uid: uid('bob') }]);
    });
    await asUser(sql, uid('alice'), async (tx) => {
      expect(await tx`select uid from user_locations`).toHaveLength(0);
    });
  });

  it('only lets participants and the venue owner read a booking, and nobody write it', async () => {
    for (const [who, sees] of [['bob', 1], ['vp', 1], ['carol', 0]] as const) {
      await asUser(sql, uid(who), async (tx) => expect(await tx`select id from bookings`).toHaveLength(sees));
    }
    await asUser(sql, uid('alice'), async (tx) => {
      expect(await denied(tx, (sp) => sp`update bookings set status = 'completed' where id = 'b1' returning id`)).toBe(true);
    });
  });

  it('never lets a client write a chat or a message directly', async () => {
    await asUser(sql, uid('alice'), async (tx) => {
      expect(await tx`select id from chats`).toHaveLength(1);
      expect(await denied(tx, (sp) => sp`insert into messages (chat_id, id, sender_uid, type, text)
        values (${chatId()}, 'x', ${uid('alice')}, 'text', 'call me 9800000000') returning id`)).toBe(true);
      expect(await denied(tx, (sp) => sp`update chats set status = 'open' where id = ${chatId()} returning id`)).toBe(true);
    });
    await setVerified('alice', false);
    await asUser(sql, uid('alice'), async (tx) => expect(await tx`select id from chats`).toHaveLength(0));
  });
});

describe('venues', () => {
  it('blocks listing an unverified venue', async () => {
    await asUser(sql, uid('vp'), async (tx) => {
      expect(await denied(tx, (sp) => sp`update venues set is_listed = true where id = 'v1' returning id`)).toBe(true);
      expect(await denied(tx, (sp) => sp`update venues set perk = ${sp.json({ text: 'Free tea' })} where id = 'v1' returning id`)).toBe(false);
    });
  });

  it('blocks non-owners and protected fields', async () => {
    await asUser(sql, uid('other'), async (tx) => {
      expect(await denied(tx, (sp) => sp`update venues set perk = ${sp.json({ text: 'x' })} where id = 'v1' returning id`)).toBe(true);
    });
    await asUser(sql, uid('vp'), async (tx) => {
      expect(await denied(tx, (sp) => sp`update venues set verification_status = 'verified' where id = 'v1' returning id`)).toBe(true);
    });
  });

  it('never lets capacity drop below what is booked', async () => {
    await asUser(sql, uid('vp'), async (tx) => {
      expect(await denied(tx, (sp) => sp`update venue_slots set capacity = 1 where id = 's1' returning id`)).toBe(true);
      expect(await denied(tx, (sp) => sp`update venue_slots set capacity = 2 where id = 's1' returning id`)).toBe(false);
      expect(await denied(tx, (sp) => sp`update venue_slots set booked = 0 where id = 's1' returning id`)).toBe(true);
    });
  });

  it('seekers never read venues or slots directly', async () => {
    await asUser(sql, uid('alice'), async (tx) => {
      expect(await tx`select id from venues`).toHaveLength(0);
      expect(await tx`select id from venue_slots`).toHaveLength(0);
    });
  });
});

describe('saved companions', () => {
  it('lets a verified user save and unsave for themselves only', async () => {
    await asUser(sql, uid('alice'), async (tx) => {
      expect(await denied(tx, (sp) => sp`insert into saved_companions (uid, companion_uid) values (${uid('alice')}, ${uid('bob')}) returning uid`)).toBe(false);
      expect(await tx`select companion_uid from saved_companions`).toEqual([{ companion_uid: uid('bob') }]);
      expect(await denied(tx, (sp) => sp`delete from saved_companions where companion_uid = ${uid('bob')} returning uid`)).toBe(false);
      expect(await denied(tx, (sp) => sp`insert into saved_companions (uid, companion_uid) values (${uid('bob')}, ${uid('alice')}) returning uid`)).toBe(true);
    });
  });

  it('needs verification, a server timestamp and not yourself', async () => {
    await asUser(sql, uid('alice'), async (tx) => {
      expect(await denied(tx, (sp) => sp`insert into saved_companions (uid, companion_uid, saved_at)
        values (${uid('alice')}, ${uid('bob')}, ${new Date(0)}) returning uid`)).toBe(true);
      expect(await denied(tx, (sp) => sp`insert into saved_companions (uid, companion_uid) values (${uid('alice')}, ${uid('alice')}) returning uid`)).toBe(true);
    });
    await setVerified('alice', false);
    await asUser(sql, uid('alice'), async (tx) => {
      expect(await denied(tx, (sp) => sp`insert into saved_companions (uid, companion_uid) values (${uid('alice')}, ${uid('bob')}) returning uid`)).toBe(true);
    });
  });
});

describe('chat, reports and blocks', () => {
  it('only verified participants read messages', async () => {
    await asUser(sql, uid('bob'), async (tx) => expect(await tx`select id from messages`).toHaveLength(1));
    await asUser(sql, uid('carol'), async (tx) => expect(await tx`select id from messages`).toHaveLength(0));
    await setVerified('bob', false);
    await asUser(sql, uid('bob'), async (tx) => expect(await tx`select id from messages`).toHaveLength(0));
  });

  it('nobody writes messages, reports or blocks directly', async () => {
    await asUser(sql, uid('alice'), async (tx) => {
      expect(await denied(tx, (sp) => sp`update messages set text = 'edited' where id = 'm1' returning id`)).toBe(true);
      expect(await denied(tx, (sp) => sp`insert into reports (reporter_uid, reported_uid, context_type, reason, source)
        values (${uid('alice')}, ${uid('bob')}, 'profile', 'other', 'user') returning id`)).toBe(true);
      expect(await denied(tx, (sp) => sp`delete from blocks where blocker_uid = ${uid('alice')} returning blocker_uid`)).toBe(true);
    });
  });

  it('people see only their own reports and blocks', async () => {
    await asUser(sql, uid('alice'), async (tx) => {
      expect(await tx`select id from reports`).toHaveLength(1);
      expect(await tx`select blocked_uid from blocks`).toHaveLength(1);
    });
    await asUser(sql, uid('bob'), async (tx) => {
      expect(await tx`select id from reports`).toHaveLength(0);
      expect(await tx`select blocked_uid from blocks`).toHaveLength(0);
    });
  });
});

describe('app settings and file storage', () => {
  it('everyone reads the app settings; nobody changes them from the app', async () => {
    for (const who of [uid('alice'), null]) {
      await asUser(sql, who, async (tx) => {
        expect(await tx`select overrides from app_config`).toHaveLength(1);
        expect(await denied(tx, (sp) => sp`update app_config set overrides = '{"creditCostBookSpot":0}' returning id`)).toBe(true);
      });
    }
  });

  it('verification photos go only into your own folder and are never readable', async () => {
    await asUser(sql, uid('alice'), async (tx) => {
      expect(await denied(tx, (sp) => sp`insert into storage.objects (bucket_id, name) values ('verification', ${`${uid('alice')}/s.jpg`})`)).toBe(false);
      expect(await denied(tx, (sp) => sp`insert into storage.objects (bucket_id, name) values ('verification', ${`${uid('bob')}/s.jpg`})`)).toBe(true);
      expect(await tx`select name from storage.objects where bucket_id = 'verification'`).toHaveLength(0);
    });
  });

  it('profile photos are visible to verified people only', async () => {
    await sql`insert into storage.objects (bucket_id, name) values ('photos', ${`${uid('bob')}/p.jpg`})`;
    await asUser(sql, uid('alice'), async (tx) => expect(await tx`select name from storage.objects`).toHaveLength(1));
    await setVerified('alice', false);
    await asUser(sql, uid('alice'), async (tx) => expect(await tx`select name from storage.objects`).toHaveLength(0));
  });
});
