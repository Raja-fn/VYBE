import { defaultAppConfig } from '../../src/config/appConfig';
import { requestBookingLogic } from '../../src/handlers/booking';
import { markChatReadLogic, sendMessageLogic, startChatLogic } from '../../src/handlers/chat';
import { chatIdFor } from '../../src/handlers/chatCards';
import { discoverCompanionsLogic } from '../../src/handlers/discovery';
import { blockUserLogic, submitReportLogic } from '../../src/handlers/safety';
import { addPerson, addVenue, connect, expectAppError, googleCaller, makeDeps, People, reset } from './helpers';

const NOW = new Date('2026-11-10T10:00:00Z');
const BANDRA = { lat: 19.0596, lng: 72.8295 };

const sql = connect();
let people: People;
let chatId: string;
let clientCounter = 0;

const deps = (config = {}) => makeDeps(sql, { discoverCallsPerMinute: 1000, ...config }, NOW);
const uid = (name: string) => people.uid(name);
const caller = (name: string) => googleCaller(uid(name));

async function member(name: string, gender: string, at: { lat: number; lng: number }, companion = false) {
  await addPerson(sql, {
    uid: uid(name),
    name,
    gender,
    at,
    locatedAt: NOW,
    companion: companion ? { planTypes: ['coffee'], weekly: [{ weekday: 2, start: '16:00', end: '20:00' }] } : undefined,
  });
}

const send = (name: string, text: string, clientId?: string) =>
  sendMessageLogic(deps(), caller(name), { chatId, text, clientId: clientId ?? `client${(clientCounter += 1)}xx` });

const balance = async (name: string) => (await sql<{ balance: number }[]>`select balance from credit_accounts where uid = ${uid(name)}`)[0].balance;
const textMessages = async () => (await sql`select 1 from messages where chat_id = ${chatId} and type = 'text'`).length;

beforeEach(async () => {
  await reset(sql);
  people = new People();
  await member('aarav', 'man', BANDRA);
  await member('kabir', 'man', { lat: 19.061, lng: 72.831 });
  await member('neha', 'woman', { lat: 19.062, lng: 72.833 }, true);
  chatId = chatIdFor(uid('aarav'), uid('neha'));
});

describe('startChat', () => {
  it('opens the chat for 1 credit, once per pair', async () => {
    expect(await startChatLogic(deps(), caller('aarav'), { companionUid: uid('neha') })).toEqual({ chatId, charged: true, balance: 19 });
    expect(await startChatLogic(deps(), caller('aarav'), { companionUid: uid('neha') })).toEqual({ chatId, charged: false, balance: 19 });
    expect(await balance('aarav')).toBe(19);

    const [chat] = await sql`select * from chats where id = ${chatId}`;
    expect(chat).toMatchObject({ participants: [uid('aarav'), uid('neha')].sort(), status: 'open', seeker_uid: uid('aarav'), companion_uid: uid('neha') });
    expect(chat.participant_info[uid('neha')]).toEqual({ displayName: 'neha' });
    const [start] = await sql`select * from messages where chat_id = ${chatId} and id = 'start'`;
    expect(start).toMatchObject({ type: 'system', system_kind: 'chat_started', credits: 1 });
    const [ledger] = await sql`select reason from credit_ledger where id = ${`${chatId}_open`}`;
    expect(ledger.reason).toBe('chat_start');
  });

  it('two taps at the same moment still charge once', async () => {
    await Promise.all([1, 2].map(() => startChatLogic(deps(), caller('aarav'), { companionUid: uid('neha') })));
    expect(await balance('aarav')).toBe(19);
  });

  it('needs a credit', async () => {
    await sql`update credit_accounts set balance = 0 where uid = ${uid('aarav')}`;
    await expectAppError(startChatLogic(deps(), caller('aarav'), { companionUid: uid('neha') }), 'insufficient_credits');
  });

  it('only with someone the seeker can see', async () => {
    await expectAppError(startChatLogic(deps(), caller('aarav'), { companionUid: uid('kabir') }), 'not_found');
  });
});

describe('sendMessage', () => {
  beforeEach(async () => {
    await startChatLogic(deps(), caller('aarav'), { companionUid: uid('neha') });
  });

  it('stores ordinary messages and updates the chat preview and unread count', async () => {
    await send('aarav', '  Hi! Saw you like filter coffee.  ');
    await send('neha', 'Yes! Free this Saturday?');
    await send('aarav', 'Afternoon works for me. 4:00 PM?');
    expect(await textMessages()).toBe(3);
    const [chat] = await sql`select last_message, unread from chats where id = ${chatId}`;
    expect(chat.last_message).toMatchObject({ text: 'Afternoon works for me. 4:00 PM?', senderUid: uid('aarav') });
    expect(chat.unread).toEqual({ [uid('aarav')]: 1, [uid('neha')]: 2 });
  });

  it('a retry with the same client id is not posted twice', async () => {
    await send('aarav', 'Hello', 'sameidxxx1');
    await send('aarav', 'Hello', 'sameidxxx1');
    expect(await textMessages()).toBe(1);
    const [chat] = await sql`select unread from chats where id = ${chatId}`;
    expect(chat.unread[uid('neha')]).toBe(1);
  });

  it('blocks contact details and explicit content before anything is stored', async () => {
    await expectAppError(send('aarav', 'call me 98765 43210'), 'moderation_blocked');
    await expectAppError(send('aarav', 'add me on insta'), 'moderation_blocked');
    await expectAppError(send('aarav', 'something fake-explicit-term'), 'moderation_blocked');
    expect(await textMessages()).toBe(0);
  });

  it('the third blocked attempt files one automatic report', async () => {
    await expectAppError(send('aarav', 'whatsapp me'), 'moderation_blocked');
    await expectAppError(send('aarav', 'neha at gmail dot com'), 'moderation_blocked');
    expect(await sql`select 1 from reports`).toHaveLength(0);
    await expectAppError(send('aarav', 'www.me.com'), 'moderation_blocked');
    await expectAppError(send('aarav', '9876543210'), 'moderation_blocked');
    const reports = await sql`select reported_uid, source, status from reports`;
    expect(reports).toHaveLength(1);
    expect(reports[0]).toEqual({ reported_uid: uid('aarav'), source: 'auto_moderation', status: 'open' });
  });

  it('outsiders and empty or overlong messages are refused', async () => {
    await expectAppError(send('kabir', 'hi'), 'not_found');
    await expectAppError(send('aarav', '   '), 'invalid_input');
    await expectAppError(send('aarav', 'x'.repeat(defaultAppConfig.chatMessageMaxLength + 1)), 'invalid_input');
  });

  it('marking read resets only my unread count', async () => {
    await send('aarav', 'Hello');
    await send('neha', 'Hi');
    await markChatReadLogic(deps(), caller('neha'), { chatId });
    const [chat] = await sql`select unread from chats where id = ${chatId}`;
    expect(chat.unread).toEqual({ [uid('aarav')]: 1, [uid('neha')]: 0 });
  });

  it('a booking between them shows up as a card in the chat', async () => {
    await addVenue(sql, { id: 'cafe', ownerUid: uid('owner'), name: 'Harbour Bean Cafe', at: { lat: 19.0545, lng: 72.834 }, planTypes: ['coffee'] }, [
      { id: '20261110_1700', dayKey: '2026-11-10', startAt: new Date('2026-11-10T17:00:00+05:30'), endAt: new Date('2026-11-10T18:00:00+05:30') },
    ]);
    const { bookingId } = await requestBookingLogic(deps(), caller('aarav'), {
      requestId: 'bookcardxx1',
      companionUid: uid('neha'),
      venueId: 'cafe',
      slotId: '20261110_1700',
      planType: 'coffee',
      kind: 'scheduled',
    });
    const [card] = await sql`select * from messages where chat_id = ${chatId} and id = ${`booking_${bookingId}`}`;
    expect(card).toMatchObject({ type: 'booking_card', booking_id: bookingId, plan_type: 'coffee', venue_name: 'Harbour Bean Cafe' });
    const [chat] = await sql`select unread from chats where id = ${chatId}`;
    expect(chat.unread[uid('neha')]).toBe(1);
  });
});

describe('report and block', () => {
  it('files a user report and rate-limits them', async () => {
    const { reportId } = await submitReportLogic(deps(), caller('aarav'), {
      reportedUid: uid('neha'),
      contextType: 'chat',
      refId: chatId,
      reason: 'harassment',
      details: 'Rude',
    });
    const [report] = await sql`select * from reports where id = ${reportId}`;
    expect(report).toMatchObject({
      reporter_uid: uid('aarav'),
      reported_uid: uid('neha'),
      reason: 'harassment',
      source: 'user',
      status: 'open',
      context_type: 'chat',
      context_ref_id: chatId,
    });
    await expectAppError(
      submitReportLogic(deps({ reportsPerDay: 1 }), caller('aarav'), { reportedUid: uid('neha'), contextType: 'profile', reason: 'other' }),
      'rate_limited',
    );
    await expectAppError(submitReportLogic(deps(), caller('aarav'), { reportedUid: uid('aarav'), contextType: 'profile', reason: 'other' }), 'invalid_input');
  });

  it('blocking closes the chat, cancels open bookings with no refund, and hides both people', async () => {
    await startChatLogic(deps(), caller('aarav'), { companionUid: uid('neha') });
    await addVenue(sql, { id: 'cafe', ownerUid: uid('owner'), name: 'Cafe', at: { lat: 19.0545, lng: 72.834 } }, [
      { id: 's1', dayKey: '2026-11-10', startAt: new Date('2026-11-10T17:00:00+05:30'), endAt: new Date('2026-11-10T18:00:00+05:30'), booked: 1 },
    ]);
    await sql`
      insert into bookings (id, seeker_uid, companion_uid, venue_id, venue_name, venue_category, venue_owner_uid, slot_id,
        day_key, start_at, end_at, plan_type, kind, status, credit_cost, participants)
      values ('b1', ${uid('aarav')}, ${uid('neha')}, 'cafe', 'Cafe', 'cafe', ${uid('owner')}, 's1', '2026-11-10',
        ${new Date('2026-11-10T17:00:00+05:30')}, ${new Date('2026-11-10T18:00:00+05:30')}, 'coffee', 'scheduled', 'requested', 5,
        ${[uid('aarav'), uid('neha')]}::uuid[])`;
    const before = await balance('aarav');

    expect(await blockUserLogic(deps(), caller('neha'), { blockedUid: uid('aarav') })).toEqual({ cancelledBookings: 1 });
    expect((await sql`select status from chats where id = ${chatId}`)[0].status).toBe('closed_blocked');
    expect((await sql`select status, status_reason from bookings where id = 'b1'`)[0]).toEqual({ status: 'cancelled', status_reason: 'blocked' });
    expect((await sql`select booked from venue_slots where id = 's1'`)[0].booked).toBe(0);
    expect(await balance('aarav')).toBe(before);

    await expectAppError(send('aarav', 'hello?'), 'blocked');
    await expectAppError(startChatLogic(deps(), caller('aarav'), { companionUid: uid('neha') }), 'not_found');
    const { companions } = await discoverCompanionsLogic(deps(), caller('aarav'), {});
    expect(companions.map((c) => c.uid)).not.toContain(uid('neha'));
  });

  it('cannot block yourself', async () => {
    await expectAppError(blockUserLogic(deps(), caller('aarav'), { blockedUid: uid('aarav') }), 'invalid_input');
  });
});
