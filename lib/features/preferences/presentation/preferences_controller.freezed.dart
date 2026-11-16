// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preferences_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PreferencesDraft {

 int get ageMin; int get ageMax; Gender? get gender; ShowMe get showMe; bool get showGender; bool get saving; AppFailure? get failure;
/// Create a copy of PreferencesDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PreferencesDraftCopyWith<PreferencesDraft> get copyWith => _$PreferencesDraftCopyWithImpl<PreferencesDraft>(this as PreferencesDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PreferencesDraft&&(identical(other.ageMin, ageMin) || other.ageMin == ageMin)&&(identical(other.ageMax, ageMax) || other.ageMax == ageMax)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.showMe, showMe) || other.showMe == showMe)&&(identical(other.showGender, showGender) || other.showGender == showGender)&&(identical(other.saving, saving) || other.saving == saving)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,ageMin,ageMax,gender,showMe,showGender,saving,failure);

@override
String toString() {
  return 'PreferencesDraft(ageMin: $ageMin, ageMax: $ageMax, gender: $gender, showMe: $showMe, showGender: $showGender, saving: $saving, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $PreferencesDraftCopyWith<$Res>  {
  factory $PreferencesDraftCopyWith(PreferencesDraft value, $Res Function(PreferencesDraft) _then) = _$PreferencesDraftCopyWithImpl;
@useResult
$Res call({
 int ageMin, int ageMax, Gender? gender, ShowMe showMe, bool showGender, bool saving, AppFailure? failure
});




}
/// @nodoc
class _$PreferencesDraftCopyWithImpl<$Res>
    implements $PreferencesDraftCopyWith<$Res> {
  _$PreferencesDraftCopyWithImpl(this._self, this._then);

  final PreferencesDraft _self;
  final $Res Function(PreferencesDraft) _then;

/// Create a copy of PreferencesDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ageMin = null,Object? ageMax = null,Object? gender = freezed,Object? showMe = null,Object? showGender = null,Object? saving = null,Object? failure = freezed,}) {
  return _then(_self.copyWith(
ageMin: null == ageMin ? _self.ageMin : ageMin // ignore: cast_nullable_to_non_nullable
as int,ageMax: null == ageMax ? _self.ageMax : ageMax // ignore: cast_nullable_to_non_nullable
as int,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,showMe: null == showMe ? _self.showMe : showMe // ignore: cast_nullable_to_non_nullable
as ShowMe,showGender: null == showGender ? _self.showGender : showGender // ignore: cast_nullable_to_non_nullable
as bool,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [PreferencesDraft].
extension PreferencesDraftPatterns on PreferencesDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PreferencesDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PreferencesDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PreferencesDraft value)  $default,){
final _that = this;
switch (_that) {
case _PreferencesDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PreferencesDraft value)?  $default,){
final _that = this;
switch (_that) {
case _PreferencesDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int ageMin,  int ageMax,  Gender? gender,  ShowMe showMe,  bool showGender,  bool saving,  AppFailure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PreferencesDraft() when $default != null:
return $default(_that.ageMin,_that.ageMax,_that.gender,_that.showMe,_that.showGender,_that.saving,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int ageMin,  int ageMax,  Gender? gender,  ShowMe showMe,  bool showGender,  bool saving,  AppFailure? failure)  $default,) {final _that = this;
switch (_that) {
case _PreferencesDraft():
return $default(_that.ageMin,_that.ageMax,_that.gender,_that.showMe,_that.showGender,_that.saving,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int ageMin,  int ageMax,  Gender? gender,  ShowMe showMe,  bool showGender,  bool saving,  AppFailure? failure)?  $default,) {final _that = this;
switch (_that) {
case _PreferencesDraft() when $default != null:
return $default(_that.ageMin,_that.ageMax,_that.gender,_that.showMe,_that.showGender,_that.saving,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _PreferencesDraft extends PreferencesDraft {
  const _PreferencesDraft({required this.ageMin, required this.ageMax, this.gender, this.showMe = ShowMe.everyone, this.showGender = false, this.saving = false, this.failure}): super._();
  

@override final  int ageMin;
@override final  int ageMax;
@override final  Gender? gender;
@override@JsonKey() final  ShowMe showMe;
@override@JsonKey() final  bool showGender;
@override@JsonKey() final  bool saving;
@override final  AppFailure? failure;

/// Create a copy of PreferencesDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PreferencesDraftCopyWith<_PreferencesDraft> get copyWith => __$PreferencesDraftCopyWithImpl<_PreferencesDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PreferencesDraft&&(identical(other.ageMin, ageMin) || other.ageMin == ageMin)&&(identical(other.ageMax, ageMax) || other.ageMax == ageMax)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.showMe, showMe) || other.showMe == showMe)&&(identical(other.showGender, showGender) || other.showGender == showGender)&&(identical(other.saving, saving) || other.saving == saving)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,ageMin,ageMax,gender,showMe,showGender,saving,failure);

@override
String toString() {
  return 'PreferencesDraft(ageMin: $ageMin, ageMax: $ageMax, gender: $gender, showMe: $showMe, showGender: $showGender, saving: $saving, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$PreferencesDraftCopyWith<$Res> implements $PreferencesDraftCopyWith<$Res> {
  factory _$PreferencesDraftCopyWith(_PreferencesDraft value, $Res Function(_PreferencesDraft) _then) = __$PreferencesDraftCopyWithImpl;
@override @useResult
$Res call({
 int ageMin, int ageMax, Gender? gender, ShowMe showMe, bool showGender, bool saving, AppFailure? failure
});




}
/// @nodoc
class __$PreferencesDraftCopyWithImpl<$Res>
    implements _$PreferencesDraftCopyWith<$Res> {
  __$PreferencesDraftCopyWithImpl(this._self, this._then);

  final _PreferencesDraft _self;
  final $Res Function(_PreferencesDraft) _then;

/// Create a copy of PreferencesDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ageMin = null,Object? ageMax = null,Object? gender = freezed,Object? showMe = null,Object? showGender = null,Object? saving = null,Object? failure = freezed,}) {
  return _then(_PreferencesDraft(
ageMin: null == ageMin ? _self.ageMin : ageMin // ignore: cast_nullable_to_non_nullable
as int,ageMax: null == ageMax ? _self.ageMax : ageMax // ignore: cast_nullable_to_non_nullable
as int,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,showMe: null == showMe ? _self.showMe : showMe // ignore: cast_nullable_to_non_nullable
as ShowMe,showGender: null == showGender ? _self.showGender : showGender // ignore: cast_nullable_to_non_nullable
as bool,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

// dart format on
