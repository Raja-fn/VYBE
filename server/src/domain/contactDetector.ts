/**
 * VYBE's own rule set for keeping chats on the app: phone numbers, emails,
 * social handles and links are blocked before a message is stored.
 * Pure, so every rule is unit-tested. Explicit content is a separate check
 * (ModerationService).
 */

export type ContactReason = 'phone_number' | 'email' | 'social_handle' | 'link';

const DIGIT_WORDS: Record<string, string> = {
  zero: '0', oh: '0', one: '1', two: '2', three: '3', four: '4', five: '5', six: '6', seven: '7', eight: '8', nine: '9',
  // Hindi numerals typed in Latin script.
  ek: '1', do: '2', teen: '3', char: '4', chaar: '4', paanch: '5', panch: '5', chhe: '6', saat: '7', aath: '8', nau: '9', shunya: '0',
};

/** Shortest digit run treated as a phone number (Indian mobiles have 10). */
const MIN_PHONE_DIGITS = 8;

/** Apps people use to move a chat elsewhere. */
const PLATFORMS = [
  'whatsapp', 'whats app', 'watsapp', 'insta', 'instagram', 'snapchat', 'snap', 'telegram', 'facebook', 'fb',
  'twitter', 'linkedin', 'signal', 'discord', 'hangouts', 'skype', 'imo', 'sharechat', 'moj', 'gpay', 'paytm', 'upi',
];

/** Normalises tricks like "9 8 7", "nine eight", "9-8.7" into plain digits. */
function digitRuns(text: string): string[] {
  const words = text
    .toLowerCase()
    .split(/[^a-z0-9]+/)
    .filter(Boolean)
    .map((w) => DIGIT_WORDS[w] ?? w);
  const runs: string[] = [];
  let current = '';
  for (const word of words) {
    if (/^\d+$/.test(word)) {
      current += word;
    } else {
      if (current) runs.push(current);
      current = '';
    }
  }
  if (current) runs.push(current);
  return runs;
}

function hasPhoneNumber(text: string): boolean {
  // Times ("4:00"), short counts ("5 km", "2 credits") and dates stay well under the threshold.
  return digitRuns(text).some((run) => run.length >= MIN_PHONE_DIGITS);
}

function hasEmail(text: string): boolean {
  if (/[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}/i.test(text)) return true;
  // "name at gmail dot com", "name (at) gmail (dot) com"
  return /\b[a-z0-9._-]+\s*[([]?\s*at\s*[)\]]?\s*[a-z0-9-]+\s*[([]?\s*dot\s*[)\]]?\s*[a-z]{2,}\b/i.test(text);
}

function hasLink(text: string): boolean {
  if (/\b(https?:\/\/|www\.)/i.test(text)) return true;
  // bare domains: "bit.ly/x", "example.com", "wa.me/91..."
  return /\b[a-z0-9-]+\s*\.\s*(com|in|net|org|io|me|ly|co|app|link|gg|xyz|info|biz)\b(\/\S*)?/i.test(text);
}

function hasSocialHandle(text: string): boolean {
  if (/(^|\s)@[a-z0-9._]{3,}/i.test(text)) return true;
  const lower = text.toLowerCase();
  return PLATFORMS.some((p) => new RegExp(`(^|[^a-z])${p.replace(/ /g, '\\s*')}([^a-z]|$)`).test(lower));
}

/** Every rule a message breaks; empty means it may be sent. */
export function detectContactSharing(text: string): ContactReason[] {
  const reasons: ContactReason[] = [];
  if (hasPhoneNumber(text)) reasons.push('phone_number');
  if (hasEmail(text)) reasons.push('email');
  if (hasSocialHandle(text)) reasons.push('social_handle');
  if (hasLink(text)) reasons.push('link');
  return reasons;
}
