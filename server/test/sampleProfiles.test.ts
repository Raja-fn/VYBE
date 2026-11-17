import { sampleCompanions } from '../src/domain/sampleProfiles';

const base = { planType: null, venuesNearby: 10, now: new Date('2026-11-16T10:00:00Z'), photoBaseUrl: 'https://x.test/samples' };

describe('sample profiles', () => {
  it("respect the viewer's Show me setting", () => {
    const women = sampleCompanions({ ...base, showMe: 'women' });
    const men = sampleCompanions({ ...base, showMe: 'men' });
    const everyone = sampleCompanions({ ...base, showMe: 'everyone' });
    expect(women.length).toBeGreaterThan(0);
    expect(men.length).toBeGreaterThan(0);
    expect(women.length + men.length).toBe(everyone.length);
    expect(new Set([...women, ...men].map((c) => c.uid)).size).toBe(everyone.length);
  });

  it('never claim more spots than there are nearby', () => {
    for (const c of sampleCompanions({ ...base, showMe: 'everyone', venuesNearby: 2 })) {
      expect(c.spotsNearby).toBeLessThanOrEqual(2);
    }
  });
});
