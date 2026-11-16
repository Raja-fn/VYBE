"""Pulls public meeting places out of an OpenStreetMap .osm.pbf file.

    python -E -P tool/places/extract_osm_places.py <india-latest.osm.pbf> <out.jsonl>

Writes one JSON object per line in Overpass element shape
({type, id, lat, lon, tags}), which server/scripts/import-places.ts turns into
venues with the same rules the server uses (placesFromOsm).

Kinds: cafes, restaurants, food courts, cinemas, malls, parks, theatres and
arts centres, named only. Places drawn as outlines (ways) get the average of
their corner points.

Speed: the file holds hundreds of millions of points. Every scan filters in
osmium's C++ layer (by tag key, or by id), so Python only sees the objects it
needs. Three scans: matching outlines, matching points, outline corners.
"""
import json
import sys
import time

import osmium
from osmium.filter import IdFilter, KeyFilter

KEEP_TAGS = ('name', 'amenity', 'shop', 'leisure', 'access', 'addr:street', 'addr:suburb',
             'addr:neighbourhood', 'addr:city')
AMENITIES = {'cafe', 'restaurant', 'food_court', 'cinema', 'theatre', 'arts_centre'}
KINDS = ('amenity', 'shop', 'leisure')


def wanted(tags) -> bool:
    if 'name' not in tags:
        return False
    return tags.get('amenity') in AMENITIES or tags.get('shop') == 'mall' or tags.get('leisure') == 'park'


def keep(tags) -> dict:
    return {k: tags[k] for k in KEEP_TAGS if k in tags}


def log(started: float, message: str) -> None:
    print(f'[{time.time() - started:6.0f}s] {message}', flush=True)


def main(pbf: str, out_path: str) -> None:
    started = time.time()

    # Scan 1: outlines (ways) of the wanted kinds, and the corner ids they need.
    ways = {}
    needed = set()
    for w in osmium.FileProcessor(pbf, osmium.osm.WAY).with_filter(KeyFilter(*KINDS)):
        if wanted(w.tags):
            refs = [n.ref for n in w.nodes]
            ways[w.id] = (keep(w.tags), refs)
            needed.update(refs)
    log(started, f'scan 1: {len(ways)} outlines, {len(needed)} corner points needed')

    with open(out_path, 'w', encoding='utf-8') as out:
        # Scan 2: places drawn as single points.
        points = 0
        for n in osmium.FileProcessor(pbf, osmium.osm.NODE).with_filter(KeyFilter(*KINDS)):
            if wanted(n.tags) and n.location.valid():
                out.write(json.dumps({'type': 'node', 'id': n.id, 'lat': n.location.lat, 'lon': n.location.lon,
                                      'tags': keep(n.tags)}, ensure_ascii=False) + '\n')
                points += 1
        log(started, f'scan 2: {points} points')

        # Scan 3: just the corner points of the outlines.
        locations = {}
        for n in osmium.FileProcessor(pbf, osmium.osm.NODE).with_filter(IdFilter(needed)):
            if n.location.valid():
                locations[n.id] = (n.location.lat, n.location.lon)
        outlines = 0
        for way_id, (tags, refs) in ways.items():
            corners = [locations[r] for r in refs if r in locations]
            if not corners:
                continue
            lat = sum(c[0] for c in corners) / len(corners)
            lon = sum(c[1] for c in corners) / len(corners)
            out.write(json.dumps({'type': 'way', 'id': way_id, 'center': {'lat': lat, 'lon': lon}, 'tags': tags},
                                 ensure_ascii=False) + '\n')
            outlines += 1
        log(started, f'scan 3: {outlines} outlines placed; {points + outlines} places written to {out_path}')


if __name__ == '__main__':
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(sys.argv[1], sys.argv[2])
