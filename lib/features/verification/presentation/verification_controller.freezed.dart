// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verification_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VerificationFlowState {

 String? get phoneE164; String? get verificationId; int? get resendToken; DateTime? get codeSentAt; IdDocumentType? get documentType; bool get busy; bool get phoneInvalid; bool get codeInvalid; AppFailure? get failure;
/// Create a copy of VerificationFlowState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerificationFlowStateCopyWith<VerificationFlowState> get copyWith => _$VerificationFlowStateCopyWithImpl<VerificationFlowState>(this as VerificationFlowState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationFlowState&&(identical(other.phoneE164, phoneE164) || other.phoneE164 == phoneE164)&&(identical(other.verificationId, verificationId) || other.verificationId == verificationId)&&(identical(other.resendToken, resendToken) || other.resendToken == resendToken)&&(identical(other.codeSentAt, codeSentAt) || other.codeSentAt == codeSentAt)&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.phoneInvalid, phoneInvalid) || other.phoneInvalid == phoneInvalid)&&(identical(other.codeInvalid, codeInvalid) || other.codeInvalid == codeInvalid)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,phoneE164,verificationId,resendToken,codeSentAt,documentType,busy,phoneInvalid,codeInvalid,failure);

@override
String toString() {
  return 'VerificationFlowState(phoneE164: $phoneE164, verificationId: $verificationId, resendToken: $resendToken, codeSentAt: $codeSentAt, documentType: $documentType, busy: $busy, phoneInvalid: $phoneInvalid, codeInvalid: $codeInvalid, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $VerificationFlowStateCopyWith<$Res>  {
  factory $VerificationFlowStateCopyWith(VerificationFlowState value, $Res Function(VerificationFlowState) _then) = _$VerificationFlowStateCopyWithImpl;
@useResult
$Res call({
 String? phoneE164, String? verificationId, int? resendToken, DateTime? codeSentAt, IdDocumentType? documentType, bool busy, bool phoneInvalid, bool codeInvalid, AppFailure? failure
});




}
/// @nodoc
class _$VerificationFlowStateCopyWithImpl<$Res>
    implements $VerificationFlowStateCopyWith<$Res> {
  _$VerificationFlowStateCopyWithImpl(this._self, this._then);

  final VerificationFlowState _self;
  final $Res Function(VerificationFlowState) _then;

/// Create a copy of VerificationFlowState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phoneE164 = freezed,Object? verificationId = freezed,Object? resendToken = freezed,Object? codeSentAt = freezed,Object? documentType = freezed,Object? busy = null,Object? phoneInvalid = null,Object? codeInvalid = null,Object? failure = freezed,}) {
  return _then(_self.copyWith(
phoneE164: freezed == phoneE164 ? _self.phoneE164 : phoneE164 // ignore: cast_nullable_to_non_nullable
as String?,verificationId: freezed == verificationId ? _self.verificationId : verificationId // ignore: cast_nullable_to_non_nullable
as String?,resendToken: freezed == resendToken ? _self.resendToken : resendToken // ignore: cast_nullable_to_non_nullable
as int?,codeSentAt: freezed == codeSentAt ? _self.codeSentAt : codeSentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,documentType: freezed == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as IdDocumentType?,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,phoneInvalid: null == phoneInvalid ? _self.phoneInvalid : phoneInvalid // ignore: cast_nullable_to_non_nullable
as bool,codeInvalid: null == codeInvalid ? _self.codeInvalid : codeInvalid // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [VerificationFlowState].
extension VerificationFlowStatePatterns on VerificationFlowState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerificationFlowState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerificationFlowState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerificationFlowState value)  $default,){
final _that = this;
switch (_that) {
case _VerificationFlowState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerificationFlowState value)?  $default,){
final _that = this;
switch (_that) {
case _VerificationFlowState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? phoneE164,  String? verificationId,  int? resendToken,  DateTime? codeSentAt,  IdDocumentType? documentType,  bool busy,  bool phoneInvalid,  bool codeInvalid,  AppFailure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerificationFlowState() when $default != null:
return $default(_that.phoneE164,_that.verificationId,_that.resendToken,_that.codeSentAt,_that.documentType,_that.busy,_that.phoneInvalid,_that.codeInvalid,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? phoneE164,  String? verificationId,  int? resendToken,  DateTime? codeSentAt,  IdDocumentType? documentType,  bool busy,  bool phoneInvalid,  bool codeInvalid,  AppFailure? failure)  $default,) {final _that = this;
switch (_that) {
case _VerificationFlowState():
return $default(_that.phoneE164,_that.verificationId,_that.resendToken,_that.codeSentAt,_that.documentType,_that.busy,_that.phoneInvalid,_that.codeInvalid,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? phoneE164,  String? verificationId,  int? resendToken,  DateTime? codeSentAt,  IdDocumentType? documentType,  bool busy,  bool phoneInvalid,  bool codeInvalid,  AppFailure? failure)?  $default,) {final _that = this;
switch (_that) {
case _VerificationFlowState() when $default != null:
return $default(_that.phoneE164,_that.verificationId,_that.resendToken,_that.codeSentAt,_that.documentType,_that.busy,_that.phoneInvalid,_that.codeInvalid,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _VerificationFlowState extends VerificationFlowState {
  const _VerificationFlowState({this.phoneE164, this.verificationId, this.resendToken, this.codeSentAt, this.documentType, this.busy = false, this.phoneInvalid = false, this.codeInvalid = false, this.failure}): super._();
  

@override final  String? phoneE164;
@override final  String? verificationId;
@override final  int? resendToken;
@override final  DateTime? codeSentAt;
@override final  IdDocumentType? documentType;
@override@JsonKey() final  bool busy;
@override@JsonKey() final  bool phoneInvalid;
@override@JsonKey() final  bool codeInvalid;
@override final  AppFailure? failure;

/// Create a copy of VerificationFlowState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerificationFlowStateCopyWith<_VerificationFlowState> get copyWith => __$VerificationFlowStateCopyWithImpl<_VerificationFlowState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerificationFlowState&&(identical(other.phoneE164, phoneE164) || other.phoneE164 == phoneE164)&&(identical(other.verificationId, verificationId) || other.verificationId == verificationId)&&(identical(other.resendToken, resendToken) || other.resendToken == resendToken)&&(identical(other.codeSentAt, codeSentAt) || other.codeSentAt == codeSentAt)&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.phoneInvalid, phoneInvalid) || other.phoneInvalid == phoneInvalid)&&(identical(other.codeInvalid, codeInvalid) || other.codeInvalid == codeInvalid)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,phoneE164,verificationId,resendToken,codeSentAt,documentType,busy,phoneInvalid,codeInvalid,failure);

@override
String toString() {
  return 'VerificationFlowState(phoneE164: $phoneE164, verificationId: $verificationId, resendToken: $resendToken, codeSentAt: $codeSentAt, documentType: $documentType, busy: $busy, phoneInvalid: $phoneInvalid, codeInvalid: $codeInvalid, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$VerificationFlowStateCopyWith<$Res> implements $VerificationFlowStateCopyWith<$Res> {
  factory _$VerificationFlowStateCopyWith(_VerificationFlowState value, $Res Function(_VerificationFlowState) _then) = __$VerificationFlowStateCopyWithImpl;
@override @useResult
$Res call({
 String? phoneE164, String? verificationId, int? resendToken, DateTime? codeSentAt, IdDocumentType? documentType, bool busy, bool phoneInvalid, bool codeInvalid, AppFailure? failure
});




}
/// @nodoc
class __$VerificationFlowStateCopyWithImpl<$Res>
    implements _$VerificationFlowStateCopyWith<$Res> {
  __$VerificationFlowStateCopyWithImpl(this._self, this._then);

  final _VerificationFlowState _self;
  final $Res Function(_VerificationFlowState) _then;

/// Create a copy of VerificationFlowState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phoneE164 = freezed,Object? verificationId = freezed,Object? resendToken = freezed,Object? codeSentAt = freezed,Object? documentType = freezed,Object? busy = null,Object? phoneInvalid = null,Object? codeInvalid = null,Object? failure = freezed,}) {
  return _then(_VerificationFlowState(
phoneE164: freezed == phoneE164 ? _self.phoneE164 : phoneE164 // ignore: cast_nullable_to_non_nullable
as String?,verificationId: freezed == verificationId ? _self.verificationId : verificationId // ignore: cast_nullable_to_non_nullable
as String?,resendToken: freezed == resendToken ? _self.resendToken : resendToken // ignore: cast_nullable_to_non_nullable
as int?,codeSentAt: freezed == codeSentAt ? _self.codeSentAt : codeSentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,documentType: freezed == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as IdDocumentType?,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,phoneInvalid: null == phoneInvalid ? _self.phoneInvalid : phoneInvalid // ignore: cast_nullable_to_non_nullable
as bool,codeInvalid: null == codeInvalid ? _self.codeInvalid : codeInvalid // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

// dart format on
