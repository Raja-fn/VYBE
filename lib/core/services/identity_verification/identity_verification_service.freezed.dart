// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'identity_verification_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IdvSession {

 String get id; IdvStep get step; DateTime get expiresAt;/// Cloud Storage path the capture must be uploaded to.
 String get uploadPath;
/// Create a copy of IdvSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IdvSessionCopyWith<IdvSession> get copyWith => _$IdvSessionCopyWithImpl<IdvSession>(this as IdvSession, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IdvSession&&(identical(other.id, id) || other.id == id)&&(identical(other.step, step) || other.step == step)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.uploadPath, uploadPath) || other.uploadPath == uploadPath));
}


@override
int get hashCode => Object.hash(runtimeType,id,step,expiresAt,uploadPath);

@override
String toString() {
  return 'IdvSession(id: $id, step: $step, expiresAt: $expiresAt, uploadPath: $uploadPath)';
}


}

/// @nodoc
abstract mixin class $IdvSessionCopyWith<$Res>  {
  factory $IdvSessionCopyWith(IdvSession value, $Res Function(IdvSession) _then) = _$IdvSessionCopyWithImpl;
@useResult
$Res call({
 String id, IdvStep step, DateTime expiresAt, String uploadPath
});




}
/// @nodoc
class _$IdvSessionCopyWithImpl<$Res>
    implements $IdvSessionCopyWith<$Res> {
  _$IdvSessionCopyWithImpl(this._self, this._then);

  final IdvSession _self;
  final $Res Function(IdvSession) _then;

/// Create a copy of IdvSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? step = null,Object? expiresAt = null,Object? uploadPath = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as IdvStep,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,uploadPath: null == uploadPath ? _self.uploadPath : uploadPath // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [IdvSession].
extension IdvSessionPatterns on IdvSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IdvSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IdvSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IdvSession value)  $default,){
final _that = this;
switch (_that) {
case _IdvSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IdvSession value)?  $default,){
final _that = this;
switch (_that) {
case _IdvSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  IdvStep step,  DateTime expiresAt,  String uploadPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IdvSession() when $default != null:
return $default(_that.id,_that.step,_that.expiresAt,_that.uploadPath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  IdvStep step,  DateTime expiresAt,  String uploadPath)  $default,) {final _that = this;
switch (_that) {
case _IdvSession():
return $default(_that.id,_that.step,_that.expiresAt,_that.uploadPath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  IdvStep step,  DateTime expiresAt,  String uploadPath)?  $default,) {final _that = this;
switch (_that) {
case _IdvSession() when $default != null:
return $default(_that.id,_that.step,_that.expiresAt,_that.uploadPath);case _:
  return null;

}
}

}

/// @nodoc


class _IdvSession implements IdvSession {
  const _IdvSession({required this.id, required this.step, required this.expiresAt, required this.uploadPath});
  

@override final  String id;
@override final  IdvStep step;
@override final  DateTime expiresAt;
/// Cloud Storage path the capture must be uploaded to.
@override final  String uploadPath;

/// Create a copy of IdvSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IdvSessionCopyWith<_IdvSession> get copyWith => __$IdvSessionCopyWithImpl<_IdvSession>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IdvSession&&(identical(other.id, id) || other.id == id)&&(identical(other.step, step) || other.step == step)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.uploadPath, uploadPath) || other.uploadPath == uploadPath));
}


@override
int get hashCode => Object.hash(runtimeType,id,step,expiresAt,uploadPath);

@override
String toString() {
  return 'IdvSession(id: $id, step: $step, expiresAt: $expiresAt, uploadPath: $uploadPath)';
}


}

/// @nodoc
abstract mixin class _$IdvSessionCopyWith<$Res> implements $IdvSessionCopyWith<$Res> {
  factory _$IdvSessionCopyWith(_IdvSession value, $Res Function(_IdvSession) _then) = __$IdvSessionCopyWithImpl;
@override @useResult
$Res call({
 String id, IdvStep step, DateTime expiresAt, String uploadPath
});




}
/// @nodoc
class __$IdvSessionCopyWithImpl<$Res>
    implements _$IdvSessionCopyWith<$Res> {
  __$IdvSessionCopyWithImpl(this._self, this._then);

  final _IdvSession _self;
  final $Res Function(_IdvSession) _then;

/// Create a copy of IdvSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? step = null,Object? expiresAt = null,Object? uploadPath = null,}) {
  return _then(_IdvSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as IdvStep,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,uploadPath: null == uploadPath ? _self.uploadPath : uploadPath // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$IdvOutcome {

 IdvStatus get stepStatus;/// True once every verification step is approved.
 bool get accountApproved;/// Server reason code for a rejection, e.g. "underage".
 String? get reason;
/// Create a copy of IdvOutcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IdvOutcomeCopyWith<IdvOutcome> get copyWith => _$IdvOutcomeCopyWithImpl<IdvOutcome>(this as IdvOutcome, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IdvOutcome&&(identical(other.stepStatus, stepStatus) || other.stepStatus == stepStatus)&&(identical(other.accountApproved, accountApproved) || other.accountApproved == accountApproved)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,stepStatus,accountApproved,reason);

@override
String toString() {
  return 'IdvOutcome(stepStatus: $stepStatus, accountApproved: $accountApproved, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $IdvOutcomeCopyWith<$Res>  {
  factory $IdvOutcomeCopyWith(IdvOutcome value, $Res Function(IdvOutcome) _then) = _$IdvOutcomeCopyWithImpl;
@useResult
$Res call({
 IdvStatus stepStatus, bool accountApproved, String? reason
});




}
/// @nodoc
class _$IdvOutcomeCopyWithImpl<$Res>
    implements $IdvOutcomeCopyWith<$Res> {
  _$IdvOutcomeCopyWithImpl(this._self, this._then);

  final IdvOutcome _self;
  final $Res Function(IdvOutcome) _then;

/// Create a copy of IdvOutcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stepStatus = null,Object? accountApproved = null,Object? reason = freezed,}) {
  return _then(_self.copyWith(
stepStatus: null == stepStatus ? _self.stepStatus : stepStatus // ignore: cast_nullable_to_non_nullable
as IdvStatus,accountApproved: null == accountApproved ? _self.accountApproved : accountApproved // ignore: cast_nullable_to_non_nullable
as bool,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [IdvOutcome].
extension IdvOutcomePatterns on IdvOutcome {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IdvOutcome value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IdvOutcome() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IdvOutcome value)  $default,){
final _that = this;
switch (_that) {
case _IdvOutcome():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IdvOutcome value)?  $default,){
final _that = this;
switch (_that) {
case _IdvOutcome() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( IdvStatus stepStatus,  bool accountApproved,  String? reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IdvOutcome() when $default != null:
return $default(_that.stepStatus,_that.accountApproved,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( IdvStatus stepStatus,  bool accountApproved,  String? reason)  $default,) {final _that = this;
switch (_that) {
case _IdvOutcome():
return $default(_that.stepStatus,_that.accountApproved,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( IdvStatus stepStatus,  bool accountApproved,  String? reason)?  $default,) {final _that = this;
switch (_that) {
case _IdvOutcome() when $default != null:
return $default(_that.stepStatus,_that.accountApproved,_that.reason);case _:
  return null;

}
}

}

/// @nodoc


class _IdvOutcome implements IdvOutcome {
  const _IdvOutcome({required this.stepStatus, required this.accountApproved, this.reason});
  

@override final  IdvStatus stepStatus;
/// True once every verification step is approved.
@override final  bool accountApproved;
/// Server reason code for a rejection, e.g. "underage".
@override final  String? reason;

/// Create a copy of IdvOutcome
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IdvOutcomeCopyWith<_IdvOutcome> get copyWith => __$IdvOutcomeCopyWithImpl<_IdvOutcome>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IdvOutcome&&(identical(other.stepStatus, stepStatus) || other.stepStatus == stepStatus)&&(identical(other.accountApproved, accountApproved) || other.accountApproved == accountApproved)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,stepStatus,accountApproved,reason);

@override
String toString() {
  return 'IdvOutcome(stepStatus: $stepStatus, accountApproved: $accountApproved, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$IdvOutcomeCopyWith<$Res> implements $IdvOutcomeCopyWith<$Res> {
  factory _$IdvOutcomeCopyWith(_IdvOutcome value, $Res Function(_IdvOutcome) _then) = __$IdvOutcomeCopyWithImpl;
@override @useResult
$Res call({
 IdvStatus stepStatus, bool accountApproved, String? reason
});




}
/// @nodoc
class __$IdvOutcomeCopyWithImpl<$Res>
    implements _$IdvOutcomeCopyWith<$Res> {
  __$IdvOutcomeCopyWithImpl(this._self, this._then);

  final _IdvOutcome _self;
  final $Res Function(_IdvOutcome) _then;

/// Create a copy of IdvOutcome
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stepStatus = null,Object? accountApproved = null,Object? reason = freezed,}) {
  return _then(_IdvOutcome(
stepStatus: null == stepStatus ? _self.stepStatus : stepStatus // ignore: cast_nullable_to_non_nullable
as IdvStatus,accountApproved: null == accountApproved ? _self.accountApproved : accountApproved // ignore: cast_nullable_to_non_nullable
as bool,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
