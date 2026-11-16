import { defaultAppConfig } from '../src/config/appConfig';
import { distanceKm } from '../src/domain/geo';
import { ageOn, members, venues } from '../seed/fixtures';

const center = defaultAppConfig.launchCity;
const radius = defaultAppConfig.discoveryRadiusKm;
const FAR = new Set(['c_far', 'v_lakeview']);

describe('seed fixtures', () => {
  it('uses unique ids and phone numbers', () => {
    const uids = [...members.map((m) => m.uid), ...venues.map((v) => v.ownerUid)];
    const phones = [...members.map((m) => m.phoneE164), ...venues.map((v) => v.ownerPhoneE164)];
    expect(new Set(uids).size).toBe(uids.length);
    expect(new Set(phones).size).toBe(phones.length);
    expect(new Set(venues.map((v) => v.venueId)).size).toBe(venues.length);
  });

  it('keeps everyone inside the radius except the deliberate far-away cases', () => {
    for (const m of members) {
      const inside = distanceKm(center, m.location) <= radius;
      expect([m.uid, inside]).toEqual([m.uid, !FAR.has(m.uid)]);
    }
    for (const v of venues) {
      const inside = distanceKm(center, v) <= radius;
      expect([v.venueId, inside]).toEqual([v.venueId, !FAR.has(v.venueId)]);
    }
  });

  it('covers every gender and every matching setting', () => {
    const companions = members.filter((m) => m.companion);
    const seekers = members.filter((m) => !m.companion);
    expect(new Set(companions.map((m) => m.gender))).toEqual(new Set(['woman', 'man', 'non_binary', 'undisclosed']));
    expect(new Set(companions.map((m) => m.whoCanRequest))).toEqual(new Set(['everyone', 'women', 'men']));
    expect(new Set(seekers.map((m) => m.gender))).toEqual(new Set(['woman', 'man', 'non_binary', 'undisclosed']));
    expect(new Set(seekers.map((m) => m.showMe))).toEqual(new Set(['women', 'men', 'everyone']));
  });

  it('only seeds adults', () => {
    const now = new Date('2026-11-10T00:00:00Z');
    expect(members.every((m) => ageOn(m.dateOfBirth, now) >= defaultAppConfig.ageMinimum)).toBe(true);
  });

  it('includes the edge-case accounts', () => {
    expect(members.find((m) => m.uid === 'u_unverified')?.verification).toBe('pending');
    expect(members.find((m) => m.uid === 'u_banned')?.banned).toBe(true);
    expect(members.find((m) => m.uid === 'u_rejected')?.verification).toBe('rejected');
    expect(venues.find((v) => v.venueId === 'v_corner_tea')).toMatchObject({ verificationStatus: 'pending', isListed: false });
  });

  it('never lists an unverified venue', () => {
    expect(venues.every((v) => !v.isListed || v.verificationStatus === 'verified')).toBe(true);
  });
});

describe('ageOn', () => {
  it('counts a birthday only once it has passed', () => {
    expect(ageOn('2000-11-10', new Date('2026-11-10T00:00:00Z'))).toBe(26);
    expect(ageOn('2000-11-11', new Date('2026-11-10T00:00:00Z'))).toBe(25);
  });
});
