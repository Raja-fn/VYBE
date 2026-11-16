// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_details.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileDetails {

 String? get about; String? get city; List<String> get languages; String? get education; String? get profession; List<String> get interests; List<String> get personality; String? get socialEnergy; String? get drinking; String? get smoking; String? get fitness;
/// Create a copy of ProfileDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileDetailsCopyWith<ProfileDetails> get copyWith => _$ProfileDetailsCopyWithImpl<ProfileDetails>(this as ProfileDetails, _$identity);

  /// Serializes this ProfileDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileDetails&&(identical(other.about, about) || other.about == about)&&(identical(other.city, city) || other.city == city)&&const DeepCollectionEquality().equals(other.languages, languages)&&(identical(other.education, education) || other.education == education)&&(identical(other.profession, profession) || other.profession == profession)&&const DeepCollectionEquality().equals(other.interests, interests)&&const DeepCollectionEquality().equals(other.personality, personality)&&(identical(other.socialEnergy, socialEnergy) || other.socialEnergy == socialEnergy)&&(identical(other.drinking, drinking) || other.drinking == drinking)&&(identical(other.smoking, smoking) || other.smoking == smoking)&&(identical(other.fitness, fitness) || other.fitness == fitness));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,about,city,const DeepCollectionEquality().hash(languages),education,profession,const DeepCollectionEquality().hash(interests),const DeepCollectionEquality().hash(personality),socialEnergy,drinking,smoking,fitness);

@override
String toString() {
  return 'ProfileDetails(about: $about, city: $city, languages: $languages, education: $education, profession: $profession, interests: $interests, personality: $personality, socialEnergy: $socialEnergy, drinking: $drinking, smoking: $smoking, fitness: $fitness)';
}


}

/// @nodoc
abstract mixin class $ProfileDetailsCopyWith<$Res>  {
  factory $ProfileDetailsCopyWith(ProfileDetails value, $Res Function(ProfileDetails) _then) = _$ProfileDetailsCopyWithImpl;
@useResult
$Res call({
 String? about, String? city, List<String> languages, String? education, String? profession, List<String> interests, List<String> personality, String? socialEnergy, String? drinking, String? smoking, String? fitness
});




}
/// @nodoc
class _$ProfileDetailsCopyWithImpl<$Res>
    implements $ProfileDetailsCopyWith<$Res> {
  _$ProfileDetailsCopyWithImpl(this._self, this._then);

  final ProfileDetails _self;
  final $Res Function(ProfileDetails) _then;

/// Create a copy of ProfileDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? about = freezed,Object? city = freezed,Object? languages = null,Object? education = freezed,Object? profession = freezed,Object? interests = null,Object? personality = null,Object? socialEnergy = freezed,Object? drinking = freezed,Object? smoking = freezed,Object? fitness = freezed,}) {
  return _then(_self.copyWith(
about: freezed == about ? _self.about : about // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,languages: null == languages ? _self.languages : languages // ignore: cast_nullable_to_non_nullable
as List<String>,education: freezed == education ? _self.education : education // ignore: cast_nullable_to_non_nullable
as String?,profession: freezed == profession ? _self.profession : profession // ignore: cast_nullable_to_non_nullable
as String?,interests: null == interests ? _self.interests : interests // ignore: cast_nullable_to_non_nullable
as List<String>,personality: null == personality ? _self.personality : personality // ignore: cast_nullable_to_non_nullable
as List<String>,socialEnergy: freezed == socialEnergy ? _self.socialEnergy : socialEnergy // ignore: cast_nullable_to_non_nullable
as String?,drinking: freezed == drinking ? _self.drinking : drinking // ignore: cast_nullable_to_non_nullable
as String?,smoking: freezed == smoking ? _self.smoking : smoking // ignore: cast_nullable_to_non_nullable
as String?,fitness: freezed == fitness ? _self.fitness : fitness // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileDetails].
extension ProfileDetailsPatterns on ProfileDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileDetails() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileDetails value)  $default,){
final _that = this;
switch (_that) {
case _ProfileDetails():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileDetails value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileDetails() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? about,  String? city,  List<String> languages,  String? education,  String? profession,  List<String> interests,  List<String> personality,  String? socialEnergy,  String? drinking,  String? smoking,  String? fitness)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileDetails() when $default != null:
return $default(_that.about,_that.city,_that.languages,_that.education,_that.profession,_that.interests,_that.personality,_that.socialEnergy,_that.drinking,_that.smoking,_that.fitness);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? about,  String? city,  List<String> languages,  String? education,  String? profession,  List<String> interests,  List<String> personality,  String? socialEnergy,  String? drinking,  String? smoking,  String? fitness)  $default,) {final _that = this;
switch (_that) {
case _ProfileDetails():
return $default(_that.about,_that.city,_that.languages,_that.education,_that.profession,_that.interests,_that.personality,_that.socialEnergy,_that.drinking,_that.smoking,_that.fitness);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? about,  String? city,  List<String> languages,  String? education,  String? profession,  List<String> interests,  List<String> personality,  String? socialEnergy,  String? drinking,  String? smoking,  String? fitness)?  $default,) {final _that = this;
switch (_that) {
case _ProfileDetails() when $default != null:
return $default(_that.about,_that.city,_that.languages,_that.education,_that.profession,_that.interests,_that.personality,_that.socialEnergy,_that.drinking,_that.smoking,_that.fitness);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfileDetails extends ProfileDetails {
  const _ProfileDetails({this.about, this.city, final  List<String> languages = const [], this.education, this.profession, final  List<String> interests = const [], final  List<String> personality = const [], this.socialEnergy, this.drinking, this.smoking, this.fitness}): _languages = languages,_interests = interests,_personality = personality,super._();
  factory _ProfileDetails.fromJson(Map<String, dynamic> json) => _$ProfileDetailsFromJson(json);

@override final  String? about;
@override final  String? city;
 final  List<String> _languages;
@override@JsonKey() List<String> get languages {
  if (_languages is EqualUnmodifiableListView) return _languages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_languages);
}

@override final  String? education;
@override final  String? profession;
 final  List<String> _interests;
@override@JsonKey() List<String> get interests {
  if (_interests is EqualUnmodifiableListView) return _interests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_interests);
}

 final  List<String> _personality;
@override@JsonKey() List<String> get personality {
  if (_personality is EqualUnmodifiableListView) return _personality;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_personality);
}

@override final  String? socialEnergy;
@override final  String? drinking;
@override final  String? smoking;
@override final  String? fitness;

/// Create a copy of ProfileDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileDetailsCopyWith<_ProfileDetails> get copyWith => __$ProfileDetailsCopyWithImpl<_ProfileDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileDetails&&(identical(other.about, about) || other.about == about)&&(identical(other.city, city) || other.city == city)&&const DeepCollectionEquality().equals(other._languages, _languages)&&(identical(other.education, education) || other.education == education)&&(identical(other.profession, profession) || other.profession == profession)&&const DeepCollectionEquality().equals(other._interests, _interests)&&const DeepCollectionEquality().equals(other._personality, _personality)&&(identical(other.socialEnergy, socialEnergy) || other.socialEnergy == socialEnergy)&&(identical(other.drinking, drinking) || other.drinking == drinking)&&(identical(other.smoking, smoking) || other.smoking == smoking)&&(identical(other.fitness, fitness) || other.fitness == fitness));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,about,city,const DeepCollectionEquality().hash(_languages),education,profession,const DeepCollectionEquality().hash(_interests),const DeepCollectionEquality().hash(_personality),socialEnergy,drinking,smoking,fitness);

@override
String toString() {
  return 'ProfileDetails(about: $about, city: $city, languages: $languages, education: $education, profession: $profession, interests: $interests, personality: $personality, socialEnergy: $socialEnergy, drinking: $drinking, smoking: $smoking, fitness: $fitness)';
}


}

/// @nodoc
abstract mixin class _$ProfileDetailsCopyWith<$Res> implements $ProfileDetailsCopyWith<$Res> {
  factory _$ProfileDetailsCopyWith(_ProfileDetails value, $Res Function(_ProfileDetails) _then) = __$ProfileDetailsCopyWithImpl;
@override @useResult
$Res call({
 String? about, String? city, List<String> languages, String? education, String? profession, List<String> interests, List<String> personality, String? socialEnergy, String? drinking, String? smoking, String? fitness
});




}
/// @nodoc
class __$ProfileDetailsCopyWithImpl<$Res>
    implements _$ProfileDetailsCopyWith<$Res> {
  __$ProfileDetailsCopyWithImpl(this._self, this._then);

  final _ProfileDetails _self;
  final $Res Function(_ProfileDetails) _then;

/// Create a copy of ProfileDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? about = freezed,Object? city = freezed,Object? languages = null,Object? education = freezed,Object? profession = freezed,Object? interests = null,Object? personality = null,Object? socialEnergy = freezed,Object? drinking = freezed,Object? smoking = freezed,Object? fitness = freezed,}) {
  return _then(_ProfileDetails(
about: freezed == about ? _self.about : about // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,languages: null == languages ? _self._languages : languages // ignore: cast_nullable_to_non_nullable
as List<String>,education: freezed == education ? _self.education : education // ignore: cast_nullable_to_non_nullable
as String?,profession: freezed == profession ? _self.profession : profession // ignore: cast_nullable_to_non_nullable
as String?,interests: null == interests ? _self._interests : interests // ignore: cast_nullable_to_non_nullable
as List<String>,personality: null == personality ? _self._personality : personality // ignore: cast_nullable_to_non_nullable
as List<String>,socialEnergy: freezed == socialEnergy ? _self.socialEnergy : socialEnergy // ignore: cast_nullable_to_non_nullable
as String?,drinking: freezed == drinking ? _self.drinking : drinking // ignore: cast_nullable_to_non_nullable
as String?,smoking: freezed == smoking ? _self.smoking : smoking // ignore: cast_nullable_to_non_nullable
as String?,fitness: freezed == fitness ? _self.fitness : fitness // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
