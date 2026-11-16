// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Preferences {

 Gender get gender; ShowMe get showMe; int get ageMin; int get ageMax; bool get showGender; WhoCanRequest get whoCanRequest;
/// Create a copy of Preferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PreferencesCopyWith<Preferences> get copyWith => _$PreferencesCopyWithImpl<Preferences>(this as Preferences, _$identity);

  /// Serializes this Preferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Preferences&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.showMe, showMe) || other.showMe == showMe)&&(identical(other.ageMin, ageMin) || other.ageMin == ageMin)&&(identical(other.ageMax, ageMax) || other.ageMax == ageMax)&&(identical(other.showGender, showGender) || other.showGender == showGender)&&(identical(other.whoCanRequest, whoCanRequest) || other.whoCanRequest == whoCanRequest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gender,showMe,ageMin,ageMax,showGender,whoCanRequest);

@override
String toString() {
  return 'Preferences(gender: $gender, showMe: $showMe, ageMin: $ageMin, ageMax: $ageMax, showGender: $showGender, whoCanRequest: $whoCanRequest)';
}


}

/// @nodoc
abstract mixin class $PreferencesCopyWith<$Res>  {
  factory $PreferencesCopyWith(Preferences value, $Res Function(Preferences) _then) = _$PreferencesCopyWithImpl;
@useResult
$Res call({
 Gender gender, ShowMe showMe, int ageMin, int ageMax, bool showGender, WhoCanRequest whoCanRequest
});




}
/// @nodoc
class _$PreferencesCopyWithImpl<$Res>
    implements $PreferencesCopyWith<$Res> {
  _$PreferencesCopyWithImpl(this._self, this._then);

  final Preferences _self;
  final $Res Function(Preferences) _then;

/// Create a copy of Preferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? gender = null,Object? showMe = null,Object? ageMin = null,Object? ageMax = null,Object? showGender = null,Object? whoCanRequest = null,}) {
  return _then(_self.copyWith(
gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,showMe: null == showMe ? _self.showMe : showMe // ignore: cast_nullable_to_non_nullable
as ShowMe,ageMin: null == ageMin ? _self.ageMin : ageMin // ignore: cast_nullable_to_non_nullable
as int,ageMax: null == ageMax ? _self.ageMax : ageMax // ignore: cast_nullable_to_non_nullable
as int,showGender: null == showGender ? _self.showGender : showGender // ignore: cast_nullable_to_non_nullable
as bool,whoCanRequest: null == whoCanRequest ? _self.whoCanRequest : whoCanRequest // ignore: cast_nullable_to_non_nullable
as WhoCanRequest,
  ));
}

}


/// Adds pattern-matching-related methods to [Preferences].
extension PreferencesPatterns on Preferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Preferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Preferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Preferences value)  $default,){
final _that = this;
switch (_that) {
case _Preferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Preferences value)?  $default,){
final _that = this;
switch (_that) {
case _Preferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Gender gender,  ShowMe showMe,  int ageMin,  int ageMax,  bool showGender,  WhoCanRequest whoCanRequest)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Preferences() when $default != null:
return $default(_that.gender,_that.showMe,_that.ageMin,_that.ageMax,_that.showGender,_that.whoCanRequest);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Gender gender,  ShowMe showMe,  int ageMin,  int ageMax,  bool showGender,  WhoCanRequest whoCanRequest)  $default,) {final _that = this;
switch (_that) {
case _Preferences():
return $default(_that.gender,_that.showMe,_that.ageMin,_that.ageMax,_that.showGender,_that.whoCanRequest);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Gender gender,  ShowMe showMe,  int ageMin,  int ageMax,  bool showGender,  WhoCanRequest whoCanRequest)?  $default,) {final _that = this;
switch (_that) {
case _Preferences() when $default != null:
return $default(_that.gender,_that.showMe,_that.ageMin,_that.ageMax,_that.showGender,_that.whoCanRequest);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Preferences implements Preferences {
  const _Preferences({required this.gender, required this.showMe, required this.ageMin, required this.ageMax, required this.showGender, required this.whoCanRequest});
  factory _Preferences.fromJson(Map<String, dynamic> json) => _$PreferencesFromJson(json);

@override final  Gender gender;
@override final  ShowMe showMe;
@override final  int ageMin;
@override final  int ageMax;
@override final  bool showGender;
@override final  WhoCanRequest whoCanRequest;

/// Create a copy of Preferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PreferencesCopyWith<_Preferences> get copyWith => __$PreferencesCopyWithImpl<_Preferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Preferences&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.showMe, showMe) || other.showMe == showMe)&&(identical(other.ageMin, ageMin) || other.ageMin == ageMin)&&(identical(other.ageMax, ageMax) || other.ageMax == ageMax)&&(identical(other.showGender, showGender) || other.showGender == showGender)&&(identical(other.whoCanRequest, whoCanRequest) || other.whoCanRequest == whoCanRequest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gender,showMe,ageMin,ageMax,showGender,whoCanRequest);

@override
String toString() {
  return 'Preferences(gender: $gender, showMe: $showMe, ageMin: $ageMin, ageMax: $ageMax, showGender: $showGender, whoCanRequest: $whoCanRequest)';
}


}

/// @nodoc
abstract mixin class _$PreferencesCopyWith<$Res> implements $PreferencesCopyWith<$Res> {
  factory _$PreferencesCopyWith(_Preferences value, $Res Function(_Preferences) _then) = __$PreferencesCopyWithImpl;
@override @useResult
$Res call({
 Gender gender, ShowMe showMe, int ageMin, int ageMax, bool showGender, WhoCanRequest whoCanRequest
});




}
/// @nodoc
class __$PreferencesCopyWithImpl<$Res>
    implements _$PreferencesCopyWith<$Res> {
  __$PreferencesCopyWithImpl(this._self, this._then);

  final _Preferences _self;
  final $Res Function(_Preferences) _then;

/// Create a copy of Preferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gender = null,Object? showMe = null,Object? ageMin = null,Object? ageMax = null,Object? showGender = null,Object? whoCanRequest = null,}) {
  return _then(_Preferences(
gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,showMe: null == showMe ? _self.showMe : showMe // ignore: cast_nullable_to_non_nullable
as ShowMe,ageMin: null == ageMin ? _self.ageMin : ageMin // ignore: cast_nullable_to_non_nullable
as int,ageMax: null == ageMax ? _self.ageMax : ageMax // ignore: cast_nullable_to_non_nullable
as int,showGender: null == showGender ? _self.showGender : showGender // ignore: cast_nullable_to_non_nullable
as bool,whoCanRequest: null == whoCanRequest ? _self.whoCanRequest : whoCanRequest // ignore: cast_nullable_to_non_nullable
as WhoCanRequest,
  ));
}


}

// dart format on
