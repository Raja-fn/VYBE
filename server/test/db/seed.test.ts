import { discoverCompanionsLogic } from '../../src/handlers/discovery';
import { seedUid } from '../../src/services/seedIds';
import { seedAccounts, seedDatabase, testEmail } from '../../seed/seed';
import { authUser, connect, googleCaller, makeDeps, reset } from './helpers';

const sql = connect();
const NOW = new Date('2026-11-10T10:00:00Z');

beforeEach(async () => {
  await reset(sql);
  for (const account of seedAccounts()) await authUser(sql, account.uid, account.email);
});

describe('seed data', () => {
  it('fills the test project and can run again without duplicates or lost spending', async () => {
    const first = await seedDatabase(sql, NOW);
    expect(first.slots).toBeGreaterThan(100);
    await sql`update credit_accounts set balance = 3 where uid = ${seedUid('s_aarav')}`;
    await seedDatabase(sql, NOW);

    const [counts] = await sql`
      select (select count(*)::int from users) as users, (select count(*)::int from venues) as venues,
        (select count(*)::int from companion_index) as indexed`;
    expect(counts).toEqual({ users: 22, venues: 7, indexed: 8 });
    expect((await sql`select balance from credit_accounts where uid = ${seedUid('s_aarav')}`)[0].balance).toBe(3);
  });

  it('Aarav (aarav@findx.test) sees nearby companions straight away', async () => {
    await seedDatabase(sql, NOW);
    expect(testEmail('Aarav')).toBe('aarav@findx.test');
    const { companions } = await discoverCompanionsLogic(makeDeps(sql, {}, NOW), googleCaller(seedUid('s_aarav')), {});
    expect(companions.length).toBeGreaterThanOrEqual(3);
    expect(companions.map((c) => c.displayName)).not.toContain('Meera'); // outside 5 km
  });

  it('gives every seeded person a stable, valid id', () => {
    expect(seedUid('s_aarav')).toBe(seedUid('s_aarav'));
    expect(seedUid('s_aarav')).toMatch(/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/);
  });
});
