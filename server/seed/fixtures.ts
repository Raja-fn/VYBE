/**
 * Emulator seed data for Mumbai (Bandra / Khar / Santacruz).
 * Every person and venue here is fictional.
 *
 * Coverage, so each matching rule can be tried by hand:
 *  - companions of every gender and every "Who can request you" setting
 *  - seekers of every gender and every "Show me" setting
 *  - one companion and one venue just outside the 5 km radius
 *  - an unverified user, a banned user, a rejected-verification user
 *  - a venue still pending verification
 */
import type { SlotTemplate } from '../src/domain/slots';

export type Gender = 'woman' | 'man' | 'non_binary' | 'undisclosed';
export type ShowMe = 'women' | 'men' | 'everyone';
export type WhoCanRequest = 'everyone' | 'women' | 'men';
export type PlanType = 'coffee' | 'movie' | 'event' | 'walk' | 'dinner';

export interface SeedMember {
  uid: string;
  displayName: string;
  phoneE164: string;
  gender: Gender;
  dateOfBirth: string;
  showMe: ShowMe;
  ageMin: number;
  ageMax: number;
  showGender: boolean;
  whoCanRequest: WhoCanRequest;
  verification: 'approved' | 'pending' | 'rejected';
  banned: boolean;
  location: { lat: number; lng: number };
  companion?: {
    about: string;
    activityTags: string[];
    planTypes: PlanType[];
    prompt: { promptId: string; answer: string };
    /** Hours from seed time the companion stays "Free now"; null = not free now. */
    freeNowHours: number | null;
  };
}

export interface SeedVenue {
  venueId: string;
  ownerUid: string;
  ownerPhoneE164: string;
  businessName: string;
  name: string;
  category: 'cafe' | 'food_court' | 'open_park' | 'cinema' | 'restaurant';
  addressLine: string;
  lat: number;
  lng: number;
  planTypes: PlanType[];
  verificationStatus: 'verified' | 'pending';
  isListed: boolean;
  perk: string;
  slotTemplate: SlotTemplate;
}

const everyDay = (open: string, close: string) =>
  [1, 2, 3, 4, 5, 6, 7].map((weekday) => ({ weekday, open, close }));

const companion = (overrides: Partial<SeedMember> & Pick<SeedMember, 'uid' | 'displayName' | 'phoneE164' | 'gender' | 'dateOfBirth' | 'location' | 'companion'>): SeedMember => ({
  showMe: 'everyone',
  ageMin: 21,
  ageMax: 35,
  showGender: false,
  whoCanRequest: 'everyone',
  verification: 'approved',
  banned: false,
  ...overrides,
});

const seeker = (overrides: Partial<SeedMember> & Pick<SeedMember, 'uid' | 'displayName' | 'phoneE164' | 'gender' | 'dateOfBirth' | 'showMe' | 'location'>): SeedMember => ({
  ageMin: 21,
  ageMax: 35,
  showGender: false,
  whoCanRequest: 'everyone',
  verification: 'approved',
  banned: false,
  ...overrides,
});

export const members: SeedMember[] = [
  // ---- Companions (inside 5 km of Bandra) ----
  companion({
    uid: 'c_neha', displayName: 'Neha', phoneE164: '+919800000101', gender: 'woman', dateOfBirth: '2002-03-14',
    location: { lat: 19.0612, lng: 72.8331 },
    companion: {
      about: 'Product designer who loves filter coffee and long sea-face walks. Speaks English, Hindi and Marathi.',
      activityTags: ['coffee', 'movie', 'event'], planTypes: ['coffee', 'walk', 'movie'],
      prompt: { promptId: 'ideal_sunday', answer: 'Filter coffee, a used-book stall and a sunset walk.' },
      freeNowHours: 2,
    },
  }),
  companion({
    uid: 'c_arjun', displayName: 'Arjun', phoneE164: '+919800000102', gender: 'man', dateOfBirth: '1999-07-02',
    whoCanRequest: 'women', location: { lat: 19.0716, lng: 72.8365 },
    companion: {
      about: 'Film buff and weekend quizzer. Happy to find you the best cutting chai nearby.',
      activityTags: ['movie', 'event'], planTypes: ['movie', 'event', 'dinner'],
      prompt: { promptId: 'ideal_sunday', answer: 'A morning show and a long lunch after.' },
      freeNowHours: 4,
    },
  }),
  companion({
    uid: 'c_sam', displayName: 'Sam', phoneE164: '+919800000103', gender: 'non_binary', dateOfBirth: '2000-11-21',
    location: { lat: 19.0815, lng: 72.8391 },
    companion: {
      about: 'Illustrator, gig-goer and dinner-spot hunter.',
      activityTags: ['event', 'dinner'], planTypes: ['event', 'dinner', 'coffee'],
      prompt: { promptId: 'ideal_sunday', answer: 'Sketching at a cafe, then an open-mic.' },
      freeNowHours: null,
    },
  }),
  companion({
    uid: 'c_riya', displayName: 'Riya', phoneE164: '+919800000104', gender: 'woman', dateOfBirth: '2003-01-09',
    whoCanRequest: 'women', location: { lat: 19.0553, lng: 72.8268 },
    companion: {
      about: 'Student and runner. Prefers morning walks and quiet cafes.',
      activityTags: ['walk', 'coffee'], planTypes: ['walk', 'coffee'],
      prompt: { promptId: 'ideal_sunday', answer: 'A 5 km run and a big breakfast.' },
      freeNowHours: 1,
    },
  }),
  companion({
    uid: 'c_kabir', displayName: 'Kabir', phoneE164: '+919800000105', gender: 'man', dateOfBirth: '1997-05-30',
    location: { lat: 19.0652, lng: 72.8412 },
    companion: {
      about: 'Chef on weekdays, food-walk guide on weekends.',
      activityTags: ['dinner', 'walk'], planTypes: ['dinner', 'walk'],
      prompt: { promptId: 'ideal_sunday', answer: 'Trying three street-food stalls before noon.' },
      freeNowHours: null,
    },
  }),
  companion({
    uid: 'c_ira', displayName: 'Ira', phoneE164: '+919800000106', gender: 'undisclosed', dateOfBirth: '2001-09-17',
    location: { lat: 19.0478, lng: 72.8352 },
    companion: {
      about: 'Bookshop regular and board-game host.',
      activityTags: ['coffee', 'event'], planTypes: ['coffee', 'event'],
      prompt: { promptId: 'ideal_sunday', answer: 'Board games and a pot of tea.' },
      freeNowHours: 3,
    },
  }),
  companion({
    uid: 'c_dev', displayName: 'Dev', phoneE164: '+919800000107', gender: 'man', dateOfBirth: '1995-12-04',
    whoCanRequest: 'men', location: { lat: 19.0748, lng: 72.8297 },
    companion: {
      about: 'Cricket fan and casual photographer.',
      activityTags: ['walk', 'movie'], planTypes: ['walk', 'movie'],
      prompt: { promptId: 'ideal_sunday', answer: 'Photo walk along the promenade.' },
      freeNowHours: null,
    },
  }),
  // ---- Companion outside 5 km (Powai, ~9 km away) ----
  companion({
    uid: 'c_far', displayName: 'Meera', phoneE164: '+919800000108', gender: 'woman', dateOfBirth: '1998-04-22',
    location: { lat: 19.1176, lng: 72.906 },
    companion: {
      about: 'Lakeside walker. Should never appear for Bandra seekers.',
      activityTags: ['walk'], planTypes: ['walk', 'coffee'],
      prompt: { promptId: 'ideal_sunday', answer: 'A lake walk at sunrise.' },
      freeNowHours: 2,
    },
  }),

  // ---- Seekers ----
  seeker({ uid: 's_aarav', displayName: 'Aarav', phoneE164: '+919800000201', gender: 'man', dateOfBirth: '1998-02-11', showMe: 'everyone', location: { lat: 19.0596, lng: 72.8295 } }),
  seeker({ uid: 's_diya', displayName: 'Diya', phoneE164: '+919800000202', gender: 'woman', dateOfBirth: '2000-06-18', showMe: 'men', location: { lat: 19.0640, lng: 72.8350 } }),
  seeker({ uid: 's_alex', displayName: 'Alex', phoneE164: '+919800000203', gender: 'non_binary', dateOfBirth: '1999-10-05', showMe: 'everyone', location: { lat: 19.0700, lng: 72.8320 } }),
  seeker({ uid: 's_kiran', displayName: 'Kiran', phoneE164: '+919800000204', gender: 'undisclosed', dateOfBirth: '2001-12-25', showMe: 'women', location: { lat: 19.0560, lng: 72.8330 } }),

  // ---- Edge-case accounts ----
  seeker({ uid: 'u_unverified', displayName: 'Tara', phoneE164: '+919800000301', gender: 'woman', dateOfBirth: '2002-08-08', showMe: 'everyone', verification: 'pending', location: { lat: 19.0600, lng: 72.8300 } }),
  seeker({ uid: 'u_banned', displayName: 'Rohan', phoneE164: '+919800000302', gender: 'man', dateOfBirth: '1996-03-03', showMe: 'everyone', banned: true, location: { lat: 19.0610, lng: 72.8310 } }),
  seeker({ uid: 'u_rejected', displayName: 'Nikhil', phoneE164: '+919800000303', gender: 'man', dateOfBirth: '1997-01-01', showMe: 'everyone', verification: 'rejected', location: { lat: 19.0620, lng: 72.8320 } }),
];

export const venues: SeedVenue[] = [
  {
    venueId: 'v_harbour_bean', ownerUid: 'vp_harbour_bean', ownerPhoneE164: '+919800000401',
    businessName: 'Harbour Bean Cafe LLP', name: 'Harbour Bean Cafe', category: 'cafe',
    addressLine: 'Hill Road, Bandra West, Mumbai 400050', lat: 19.0545, lng: 72.8340,
    planTypes: ['coffee'], verificationStatus: 'verified', isListed: true,
    perk: '10% off any coffee for FindX meetups',
    slotTemplate: { slotMinutes: 60, tablesPerSlot: 3, openingHours: everyDay('09:00', '22:00') },
  },
  {
    venueId: 'v_palm_grove', ownerUid: 'vp_palm_grove', ownerPhoneE164: '+919800000402',
    businessName: 'Palm Grove Retail Pvt Ltd', name: 'Palm Grove Mall Food Court', category: 'food_court',
    addressLine: 'Linking Road, Khar West, Mumbai 400052', lat: 19.0705, lng: 72.8345,
    planTypes: ['coffee', 'dinner'], verificationStatus: 'verified', isListed: true,
    perk: 'Free dessert with two mains',
    slotTemplate: { slotMinutes: 60, tablesPerSlot: 4, openingHours: everyDay('11:00', '23:00') },
  },
  {
    venueId: 'v_seaface_garden', ownerUid: 'vp_seaface_garden', ownerPhoneE164: '+919800000403',
    businessName: 'Seaface Garden Trust', name: 'Seaface Garden', category: 'open_park',
    addressLine: 'Promenade, Bandra West, Mumbai 400050', lat: 19.0650, lng: 72.8230,
    planTypes: ['walk'], verificationStatus: 'verified', isListed: true,
    perk: 'Staffed help desk at the main gate',
    slotTemplate: { slotMinutes: 60, tablesPerSlot: 6, openingHours: everyDay('06:00', '20:00') },
  },
  {
    venueId: 'v_reel_house', ownerUid: 'vp_reel_house', ownerPhoneE164: '+919800000404',
    businessName: 'Reel House Cinemas', name: 'Reel House Cinema', category: 'cinema',
    addressLine: 'SV Road, Santacruz West, Mumbai 400054', lat: 19.0810, lng: 72.8400,
    planTypes: ['movie', 'event'], verificationStatus: 'verified', isListed: true,
    perk: 'Priority seating for FindX bookings',
    slotTemplate: {
      slotMinutes: 120, tablesPerSlot: 2,
      openingHours: [1, 2, 3, 4, 5, 6, 7].map((weekday) => ({ weekday, open: '12:00', close: '24:00' })),
    },
  },
  {
    venueId: 'v_lantern', ownerUid: 'vp_lantern', ownerPhoneE164: '+919800000405',
    businessName: 'Lantern Hospitality', name: 'Lantern Dinner House', category: 'restaurant',
    addressLine: 'Carter Lane, Bandra West, Mumbai 400050', lat: 19.0580, lng: 72.8270,
    planTypes: ['dinner'], verificationStatus: 'verified', isListed: true,
    perk: 'Complimentary mocktail',
    slotTemplate: { slotMinutes: 90, tablesPerSlot: 3, openingHours: everyDay('18:00', '23:00') },
  },
  // Pending verification: must never be listed or bookable.
  {
    venueId: 'v_corner_tea', ownerUid: 'vp_corner_tea', ownerPhoneE164: '+919800000406',
    businessName: 'Corner Tea Co', name: 'Corner Tea House', category: 'cafe',
    addressLine: 'Pali Hill, Bandra West, Mumbai 400050', lat: 19.0670, lng: 72.8280,
    planTypes: ['coffee'], verificationStatus: 'pending', isListed: false,
    perk: 'Free refill',
    slotTemplate: { slotMinutes: 60, tablesPerSlot: 2, openingHours: everyDay('08:00', '20:00') },
  },
  // Outside 5 km (Powai).
  {
    venueId: 'v_lakeview', ownerUid: 'vp_lakeview', ownerPhoneE164: '+919800000407',
    businessName: 'Lakeview Cafe', name: 'Lakeview Cafe', category: 'cafe',
    addressLine: 'Hiranandani, Powai, Mumbai 400076', lat: 19.1190, lng: 72.9070,
    planTypes: ['coffee'], verificationStatus: 'verified', isListed: true,
    perk: 'Lake-view table on request',
    slotTemplate: { slotMinutes: 60, tablesPerSlot: 3, openingHours: everyDay('09:00', '21:00') },
  },
];

/** Weekly availability every seeded companion gets. */
export const defaultWeeklyAvailability = [1, 2, 3, 4, 5, 6, 7].map((weekday) => ({
  weekday,
  start: weekday >= 6 ? '11:00' : '16:00',
  end: weekday >= 6 ? '21:00' : '20:00',
}));

export { ageOn } from '../src/domain/verification';
