import { detectContactSharing } from '../src/domain/contactDetector';

const blocked = (text: string) => detectContactSharing(text);

describe('detectContactSharing', () => {
  it.each([
    'call me 9876543210',
    'my number is 98765 43210',
    '+91-98765-43210',
    '9 8 7 6 5 4 3 2 1 0',
    '98.76.54.32.10',
    'nine eight seven six five four three two one zero',
    'nau aath saat chhe paanch char teen do ek shunya',
    'landline 022 2645 1234',
  ])('blocks a phone number: %s', (text) => {
    expect(blocked(text)).toContain('phone_number');
  });

  it.each(['neha.rao@gmail.com', 'mail me at neha at gmail dot com', 'neha (at) yahoo (dot) in'])('blocks an email: %s', (text) => {
    expect(blocked(text)).toContain('email');
  });

  it.each(['add me @neha_rao', 'my insta is neharao', 'ping me on WhatsApp', 'snap me', 'telegram?', 'whats app me'])(
    'blocks a social handle or platform: %s',
    (text) => {
      expect(blocked(text)).toContain('social_handle');
    },
  );

  it.each(['https://example.com/me', 'www.neha.in', 'bit.ly/abc', 'wa.me/919876543210', 'check example . com'])('blocks a link: %s', (text) => {
    expect(blocked(text)).toContain('link');
  });

  it.each([
    'Hi! Saw you like filter coffee.',
    'Yes! Free this Saturday?',
    'Afternoon works for me. 4:00 PM at the cafe?',
    'It is about 2 km from me, 20 minutes walk',
    'Booked for 15 Nov, see you at 6',
    'I have 12 credits left',
    'Shall we meet at Harbour Bean Cafe?',
    'The snapper fish there is great',
    'Do you like movies?',
  ])('allows ordinary planning: %s', (text) => {
    expect(blocked(text)).toEqual([]);
  });

  it('reports every rule broken', () => {
    expect(blocked('whatsapp 9876543210 or a@b.com')).toEqual(['phone_number', 'email', 'social_handle', 'link']);
  });
});
