// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Venue _$VenueFromJson(Map<String, dynamic> json) => _Venue(
  venueId: json['venueId'] as String,
  name: json['name'] as String,
  category: json['category'] as String,
  addressLine: json['addressLine'] as String,
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
  distanceKm: (json['distanceKm'] as num).toDouble(),
  planTypes: (json['planTypes'] as List<dynamic>).map((e) => e as String).toList(),
  popularityScore: (json['popularityScore'] as num).toDouble(),
  popularityLabel: $enumDecode(_$PopularityLabelEnumMap, json['popularityLabel'], unknownValue: PopularityLabel.quiet),
  rank: (json['rank'] as num).toInt(),
  perk: json['perk'] as String?,
);

Map<String, dynamic> _$VenueToJson(_Venue instance) => <String, dynamic>{
  'venueId': instance.venueId,
  'name': instance.name,
  'category': instance.category,
  'addressLine': instance.addressLine,
  'lat': instance.lat,
  'lng': instance.lng,
  'distanceKm': instance.distanceKm,
  'planTypes': instance.planTypes,
  'popularityScore': instance.popularityScore,
  'popularityLabel': _$PopularityLabelEnumMap[instance.popularityLabel]!,
  'rank': instance.rank,
  'perk': instance.perk,
};

const _$PopularityLabelEnumMap = {
  PopularityLabel.hot: 'hot',
  PopularityLabel.busy: 'busy',
  PopularityLabel.quiet: 'quiet',
};

_VenueSlot _$VenueSlotFromJson(Map<String, dynamic> json) => _VenueSlot(
  slotId: json['slotId'] as String,
  startAt: DateTime.parse(json['startAt'] as String),
  endAt: DateTime.parse(json['endAt'] as String),
  state: $enumDecode(_$SlotStateEnumMap, json['state'], unknownValue: SlotState.closed),
);

Map<String, dynamic> _$VenueSlotToJson(_VenueSlot instance) => <String, dynamic>{
  'slotId': instance.slotId,
  'startAt': instance.startAt.toIso8601String(),
  'endAt': instance.endAt.toIso8601String(),
  'state': _$SlotStateEnumMap[instance.state]!,
};

const _$SlotStateEnumMap = {
  SlotState.available: 'available',
  SlotState.past: 'past',
  SlotState.closed: 'closed',
  SlotState.full: 'full',
  SlotState.companionUnavailable: 'companion_unavailable',
};
