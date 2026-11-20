// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'companion_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PromptAnswer {

 String get promptId; String get answer;
/// Create a copy of PromptAnswer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PromptAnswerCopyWith<PromptAnswer> get copyWith => _$PromptAnswerCopyWithImpl<PromptAnswer>(this as PromptAnswer, _$identity);

  /// Serializes this PromptAnswer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PromptAnswer&&(identical(other.promptId, promptId) || other.promptId == promptId)&&(identical(other.answer, answer) || other.answer == answer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,promptId,answer);

@override
String toString() {
  return 'PromptAnswer(promptId: $promptId, answer: $answer)';
}


}

/// @nodoc
abstract mixin class $PromptAnswerCopyWith<$Res>  {
  factory $PromptAnswerCopyWith(PromptAnswer value, $Res Function(PromptAnswer) _then) = _$PromptAnswerCopyWithImpl;
@useResult
$Res call({
 String promptId, String answer
});




}
/// @nodoc
class _$PromptAnswerCopyWithImpl<$Res>
    implements $PromptAnswerCopyWith<$Res> {
  _$PromptAnswerCopyWithImpl(this._self, this._then);

  final PromptAnswer _self;
  final $Res Function(PromptAnswer) _then;

/// Create a copy of PromptAnswer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? promptId = null,Object? answer = null,}) {
  return _then(_self.copyWith(
promptId: null == promptId ? _self.promptId : promptId // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PromptAnswer].
extension PromptAnswerPatterns on PromptAnswer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PromptAnswer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PromptAnswer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PromptAnswer value)  $default,){
final _that = this;
switch (_that) {
case _PromptAnswer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PromptAnswer value)?  $default,){
final _that = this;
switch (_that) {
case _PromptAnswer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String promptId,  String answer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PromptAnswer() when $default != null:
return $default(_that.promptId,_that.answer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String promptId,  String answer)  $default,) {final _that = this;
switch (_that) {
case _PromptAnswer():
return $default(_that.promptId,_that.answer);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String promptId,  String answer)?  $default,) {final _that = this;
switch (_that) {
case _PromptAnswer() when $default != null:
return $default(_that.promptId,_that.answer);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PromptAnswer implements PromptAnswer {
  const _PromptAnswer({required this.promptId, required this.answer});
  factory _PromptAnswer.fromJson(Map<String, dynamic> json) => _$PromptAnswerFromJson(json);

@override final  String promptId;
@override final  String answer;

/// Create a copy of PromptAnswer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PromptAnswerCopyWith<_PromptAnswer> get copyWith => __$PromptAnswerCopyWithImpl<_PromptAnswer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PromptAnswerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PromptAnswer&&(identical(other.promptId, promptId) || other.promptId == promptId)&&(identical(other.answer, answer) || other.answer == answer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,promptId,answer);

@override
String toString() {
  return 'PromptAnswer(promptId: $promptId, answer: $answer)';
}


}

/// @nodoc
abstract mixin class _$PromptAnswerCopyWith<$Res> implements $PromptAnswerCopyWith<$Res> {
  factory _$PromptAnswerCopyWith(_PromptAnswer value, $Res Function(_PromptAnswer) _then) = __$PromptAnswerCopyWithImpl;
@override @useResult
$Res call({
 String promptId, String answer
});




}
/// @nodoc
class __$PromptAnswerCopyWithImpl<$Res>
    implements _$PromptAnswerCopyWith<$Res> {
  __$PromptAnswerCopyWithImpl(this._self, this._then);

  final _PromptAnswer _self;
  final $Res Function(_PromptAnswer) _then;

/// Create a copy of PromptAnswer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? promptId = null,Object? answer = null,}) {
  return _then(_PromptAnswer(
promptId: null == promptId ? _self.promptId : promptId // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$VoiceIntro {

 String get path; int get durationSec;
/// Create a copy of VoiceIntro
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoiceIntroCopyWith<VoiceIntro> get copyWith => _$VoiceIntroCopyWithImpl<VoiceIntro>(this as VoiceIntro, _$identity);

  /// Serializes this VoiceIntro to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoiceIntro&&(identical(other.path, path) || other.path == path)&&(identical(other.durationSec, durationSec) || other.durationSec == durationSec));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,path,durationSec);

@override
String toString() {
  return 'VoiceIntro(path: $path, durationSec: $durationSec)';
}


}

/// @nodoc
abstract mixin class $VoiceIntroCopyWith<$Res>  {
  factory $VoiceIntroCopyWith(VoiceIntro value, $Res Function(VoiceIntro) _then) = _$VoiceIntroCopyWithImpl;
@useResult
$Res call({
 String path, int durationSec
});




}
/// @nodoc
class _$VoiceIntroCopyWithImpl<$Res>
    implements $VoiceIntroCopyWith<$Res> {
  _$VoiceIntroCopyWithImpl(this._self, this._then);

  final VoiceIntro _self;
  final $Res Function(VoiceIntro) _then;

/// Create a copy of VoiceIntro
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? durationSec = null,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,durationSec: null == durationSec ? _self.durationSec : durationSec // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [VoiceIntro].
extension VoiceIntroPatterns on VoiceIntro {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoiceIntro value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoiceIntro() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoiceIntro value)  $default,){
final _that = this;
switch (_that) {
case _VoiceIntro():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoiceIntro value)?  $default,){
final _that = this;
switch (_that) {
case _VoiceIntro() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  int durationSec)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoiceIntro() when $default != null:
return $default(_that.path,_that.durationSec);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  int durationSec)  $default,) {final _that = this;
switch (_that) {
case _VoiceIntro():
return $default(_that.path,_that.durationSec);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  int durationSec)?  $default,) {final _that = this;
switch (_that) {
case _VoiceIntro() when $default != null:
return $default(_that.path,_that.durationSec);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoiceIntro implements VoiceIntro {
  const _VoiceIntro({required this.path, required this.durationSec});
  factory _VoiceIntro.fromJson(Map<String, dynamic> json) => _$VoiceIntroFromJson(json);

@override final  String path;
@override final  int durationSec;

/// Create a copy of VoiceIntro
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoiceIntroCopyWith<_VoiceIntro> get copyWith => __$VoiceIntroCopyWithImpl<_VoiceIntro>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoiceIntroToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoiceIntro&&(identical(other.path, path) || other.path == path)&&(identical(other.durationSec, durationSec) || other.durationSec == durationSec));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,path,durationSec);

@override
String toString() {
  return 'VoiceIntro(path: $path, durationSec: $durationSec)';
}


}

/// @nodoc
abstract mixin class _$VoiceIntroCopyWith<$Res> implements $VoiceIntroCopyWith<$Res> {
  factory _$VoiceIntroCopyWith(_VoiceIntro value, $Res Function(_VoiceIntro) _then) = __$VoiceIntroCopyWithImpl;
@override @useResult
$Res call({
 String path, int durationSec
});




}
/// @nodoc
class __$VoiceIntroCopyWithImpl<$Res>
    implements _$VoiceIntroCopyWith<$Res> {
  __$VoiceIntroCopyWithImpl(this._self, this._then);

  final _VoiceIntro _self;
  final $Res Function(_VoiceIntro) _then;

/// Create a copy of VoiceIntro
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? durationSec = null,}) {
  return _then(_VoiceIntro(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,durationSec: null == durationSec ? _self.durationSec : durationSec // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CompanionSummary {

 String get uid; String get displayName; int get ageYears; List<String> get photoPaths; String get about; List<String> get activityTags; List<String> get planTypes; int get ratingCount; int get meetupCount; int get distanceKm; int get spotsNearby;/// Only when the companion chose to show it.
 String? get gender; PromptAnswer? get prompt; VoiceIntro? get voiceIntro; double? get ratingAvg; DateTime? get freeNowUntil;/// The free window for "Tonight" / "Tomorrow" in Free right now.
 DateTime? get freeFrom; DateTime? get freeUntil;/// City, languages, interests, lifestyle and personality, when filled in.
 ProfileDetails get details;
/// Create a copy of CompanionSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompanionSummaryCopyWith<CompanionSummary> get copyWith => _$CompanionSummaryCopyWithImpl<CompanionSummary>(this as CompanionSummary, _$identity);

  /// Serializes this CompanionSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompanionSummary&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.ageYears, ageYears) || other.ageYears == ageYears)&&const DeepCollectionEquality().equals(other.photoPaths, photoPaths)&&(identical(other.about, about) || other.about == about)&&const DeepCollectionEquality().equals(other.activityTags, activityTags)&&const DeepCollectionEquality().equals(other.planTypes, planTypes)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.meetupCount, meetupCount) || other.meetupCount == meetupCount)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.spotsNearby, spotsNearby) || other.spotsNearby == spotsNearby)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.voiceIntro, voiceIntro) || other.voiceIntro == voiceIntro)&&(identical(other.ratingAvg, ratingAvg) || other.ratingAvg == ratingAvg)&&(identical(other.freeNowUntil, freeNowUntil) || other.freeNowUntil == freeNowUntil)&&(identical(other.freeFrom, freeFrom) || other.freeFrom == freeFrom)&&(identical(other.freeUntil, freeUntil) || other.freeUntil == freeUntil)&&(identical(other.details, details) || other.details == details));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,displayName,ageYears,const DeepCollectionEquality().hash(photoPaths),about,const DeepCollectionEquality().hash(activityTags),const DeepCollectionEquality().hash(planTypes),ratingCount,meetupCount,distanceKm,spotsNearby,gender,prompt,voiceIntro,ratingAvg,freeNowUntil,freeFrom,freeUntil,details]);

@override
String toString() {
  return 'CompanionSummary(uid: $uid, displayName: $displayName, ageYears: $ageYears, photoPaths: $photoPaths, about: $about, activityTags: $activityTags, planTypes: $planTypes, ratingCount: $ratingCount, meetupCount: $meetupCount, distanceKm: $distanceKm, spotsNearby: $spotsNearby, gender: $gender, prompt: $prompt, voiceIntro: $voiceIntro, ratingAvg: $ratingAvg, freeNowUntil: $freeNowUntil, freeFrom: $freeFrom, freeUntil: $freeUntil, details: $details)';
}


}

/// @nodoc
abstract mixin class $CompanionSummaryCopyWith<$Res>  {
  factory $CompanionSummaryCopyWith(CompanionSummary value, $Res Function(CompanionSummary) _then) = _$CompanionSummaryCopyWithImpl;
@useResult
$Res call({
 String uid, String displayName, int ageYears, List<String> photoPaths, String about, List<String> activityTags, List<String> planTypes, int ratingCount, int meetupCount, int distanceKm, int spotsNearby, String? gender, PromptAnswer? prompt, VoiceIntro? voiceIntro, double? ratingAvg, DateTime? freeNowUntil, DateTime? freeFrom, DateTime? freeUntil, ProfileDetails details
});


$PromptAnswerCopyWith<$Res>? get prompt;$VoiceIntroCopyWith<$Res>? get voiceIntro;$ProfileDetailsCopyWith<$Res> get details;

}
/// @nodoc
class _$CompanionSummaryCopyWithImpl<$Res>
    implements $CompanionSummaryCopyWith<$Res> {
  _$CompanionSummaryCopyWithImpl(this._self, this._then);

  final CompanionSummary _self;
  final $Res Function(CompanionSummary) _then;

/// Create a copy of CompanionSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? displayName = null,Object? ageYears = null,Object? photoPaths = null,Object? about = null,Object? activityTags = null,Object? planTypes = null,Object? ratingCount = null,Object? meetupCount = null,Object? distanceKm = null,Object? spotsNearby = null,Object? gender = freezed,Object? prompt = freezed,Object? voiceIntro = freezed,Object? ratingAvg = freezed,Object? freeNowUntil = freezed,Object? freeFrom = freezed,Object? freeUntil = freezed,Object? details = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,ageYears: null == ageYears ? _self.ageYears : ageYears // ignore: cast_nullable_to_non_nullable
as int,photoPaths: null == photoPaths ? _self.photoPaths : photoPaths // ignore: cast_nullable_to_non_nullable
as List<String>,about: null == about ? _self.about : about // ignore: cast_nullable_to_non_nullable
as String,activityTags: null == activityTags ? _self.activityTags : activityTags // ignore: cast_nullable_to_non_nullable
as List<String>,planTypes: null == planTypes ? _self.planTypes : planTypes // ignore: cast_nullable_to_non_nullable
as List<String>,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,meetupCount: null == meetupCount ? _self.meetupCount : meetupCount // ignore: cast_nullable_to_non_nullable
as int,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as int,spotsNearby: null == spotsNearby ? _self.spotsNearby : spotsNearby // ignore: cast_nullable_to_non_nullable
as int,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,prompt: freezed == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as PromptAnswer?,voiceIntro: freezed == voiceIntro ? _self.voiceIntro : voiceIntro // ignore: cast_nullable_to_non_nullable
as VoiceIntro?,ratingAvg: freezed == ratingAvg ? _self.ratingAvg : ratingAvg // ignore: cast_nullable_to_non_nullable
as double?,freeNowUntil: freezed == freeNowUntil ? _self.freeNowUntil : freeNowUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,freeFrom: freezed == freeFrom ? _self.freeFrom : freeFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,freeUntil: freezed == freeUntil ? _self.freeUntil : freeUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as ProfileDetails,
  ));
}
/// Create a copy of CompanionSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PromptAnswerCopyWith<$Res>? get prompt {
    if (_self.prompt == null) {
    return null;
  }

  return $PromptAnswerCopyWith<$Res>(_self.prompt!, (value) {
    return _then(_self.copyWith(prompt: value));
  });
}/// Create a copy of CompanionSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VoiceIntroCopyWith<$Res>? get voiceIntro {
    if (_self.voiceIntro == null) {
    return null;
  }

  return $VoiceIntroCopyWith<$Res>(_self.voiceIntro!, (value) {
    return _then(_self.copyWith(voiceIntro: value));
  });
}/// Create a copy of CompanionSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileDetailsCopyWith<$Res> get details {
  
  return $ProfileDetailsCopyWith<$Res>(_self.details, (value) {
    return _then(_self.copyWith(details: value));
  });
}
}


/// Adds pattern-matching-related methods to [CompanionSummary].
extension CompanionSummaryPatterns on CompanionSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompanionSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompanionSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompanionSummary value)  $default,){
final _that = this;
switch (_that) {
case _CompanionSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompanionSummary value)?  $default,){
final _that = this;
switch (_that) {
case _CompanionSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String displayName,  int ageYears,  List<String> photoPaths,  String about,  List<String> activityTags,  List<String> planTypes,  int ratingCount,  int meetupCount,  int distanceKm,  int spotsNearby,  String? gender,  PromptAnswer? prompt,  VoiceIntro? voiceIntro,  double? ratingAvg,  DateTime? freeNowUntil,  DateTime? freeFrom,  DateTime? freeUntil,  ProfileDetails details)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompanionSummary() when $default != null:
return $default(_that.uid,_that.displayName,_that.ageYears,_that.photoPaths,_that.about,_that.activityTags,_that.planTypes,_that.ratingCount,_that.meetupCount,_that.distanceKm,_that.spotsNearby,_that.gender,_that.prompt,_that.voiceIntro,_that.ratingAvg,_that.freeNowUntil,_that.freeFrom,_that.freeUntil,_that.details);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String displayName,  int ageYears,  List<String> photoPaths,  String about,  List<String> activityTags,  List<String> planTypes,  int ratingCount,  int meetupCount,  int distanceKm,  int spotsNearby,  String? gender,  PromptAnswer? prompt,  VoiceIntro? voiceIntro,  double? ratingAvg,  DateTime? freeNowUntil,  DateTime? freeFrom,  DateTime? freeUntil,  ProfileDetails details)  $default,) {final _that = this;
switch (_that) {
case _CompanionSummary():
return $default(_that.uid,_that.displayName,_that.ageYears,_that.photoPaths,_that.about,_that.activityTags,_that.planTypes,_that.ratingCount,_that.meetupCount,_that.distanceKm,_that.spotsNearby,_that.gender,_that.prompt,_that.voiceIntro,_that.ratingAvg,_that.freeNowUntil,_that.freeFrom,_that.freeUntil,_that.details);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String displayName,  int ageYears,  List<String> photoPaths,  String about,  List<String> activityTags,  List<String> planTypes,  int ratingCount,  int meetupCount,  int distanceKm,  int spotsNearby,  String? gender,  PromptAnswer? prompt,  VoiceIntro? voiceIntro,  double? ratingAvg,  DateTime? freeNowUntil,  DateTime? freeFrom,  DateTime? freeUntil,  ProfileDetails details)?  $default,) {final _that = this;
switch (_that) {
case _CompanionSummary() when $default != null:
return $default(_that.uid,_that.displayName,_that.ageYears,_that.photoPaths,_that.about,_that.activityTags,_that.planTypes,_that.ratingCount,_that.meetupCount,_that.distanceKm,_that.spotsNearby,_that.gender,_that.prompt,_that.voiceIntro,_that.ratingAvg,_that.freeNowUntil,_that.freeFrom,_that.freeUntil,_that.details);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CompanionSummary implements CompanionSummary {
  const _CompanionSummary({required this.uid, required this.displayName, required this.ageYears, required final  List<String> photoPaths, required this.about, required final  List<String> activityTags, required final  List<String> planTypes, required this.ratingCount, required this.meetupCount, required this.distanceKm, required this.spotsNearby, this.gender, this.prompt, this.voiceIntro, this.ratingAvg, this.freeNowUntil, this.freeFrom, this.freeUntil, this.details = ProfileDetails.empty}): _photoPaths = photoPaths,_activityTags = activityTags,_planTypes = planTypes;
  factory _CompanionSummary.fromJson(Map<String, dynamic> json) => _$CompanionSummaryFromJson(json);

@override final  String uid;
@override final  String displayName;
@override final  int ageYears;
 final  List<String> _photoPaths;
@override List<String> get photoPaths {
  if (_photoPaths is EqualUnmodifiableListView) return _photoPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photoPaths);
}

@override final  String about;
 final  List<String> _activityTags;
@override List<String> get activityTags {
  if (_activityTags is EqualUnmodifiableListView) return _activityTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_activityTags);
}

 final  List<String> _planTypes;
@override List<String> get planTypes {
  if (_planTypes is EqualUnmodifiableListView) return _planTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_planTypes);
}

@override final  int ratingCount;
@override final  int meetupCount;
@override final  int distanceKm;
@override final  int spotsNearby;
/// Only when the companion chose to show it.
@override final  String? gender;
@override final  PromptAnswer? prompt;
@override final  VoiceIntro? voiceIntro;
@override final  double? ratingAvg;
@override final  DateTime? freeNowUntil;
/// The free window for "Tonight" / "Tomorrow" in Free right now.
@override final  DateTime? freeFrom;
@override final  DateTime? freeUntil;
/// City, languages, interests, lifestyle and personality, when filled in.
@override@JsonKey() final  ProfileDetails details;

/// Create a copy of CompanionSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompanionSummaryCopyWith<_CompanionSummary> get copyWith => __$CompanionSummaryCopyWithImpl<_CompanionSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompanionSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompanionSummary&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.ageYears, ageYears) || other.ageYears == ageYears)&&const DeepCollectionEquality().equals(other._photoPaths, _photoPaths)&&(identical(other.about, about) || other.about == about)&&const DeepCollectionEquality().equals(other._activityTags, _activityTags)&&const DeepCollectionEquality().equals(other._planTypes, _planTypes)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.meetupCount, meetupCount) || other.meetupCount == meetupCount)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.spotsNearby, spotsNearby) || other.spotsNearby == spotsNearby)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.voiceIntro, voiceIntro) || other.voiceIntro == voiceIntro)&&(identical(other.ratingAvg, ratingAvg) || other.ratingAvg == ratingAvg)&&(identical(other.freeNowUntil, freeNowUntil) || other.freeNowUntil == freeNowUntil)&&(identical(other.freeFrom, freeFrom) || other.freeFrom == freeFrom)&&(identical(other.freeUntil, freeUntil) || other.freeUntil == freeUntil)&&(identical(other.details, details) || other.details == details));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,displayName,ageYears,const DeepCollectionEquality().hash(_photoPaths),about,const DeepCollectionEquality().hash(_activityTags),const DeepCollectionEquality().hash(_planTypes),ratingCount,meetupCount,distanceKm,spotsNearby,gender,prompt,voiceIntro,ratingAvg,freeNowUntil,freeFrom,freeUntil,details]);

@override
String toString() {
  return 'CompanionSummary(uid: $uid, displayName: $displayName, ageYears: $ageYears, photoPaths: $photoPaths, about: $about, activityTags: $activityTags, planTypes: $planTypes, ratingCount: $ratingCount, meetupCount: $meetupCount, distanceKm: $distanceKm, spotsNearby: $spotsNearby, gender: $gender, prompt: $prompt, voiceIntro: $voiceIntro, ratingAvg: $ratingAvg, freeNowUntil: $freeNowUntil, freeFrom: $freeFrom, freeUntil: $freeUntil, details: $details)';
}


}

/// @nodoc
abstract mixin class _$CompanionSummaryCopyWith<$Res> implements $CompanionSummaryCopyWith<$Res> {
  factory _$CompanionSummaryCopyWith(_CompanionSummary value, $Res Function(_CompanionSummary) _then) = __$CompanionSummaryCopyWithImpl;
@override @useResult
$Res call({
 String uid, String displayName, int ageYears, List<String> photoPaths, String about, List<String> activityTags, List<String> planTypes, int ratingCount, int meetupCount, int distanceKm, int spotsNearby, String? gender, PromptAnswer? prompt, VoiceIntro? voiceIntro, double? ratingAvg, DateTime? freeNowUntil, DateTime? freeFrom, DateTime? freeUntil, ProfileDetails details
});


@override $PromptAnswerCopyWith<$Res>? get prompt;@override $VoiceIntroCopyWith<$Res>? get voiceIntro;@override $ProfileDetailsCopyWith<$Res> get details;

}
/// @nodoc
class __$CompanionSummaryCopyWithImpl<$Res>
    implements _$CompanionSummaryCopyWith<$Res> {
  __$CompanionSummaryCopyWithImpl(this._self, this._then);

  final _CompanionSummary _self;
  final $Res Function(_CompanionSummary) _then;

/// Create a copy of CompanionSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? displayName = null,Object? ageYears = null,Object? photoPaths = null,Object? about = null,Object? activityTags = null,Object? planTypes = null,Object? ratingCount = null,Object? meetupCount = null,Object? distanceKm = null,Object? spotsNearby = null,Object? gender = freezed,Object? prompt = freezed,Object? voiceIntro = freezed,Object? ratingAvg = freezed,Object? freeNowUntil = freezed,Object? freeFrom = freezed,Object? freeUntil = freezed,Object? details = null,}) {
  return _then(_CompanionSummary(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,ageYears: null == ageYears ? _self.ageYears : ageYears // ignore: cast_nullable_to_non_nullable
as int,photoPaths: null == photoPaths ? _self._photoPaths : photoPaths // ignore: cast_nullable_to_non_nullable
as List<String>,about: null == about ? _self.about : about // ignore: cast_nullable_to_non_nullable
as String,activityTags: null == activityTags ? _self._activityTags : activityTags // ignore: cast_nullable_to_non_nullable
as List<String>,planTypes: null == planTypes ? _self._planTypes : planTypes // ignore: cast_nullable_to_non_nullable
as List<String>,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,meetupCount: null == meetupCount ? _self.meetupCount : meetupCount // ignore: cast_nullable_to_non_nullable
as int,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as int,spotsNearby: null == spotsNearby ? _self.spotsNearby : spotsNearby // ignore: cast_nullable_to_non_nullable
as int,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,prompt: freezed == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as PromptAnswer?,voiceIntro: freezed == voiceIntro ? _self.voiceIntro : voiceIntro // ignore: cast_nullable_to_non_nullable
as VoiceIntro?,ratingAvg: freezed == ratingAvg ? _self.ratingAvg : ratingAvg // ignore: cast_nullable_to_non_nullable
as double?,freeNowUntil: freezed == freeNowUntil ? _self.freeNowUntil : freeNowUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,freeFrom: freezed == freeFrom ? _self.freeFrom : freeFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,freeUntil: freezed == freeUntil ? _self.freeUntil : freeUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as ProfileDetails,
  ));
}

/// Create a copy of CompanionSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PromptAnswerCopyWith<$Res>? get prompt {
    if (_self.prompt == null) {
    return null;
  }

  return $PromptAnswerCopyWith<$Res>(_self.prompt!, (value) {
    return _then(_self.copyWith(prompt: value));
  });
}/// Create a copy of CompanionSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VoiceIntroCopyWith<$Res>? get voiceIntro {
    if (_self.voiceIntro == null) {
    return null;
  }

  return $VoiceIntroCopyWith<$Res>(_self.voiceIntro!, (value) {
    return _then(_self.copyWith(voiceIntro: value));
  });
}/// Create a copy of CompanionSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileDetailsCopyWith<$Res> get details {
  
  return $ProfileDetailsCopyWith<$Res>(_self.details, (value) {
    return _then(_self.copyWith(details: value));
  });
}
}

// dart format on
