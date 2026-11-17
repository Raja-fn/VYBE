/**
 * Sample profiles, so Discover is not empty while VYBE has few members.
 *
 * They are made up, never stored, and always marked `isSample` so the app
 * shows a "Sample" badge and turns off Message, Save and booking for them.
 * The server adds them only while `showSampleProfiles` is on in AppConfig;
 * turn it off before the public launch (launch checklist).
 *
 * Photos are abstract illustrations hosted with the website (site/samples/),
 * never pictures of real people.
 */
import type { Gender, ShowMe } from './matching';
import { showMeIncludes } from './matching';

export interface SampleProfile {
  uid: string;
  displayName: string;
  ageYears: number;
  gender: Gender;
  about: string;
  planTypes: string[];
  prompt: string;
  interests: string[];
  personality: string[];
  languages: string[];
  profession: string;
  distanceKm: number;
  freeNow: boolean;
}

export const SAMPLE_UID_PREFIX = 'sample_';

const people: SampleProfile[] = [
  {
    uid: 'ananya', displayName: 'Ananya', ageYears: 24, gender: 'woman',
    about: 'Weekend café hopper and slow-morning person. Always up for a good book recommendation.',
    planTypes: ['coffee', 'walk', 'event'], prompt: 'A long breakfast, a used bookshop and an evening walk by the river.',
    interests: ['coffee', 'books', 'photography', 'nature'], personality: ['calm', 'curious'],
    languages: ['english', 'hindi'], profession: 'UX designer', distanceKm: 1, freeNow: true,
  },
  {
    uid: 'rohan', displayName: 'Rohan', ageYears: 27, gender: 'man',
    about: 'Film buff who will happily debate the ending of any movie. Trying every biryani in town.',
    planTypes: ['movie', 'dinner', 'coffee'], prompt: 'A morning cricket match, then a double feature at the cinema.',
    interests: ['movies', 'food', 'cricket', 'music'], personality: ['witty', 'easygoing'],
    languages: ['english', 'hindi'], profession: 'Software engineer', distanceKm: 2, freeNow: false,
  },
  {
    uid: 'meera', displayName: 'Meera', ageYears: 26, gender: 'woman',
    about: 'Trained in Kathak, now mostly dancing in my kitchen. Looking for people to try new places with.',
    planTypes: ['event', 'dinner', 'walk'], prompt: 'Street food in the old city and a dance workshop in the evening.',
    interests: ['dance', 'food', 'travel', 'art'], personality: ['cheerful', 'adventurous'],
    languages: ['english', 'hindi'], profession: 'Teacher', distanceKm: 3, freeNow: true,
  },
  {
    uid: 'kabir', displayName: 'Kabir', ageYears: 29, gender: 'man',
    about: 'Runner, amateur photographer, and the friend who knows a quiet café in every neighbourhood.',
    planTypes: ['walk', 'coffee'], prompt: 'A 10K at sunrise, then filter coffee and a photo walk.',
    interests: ['fitness', 'photography', 'coffee', 'nature'], personality: ['thoughtful', 'ambitious'],
    languages: ['english', 'hindi'], profession: 'Architect', distanceKm: 2, freeNow: false,
  },
  {
    uid: 'sara', displayName: 'Sara', ageYears: 23, gender: 'woman',
    about: 'New to the city and keen to find the best momos, open-mic nights and board-game cafés.',
    planTypes: ['coffee', 'event', 'movie'], prompt: 'Board games, too much chai and an open-mic night.',
    interests: ['gaming', 'music', 'theatre', 'coffee'], personality: ['curious', 'cheerful'],
    languages: ['english'], profession: 'Content writer', distanceKm: 4, freeNow: true,
  },
  {
    uid: 'arjun', displayName: 'Arjun', ageYears: 31, gender: 'man',
    about: 'Home cook and weekend trekker. Happiest in a good conversation over dinner.',
    planTypes: ['dinner', 'walk', 'coffee'], prompt: 'Cooking a big lunch for friends, then a sunset hike.',
    interests: ['cooking', 'travel', 'nature', 'books'], personality: ['easygoing', 'thoughtful'],
    languages: ['english', 'hindi'], profession: 'Product manager', distanceKm: 5, freeNow: false,
  },
  {
    uid: 'ishita', displayName: 'Ishita', ageYears: 28, gender: 'woman',
    about: 'Gallery regular, thrift-store fan and a big believer in trying the weird item on the menu.',
    planTypes: ['event', 'coffee', 'dinner'], prompt: 'A new exhibition, a thrift haul and dinner somewhere new.',
    interests: ['art', 'fashion', 'food', 'photography'], personality: ['adventurous', 'witty'],
    languages: ['english', 'hindi'], profession: 'Illustrator', distanceKm: 3, freeNow: false,
  },
  {
    uid: 'dev', displayName: 'Dev', ageYears: 25, gender: 'man',
    about: 'Football on Sundays, tech meetups on weekdays. Always looking for a good walking route.',
    planTypes: ['walk', 'event', 'movie'], prompt: 'Five-a-side in the morning, a long walk and a late movie.',
    interests: ['football', 'tech', 'movies', 'music'], personality: ['cheerful', 'ambitious'],
    languages: ['english', 'hindi'], profession: 'Data analyst', distanceKm: 1, freeNow: true,
  },
];

export interface SampleQuery {
  showMe: ShowMe;
  planType: string | null;
  /** Spots near the viewer, so the samples show a believable count. */
  venuesNearby: number;
  now: Date;
  photoBaseUrl: string;
}

/** The sample profiles to add for this viewer, in the shape of real cards. */
export function sampleCompanions(query: SampleQuery) {
  return people
    .filter((p) => showMeIncludes(query.showMe, p.gender))
    .filter((p) => query.planType === null || p.planTypes.includes(query.planType))
    .map((p, i) => ({
      uid: `${SAMPLE_UID_PREFIX}${p.uid}`,
      displayName: p.displayName,
      ageYears: p.ageYears,
      gender: null,
      photoPaths: [1, 2, 3].map((n) => `${query.photoBaseUrl}/${p.uid}-${n}.jpg`),
      about: p.about,
      activityTags: [],
      planTypes: p.planTypes,
      prompt: { promptId: 'ideal_sunday', answer: p.prompt },
      voiceIntro: null,
      ratingAvg: null,
      ratingCount: 0,
      meetupCount: 0,
      distanceKm: p.distanceKm,
      spotsNearby: Math.min(query.venuesNearby, 3 + (i % 4)),
      freeNowUntil: p.freeNow ? new Date(query.now.getTime() + 2 * 60 * 60 * 1000).toISOString() : null,
      freeFrom: null,
      freeUntil: null,
      isSample: true,
      details: {
        city: null,
        languages: p.languages,
        education: null,
        profession: p.profession,
        interests: p.interests,
        personality: p.personality,
        socialEnergy: null,
        drinking: null,
        smoking: null,
        fitness: null,
      },
    }));
}

/** The names, for making their illustrations (tool/samples). */
export const sampleIds = people.map((p) => p.uid);
