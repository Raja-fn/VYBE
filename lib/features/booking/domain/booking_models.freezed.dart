// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Venue {

 String get venueId; String get name; String get category; String get addressLine; double get lat; double get lng; double get distanceKm; List<String> get planTypes; double get popularityScore;@JsonKey(unknownEnumValue: PopularityLabel.quiet) PopularityLabel get popularityLabel; int get rank; String? get perk;
/// Create a copy of Venue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VenueCopyWith<Venue> get copyWith => _$VenueCopyWithImpl<Venue>(this as Venue, _$identity);

  /// Serializes this Venue to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Venue&&(identical(other.venueId, venueId) || other.venueId == venueId)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.addressLine, addressLine) || other.addressLine == addressLine)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&const DeepCollectionEquality().equals(other.planTypes, planTypes)&&(identical(other.popularityScore, popularityScore) || other.popularityScore == popularityScore)&&(identical(other.popularityLabel, popularityLabel) || other.popularityLabel == popularityLabel)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.perk, perk) || other.perk == perk));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,venueId,name,category,addressLine,lat,lng,distanceKm,const DeepCollectionEquality().hash(planTypes),popularityScore,popularityLabel,rank,perk);

@override
String toString() {
  return 'Venue(venueId: $venueId, name: $name, category: $category, addressLine: $addressLine, lat: $lat, lng: $lng, distanceKm: $distanceKm, planTypes: $planTypes, popularityScore: $popularityScore, popularityLabel: $popularityLabel, rank: $rank, perk: $perk)';
}


}

/// @nodoc
abstract mixin class $VenueCopyWith<$Res>  {
  factory $VenueCopyWith(Venue value, $Res Function(Venue) _then) = _$VenueCopyWithImpl;
@useResult
$Res call({
 String venueId, String name, String category, String addressLine, double lat, double lng, double distanceKm, List<String> planTypes, double popularityScore,@JsonKey(unknownEnumValue: PopularityLabel.quiet) PopularityLabel popularityLabel, int rank, String? perk
});




}
/// @nodoc
class _$VenueCopyWithImpl<$Res>
    implements $VenueCopyWith<$Res> {
  _$VenueCopyWithImpl(this._self, this._then);

  final Venue _self;
  final $Res Function(Venue) _then;

/// Create a copy of Venue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? venueId = null,Object? name = null,Object? category = null,Object? addressLine = null,Object? lat = null,Object? lng = null,Object? distanceKm = null,Object? planTypes = null,Object? popularityScore = null,Object? popularityLabel = null,Object? rank = null,Object? perk = freezed,}) {
  return _then(_self.copyWith(
venueId: null == venueId ? _self.venueId : venueId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,addressLine: null == addressLine ? _self.addressLine : addressLine // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,planTypes: null == planTypes ? _self.planTypes : planTypes // ignore: cast_nullable_to_non_nullable
as List<String>,popularityScore: null == popularityScore ? _self.popularityScore : popularityScore // ignore: cast_nullable_to_non_nullable
as double,popularityLabel: null == popularityLabel ? _self.popularityLabel : popularityLabel // ignore: cast_nullable_to_non_nullable
as PopularityLabel,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,perk: freezed == perk ? _self.perk : perk // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Venue].
extension VenuePatterns on Venue {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Venue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Venue() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Venue value)  $default,){
final _that = this;
switch (_that) {
case _Venue():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Venue value)?  $default,){
final _that = this;
switch (_that) {
case _Venue() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String venueId,  String name,  String category,  String addressLine,  double lat,  double lng,  double distanceKm,  List<String> planTypes,  double popularityScore, @JsonKey(unknownEnumValue: PopularityLabel.quiet)  PopularityLabel popularityLabel,  int rank,  String? perk)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Venue() when $default != null:
return $default(_that.venueId,_that.name,_that.category,_that.addressLine,_that.lat,_that.lng,_that.distanceKm,_that.planTypes,_that.popularityScore,_that.popularityLabel,_that.rank,_that.perk);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String venueId,  String name,  String category,  String addressLine,  double lat,  double lng,  double distanceKm,  List<String> planTypes,  double popularityScore, @JsonKey(unknownEnumValue: PopularityLabel.quiet)  PopularityLabel popularityLabel,  int rank,  String? perk)  $default,) {final _that = this;
switch (_that) {
case _Venue():
return $default(_that.venueId,_that.name,_that.category,_that.addressLine,_that.lat,_that.lng,_that.distanceKm,_that.planTypes,_that.popularityScore,_that.popularityLabel,_that.rank,_that.perk);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String venueId,  String name,  String category,  String addressLine,  double lat,  double lng,  double distanceKm,  List<String> planTypes,  double popularityScore, @JsonKey(unknownEnumValue: PopularityLabel.quiet)  PopularityLabel popularityLabel,  int rank,  String? perk)?  $default,) {final _that = this;
switch (_that) {
case _Venue() when $default != null:
return $default(_that.venueId,_that.name,_that.category,_that.addressLine,_that.lat,_that.lng,_that.distanceKm,_that.planTypes,_that.popularityScore,_that.popularityLabel,_that.rank,_that.perk);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Venue implements Venue {
  const _Venue({required this.venueId, required this.name, required this.category, required this.addressLine, required this.lat, required this.lng, required this.distanceKm, required final  List<String> planTypes, required this.popularityScore, @JsonKey(unknownEnumValue: PopularityLabel.quiet) required this.popularityLabel, required this.rank, this.perk}): _planTypes = planTypes;
  factory _Venue.fromJson(Map<String, dynamic> json) => _$VenueFromJson(json);

@override final  String venueId;
@override final  String name;
@override final  String category;
@override final  String addressLine;
@override final  double lat;
@override final  double lng;
@override final  double distanceKm;
 final  List<String> _planTypes;
@override List<String> get planTypes {
  if (_planTypes is EqualUnmodifiableListView) return _planTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_planTypes);
}

@override final  double popularityScore;
@override@JsonKey(unknownEnumValue: PopularityLabel.quiet) final  PopularityLabel popularityLabel;
@override final  int rank;
@override final  String? perk;

/// Create a copy of Venue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VenueCopyWith<_Venue> get copyWith => __$VenueCopyWithImpl<_Venue>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VenueToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Venue&&(identical(other.venueId, venueId) || other.venueId == venueId)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.addressLine, addressLine) || other.addressLine == addressLine)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&const DeepCollectionEquality().equals(other._planTypes, _planTypes)&&(identical(other.popularityScore, popularityScore) || other.popularityScore == popularityScore)&&(identical(other.popularityLabel, popularityLabel) || other.popularityLabel == popularityLabel)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.perk, perk) || other.perk == perk));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,venueId,name,category,addressLine,lat,lng,distanceKm,const DeepCollectionEquality().hash(_planTypes),popularityScore,popularityLabel,rank,perk);

@override
String toString() {
  return 'Venue(venueId: $venueId, name: $name, category: $category, addressLine: $addressLine, lat: $lat, lng: $lng, distanceKm: $distanceKm, planTypes: $planTypes, popularityScore: $popularityScore, popularityLabel: $popularityLabel, rank: $rank, perk: $perk)';
}


}

/// @nodoc
abstract mixin class _$VenueCopyWith<$Res> implements $VenueCopyWith<$Res> {
  factory _$VenueCopyWith(_Venue value, $Res Function(_Venue) _then) = __$VenueCopyWithImpl;
@override @useResult
$Res call({
 String venueId, String name, String category, String addressLine, double lat, double lng, double distanceKm, List<String> planTypes, double popularityScore,@JsonKey(unknownEnumValue: PopularityLabel.quiet) PopularityLabel popularityLabel, int rank, String? perk
});




}
/// @nodoc
class __$VenueCopyWithImpl<$Res>
    implements _$VenueCopyWith<$Res> {
  __$VenueCopyWithImpl(this._self, this._then);

  final _Venue _self;
  final $Res Function(_Venue) _then;

/// Create a copy of Venue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? venueId = null,Object? name = null,Object? category = null,Object? addressLine = null,Object? lat = null,Object? lng = null,Object? distanceKm = null,Object? planTypes = null,Object? popularityScore = null,Object? popularityLabel = null,Object? rank = null,Object? perk = freezed,}) {
  return _then(_Venue(
venueId: null == venueId ? _self.venueId : venueId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,addressLine: null == addressLine ? _self.addressLine : addressLine // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,planTypes: null == planTypes ? _self._planTypes : planTypes // ignore: cast_nullable_to_non_nullable
as List<String>,popularityScore: null == popularityScore ? _self.popularityScore : popularityScore // ignore: cast_nullable_to_non_nullable
as double,popularityLabel: null == popularityLabel ? _self.popularityLabel : popularityLabel // ignore: cast_nullable_to_non_nullable
as PopularityLabel,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,perk: freezed == perk ? _self.perk : perk // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$VenueSlot {

 String get slotId; DateTime get startAt; DateTime get endAt;@JsonKey(unknownEnumValue: SlotState.closed) SlotState get state;
/// Create a copy of VenueSlot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VenueSlotCopyWith<VenueSlot> get copyWith => _$VenueSlotCopyWithImpl<VenueSlot>(this as VenueSlot, _$identity);

  /// Serializes this VenueSlot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VenueSlot&&(identical(other.slotId, slotId) || other.slotId == slotId)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.state, state) || other.state == state));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slotId,startAt,endAt,state);

@override
String toString() {
  return 'VenueSlot(slotId: $slotId, startAt: $startAt, endAt: $endAt, state: $state)';
}


}

/// @nodoc
abstract mixin class $VenueSlotCopyWith<$Res>  {
  factory $VenueSlotCopyWith(VenueSlot value, $Res Function(VenueSlot) _then) = _$VenueSlotCopyWithImpl;
@useResult
$Res call({
 String slotId, DateTime startAt, DateTime endAt,@JsonKey(unknownEnumValue: SlotState.closed) SlotState state
});




}
/// @nodoc
class _$VenueSlotCopyWithImpl<$Res>
    implements $VenueSlotCopyWith<$Res> {
  _$VenueSlotCopyWithImpl(this._self, this._then);

  final VenueSlot _self;
  final $Res Function(VenueSlot) _then;

/// Create a copy of VenueSlot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slotId = null,Object? startAt = null,Object? endAt = null,Object? state = null,}) {
  return _then(_self.copyWith(
slotId: null == slotId ? _self.slotId : slotId // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as SlotState,
  ));
}

}


/// Adds pattern-matching-related methods to [VenueSlot].
extension VenueSlotPatterns on VenueSlot {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VenueSlot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VenueSlot() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VenueSlot value)  $default,){
final _that = this;
switch (_that) {
case _VenueSlot():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VenueSlot value)?  $default,){
final _that = this;
switch (_that) {
case _VenueSlot() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String slotId,  DateTime startAt,  DateTime endAt, @JsonKey(unknownEnumValue: SlotState.closed)  SlotState state)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VenueSlot() when $default != null:
return $default(_that.slotId,_that.startAt,_that.endAt,_that.state);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String slotId,  DateTime startAt,  DateTime endAt, @JsonKey(unknownEnumValue: SlotState.closed)  SlotState state)  $default,) {final _that = this;
switch (_that) {
case _VenueSlot():
return $default(_that.slotId,_that.startAt,_that.endAt,_that.state);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String slotId,  DateTime startAt,  DateTime endAt, @JsonKey(unknownEnumValue: SlotState.closed)  SlotState state)?  $default,) {final _that = this;
switch (_that) {
case _VenueSlot() when $default != null:
return $default(_that.slotId,_that.startAt,_that.endAt,_that.state);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VenueSlot extends VenueSlot {
  const _VenueSlot({required this.slotId, required this.startAt, required this.endAt, @JsonKey(unknownEnumValue: SlotState.closed) required this.state}): super._();
  factory _VenueSlot.fromJson(Map<String, dynamic> json) => _$VenueSlotFromJson(json);

@override final  String slotId;
@override final  DateTime startAt;
@override final  DateTime endAt;
@override@JsonKey(unknownEnumValue: SlotState.closed) final  SlotState state;

/// Create a copy of VenueSlot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VenueSlotCopyWith<_VenueSlot> get copyWith => __$VenueSlotCopyWithImpl<_VenueSlot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VenueSlotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VenueSlot&&(identical(other.slotId, slotId) || other.slotId == slotId)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.state, state) || other.state == state));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slotId,startAt,endAt,state);

@override
String toString() {
  return 'VenueSlot(slotId: $slotId, startAt: $startAt, endAt: $endAt, state: $state)';
}


}

/// @nodoc
abstract mixin class _$VenueSlotCopyWith<$Res> implements $VenueSlotCopyWith<$Res> {
  factory _$VenueSlotCopyWith(_VenueSlot value, $Res Function(_VenueSlot) _then) = __$VenueSlotCopyWithImpl;
@override @useResult
$Res call({
 String slotId, DateTime startAt, DateTime endAt,@JsonKey(unknownEnumValue: SlotState.closed) SlotState state
});




}
/// @nodoc
class __$VenueSlotCopyWithImpl<$Res>
    implements _$VenueSlotCopyWith<$Res> {
  __$VenueSlotCopyWithImpl(this._self, this._then);

  final _VenueSlot _self;
  final $Res Function(_VenueSlot) _then;

/// Create a copy of VenueSlot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slotId = null,Object? startAt = null,Object? endAt = null,Object? state = null,}) {
  return _then(_VenueSlot(
slotId: null == slotId ? _self.slotId : slotId // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as SlotState,
  ));
}


}

/// @nodoc
mixin _$Booking {

 String get id; String get seekerUid; String get companionUid; String get companionName; String get seekerName; String get venueName; String get venueCategory; String get planType; DateTime get startAt; DateTime get endAt; BookingStatus get status; BookingKind get kind; int get creditCost;
/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingCopyWith<Booking> get copyWith => _$BookingCopyWithImpl<Booking>(this as Booking, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.seekerUid, seekerUid) || other.seekerUid == seekerUid)&&(identical(other.companionUid, companionUid) || other.companionUid == companionUid)&&(identical(other.companionName, companionName) || other.companionName == companionName)&&(identical(other.seekerName, seekerName) || other.seekerName == seekerName)&&(identical(other.venueName, venueName) || other.venueName == venueName)&&(identical(other.venueCategory, venueCategory) || other.venueCategory == venueCategory)&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.creditCost, creditCost) || other.creditCost == creditCost));
}


@override
int get hashCode => Object.hash(runtimeType,id,seekerUid,companionUid,companionName,seekerName,venueName,venueCategory,planType,startAt,endAt,status,kind,creditCost);

@override
String toString() {
  return 'Booking(id: $id, seekerUid: $seekerUid, companionUid: $companionUid, companionName: $companionName, seekerName: $seekerName, venueName: $venueName, venueCategory: $venueCategory, planType: $planType, startAt: $startAt, endAt: $endAt, status: $status, kind: $kind, creditCost: $creditCost)';
}


}

/// @nodoc
abstract mixin class $BookingCopyWith<$Res>  {
  factory $BookingCopyWith(Booking value, $Res Function(Booking) _then) = _$BookingCopyWithImpl;
@useResult
$Res call({
 String id, String seekerUid, String companionUid, String companionName, String seekerName, String venueName, String venueCategory, String planType, DateTime startAt, DateTime endAt, BookingStatus status, BookingKind kind, int creditCost
});




}
/// @nodoc
class _$BookingCopyWithImpl<$Res>
    implements $BookingCopyWith<$Res> {
  _$BookingCopyWithImpl(this._self, this._then);

  final Booking _self;
  final $Res Function(Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? seekerUid = null,Object? companionUid = null,Object? companionName = null,Object? seekerName = null,Object? venueName = null,Object? venueCategory = null,Object? planType = null,Object? startAt = null,Object? endAt = null,Object? status = null,Object? kind = null,Object? creditCost = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,seekerUid: null == seekerUid ? _self.seekerUid : seekerUid // ignore: cast_nullable_to_non_nullable
as String,companionUid: null == companionUid ? _self.companionUid : companionUid // ignore: cast_nullable_to_non_nullable
as String,companionName: null == companionName ? _self.companionName : companionName // ignore: cast_nullable_to_non_nullable
as String,seekerName: null == seekerName ? _self.seekerName : seekerName // ignore: cast_nullable_to_non_nullable
as String,venueName: null == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String,venueCategory: null == venueCategory ? _self.venueCategory : venueCategory // ignore: cast_nullable_to_non_nullable
as String,planType: null == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as BookingKind,creditCost: null == creditCost ? _self.creditCost : creditCost // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Booking].
extension BookingPatterns on Booking {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Booking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Booking value)  $default,){
final _that = this;
switch (_that) {
case _Booking():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Booking value)?  $default,){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String seekerUid,  String companionUid,  String companionName,  String seekerName,  String venueName,  String venueCategory,  String planType,  DateTime startAt,  DateTime endAt,  BookingStatus status,  BookingKind kind,  int creditCost)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.seekerUid,_that.companionUid,_that.companionName,_that.seekerName,_that.venueName,_that.venueCategory,_that.planType,_that.startAt,_that.endAt,_that.status,_that.kind,_that.creditCost);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String seekerUid,  String companionUid,  String companionName,  String seekerName,  String venueName,  String venueCategory,  String planType,  DateTime startAt,  DateTime endAt,  BookingStatus status,  BookingKind kind,  int creditCost)  $default,) {final _that = this;
switch (_that) {
case _Booking():
return $default(_that.id,_that.seekerUid,_that.companionUid,_that.companionName,_that.seekerName,_that.venueName,_that.venueCategory,_that.planType,_that.startAt,_that.endAt,_that.status,_that.kind,_that.creditCost);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String seekerUid,  String companionUid,  String companionName,  String seekerName,  String venueName,  String venueCategory,  String planType,  DateTime startAt,  DateTime endAt,  BookingStatus status,  BookingKind kind,  int creditCost)?  $default,) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.seekerUid,_that.companionUid,_that.companionName,_that.seekerName,_that.venueName,_that.venueCategory,_that.planType,_that.startAt,_that.endAt,_that.status,_that.kind,_that.creditCost);case _:
  return null;

}
}

}

/// @nodoc


class _Booking extends Booking {
  const _Booking({required this.id, required this.seekerUid, required this.companionUid, required this.companionName, required this.seekerName, required this.venueName, required this.venueCategory, required this.planType, required this.startAt, required this.endAt, required this.status, required this.kind, required this.creditCost}): super._();
  

@override final  String id;
@override final  String seekerUid;
@override final  String companionUid;
@override final  String companionName;
@override final  String seekerName;
@override final  String venueName;
@override final  String venueCategory;
@override final  String planType;
@override final  DateTime startAt;
@override final  DateTime endAt;
@override final  BookingStatus status;
@override final  BookingKind kind;
@override final  int creditCost;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingCopyWith<_Booking> get copyWith => __$BookingCopyWithImpl<_Booking>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.seekerUid, seekerUid) || other.seekerUid == seekerUid)&&(identical(other.companionUid, companionUid) || other.companionUid == companionUid)&&(identical(other.companionName, companionName) || other.companionName == companionName)&&(identical(other.seekerName, seekerName) || other.seekerName == seekerName)&&(identical(other.venueName, venueName) || other.venueName == venueName)&&(identical(other.venueCategory, venueCategory) || other.venueCategory == venueCategory)&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.creditCost, creditCost) || other.creditCost == creditCost));
}


@override
int get hashCode => Object.hash(runtimeType,id,seekerUid,companionUid,companionName,seekerName,venueName,venueCategory,planType,startAt,endAt,status,kind,creditCost);

@override
String toString() {
  return 'Booking(id: $id, seekerUid: $seekerUid, companionUid: $companionUid, companionName: $companionName, seekerName: $seekerName, venueName: $venueName, venueCategory: $venueCategory, planType: $planType, startAt: $startAt, endAt: $endAt, status: $status, kind: $kind, creditCost: $creditCost)';
}


}

/// @nodoc
abstract mixin class _$BookingCopyWith<$Res> implements $BookingCopyWith<$Res> {
  factory _$BookingCopyWith(_Booking value, $Res Function(_Booking) _then) = __$BookingCopyWithImpl;
@override @useResult
$Res call({
 String id, String seekerUid, String companionUid, String companionName, String seekerName, String venueName, String venueCategory, String planType, DateTime startAt, DateTime endAt, BookingStatus status, BookingKind kind, int creditCost
});




}
/// @nodoc
class __$BookingCopyWithImpl<$Res>
    implements _$BookingCopyWith<$Res> {
  __$BookingCopyWithImpl(this._self, this._then);

  final _Booking _self;
  final $Res Function(_Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? seekerUid = null,Object? companionUid = null,Object? companionName = null,Object? seekerName = null,Object? venueName = null,Object? venueCategory = null,Object? planType = null,Object? startAt = null,Object? endAt = null,Object? status = null,Object? kind = null,Object? creditCost = null,}) {
  return _then(_Booking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,seekerUid: null == seekerUid ? _self.seekerUid : seekerUid // ignore: cast_nullable_to_non_nullable
as String,companionUid: null == companionUid ? _self.companionUid : companionUid // ignore: cast_nullable_to_non_nullable
as String,companionName: null == companionName ? _self.companionName : companionName // ignore: cast_nullable_to_non_nullable
as String,seekerName: null == seekerName ? _self.seekerName : seekerName // ignore: cast_nullable_to_non_nullable
as String,venueName: null == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String,venueCategory: null == venueCategory ? _self.venueCategory : venueCategory // ignore: cast_nullable_to_non_nullable
as String,planType: null == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime,endAt: null == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as BookingKind,creditCost: null == creditCost ? _self.creditCost : creditCost // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
