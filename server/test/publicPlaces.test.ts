import { OpenStreetMapPlaces, overpassQuery, placesFromOsm } from '../src/services/places/publicPlacesSource';

describe('OpenStreetMap places', () => {
  it('asks for named public places of each kind around the point', () => {
    const query = overpassQuery({ lat: 26.9124, lng: 75.7873 }, 6.6, 12);
    expect(query).toContain('[out:json][timeout:12]');
    expect(query).toContain('nwr["amenity"="cafe"]["name"](around:6600,26.91240,75.78730);out center 60;');
    expect(query).toContain('["leisure"="park"]');
    expect(query).not.toMatch(/bar|pub|nightclub/);
  });

  it('turns OSM elements into meeting spots, dropping unnamed, generic and private ones', () => {
    const places = placesFromOsm([
      { type: 'node', id: 1, lat: 26.91, lon: 75.78, tags: { amenity: 'cafe', name: 'Tapri Central', 'addr:street': 'C Scheme', 'addr:city': 'Jaipur' } },
      { type: 'way', id: 2, center: { lat: 26.92, lon: 75.79 }, tags: { leisure: 'park', name: 'Central Park' } },
      { type: 'node', id: 3, lat: 26.9, lon: 75.7, tags: { amenity: 'cinema', name: 'Raj Mandir' } },
      { type: 'node', id: 4, lat: 26.9, lon: 75.7, tags: { amenity: 'cafe' } },
      { type: 'node', id: 8, lat: 26.9, lon: 75.7, tags: { amenity: 'cafe', name: 'Café' } },
      { type: 'node', id: 5, lat: 26.9, lon: 75.7, tags: { leisure: 'park', name: 'Club lawn', access: 'private' } },
      { type: 'node', id: 6, lat: 26.9, lon: 75.7, tags: { amenity: 'bar', name: 'Somewhere' } },
      { type: 'relation', id: 7, tags: { shop: 'mall', name: 'No position' } },
    ]);
    expect(places).toEqual([
      { venueId: 'osm-node-1', name: 'Tapri Central', category: 'cafe', planTypes: ['coffee'], addressLine: 'C Scheme, Jaipur', lat: 26.91, lng: 75.78 },
      { venueId: 'osm-way-2', name: 'Central Park', category: 'open_park', planTypes: ['walk'], addressLine: '', lat: 26.92, lng: 75.79 },
      { venueId: 'osm-node-3', name: 'Raj Mandir', category: 'cinema', planTypes: ['movie'], addressLine: '', lat: 26.9, lng: 75.7 },
    ]);
  });

  it('posts the query to Overpass, tries the next server when one is busy, and fails loudly when all are', async () => {
    const bodies: string[] = [];
    const ok = new OpenStreetMapPlaces({
      timeoutSeconds: 5,
      fetchFn: (async (_url: string, init?: RequestInit) => {
        bodies.push(String(init?.body));
        return new Response(JSON.stringify({ elements: [{ type: 'node', id: 9, lat: 1, lon: 2, tags: { amenity: 'restaurant', name: 'Dal Baati' } }] }));
      }) as typeof fetch,
    });
    expect((await ok.nearby({ lat: 1, lng: 2 }, 5)).map((p) => p.name)).toEqual(['Dal Baati']);
    expect(new URLSearchParams(bodies[0]).get('data')).toContain('amenity');

    const tried: string[] = [];
    const flaky = new OpenStreetMapPlaces({
      timeoutSeconds: 5,
      endpoints: ['https://a', 'https://b'],
      fetchFn: (async (url: string) => {
        tried.push(url);
        return url === 'https://a'
          ? new Response('busy', { status: 502 })
          : new Response(JSON.stringify({ elements: [] }));
      }) as typeof fetch,
    });
    await expect(flaky.nearby({ lat: 1, lng: 2 }, 5)).resolves.toEqual([]);
    expect(tried).toEqual(['https://a', 'https://b']);

    const down = new OpenStreetMapPlaces({ timeoutSeconds: 5, fetchFn: (async () => new Response('busy', { status: 429 })) as typeof fetch });
    await expect(down.nearby({ lat: 1, lng: 2 }, 5)).rejects.toThrow('HTTP 429; HTTP 429; HTTP 429');
  });
});
