// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BookSpotState {

 String get requestId; DateTime get day; String? get venueId; String? get slotId; bool get submitting; bool get sent; AppFailure? get failure;
/// Create a copy of BookSpotState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookSpotStateCopyWith<BookSpotState> get copyWith => _$BookSpotStateCopyWithImpl<BookSpotState>(this as BookSpotState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookSpotState&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.day, day) || other.day == day)&&(identical(other.venueId, venueId) || other.venueId == venueId)&&(identical(other.slotId, slotId) || other.slotId == slotId)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.sent, sent) || other.sent == sent)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,requestId,day,venueId,slotId,submitting,sent,failure);

@override
String toString() {
  return 'BookSpotState(requestId: $requestId, day: $day, venueId: $venueId, slotId: $slotId, submitting: $submitting, sent: $sent, failure: $failure)';
}


}

/// @nodoc
abstract mixin class $BookSpotStateCopyWith<$Res>  {
  factory $BookSpotStateCopyWith(BookSpotState value, $Res Function(BookSpotState) _then) = _$BookSpotStateCopyWithImpl;
@useResult
$Res call({
 String requestId, DateTime day, String? venueId, String? slotId, bool submitting, bool sent, AppFailure? failure
});




}
/// @nodoc
class _$BookSpotStateCopyWithImpl<$Res>
    implements $BookSpotStateCopyWith<$Res> {
  _$BookSpotStateCopyWithImpl(this._self, this._then);

  final BookSpotState _self;
  final $Res Function(BookSpotState) _then;

/// Create a copy of BookSpotState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requestId = null,Object? day = null,Object? venueId = freezed,Object? slotId = freezed,Object? submitting = null,Object? sent = null,Object? failure = freezed,}) {
  return _then(_self.copyWith(
requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as DateTime,venueId: freezed == venueId ? _self.venueId : venueId // ignore: cast_nullable_to_non_nullable
as String?,slotId: freezed == slotId ? _self.slotId : slotId // ignore: cast_nullable_to_non_nullable
as String?,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,sent: null == sent ? _self.sent : sent // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}

}


/// Adds pattern-matching-related methods to [BookSpotState].
extension BookSpotStatePatterns on BookSpotState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookSpotState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookSpotState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookSpotState value)  $default,){
final _that = this;
switch (_that) {
case _BookSpotState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookSpotState value)?  $default,){
final _that = this;
switch (_that) {
case _BookSpotState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String requestId,  DateTime day,  String? venueId,  String? slotId,  bool submitting,  bool sent,  AppFailure? failure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookSpotState() when $default != null:
return $default(_that.requestId,_that.day,_that.venueId,_that.slotId,_that.submitting,_that.sent,_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String requestId,  DateTime day,  String? venueId,  String? slotId,  bool submitting,  bool sent,  AppFailure? failure)  $default,) {final _that = this;
switch (_that) {
case _BookSpotState():
return $default(_that.requestId,_that.day,_that.venueId,_that.slotId,_that.submitting,_that.sent,_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String requestId,  DateTime day,  String? venueId,  String? slotId,  bool submitting,  bool sent,  AppFailure? failure)?  $default,) {final _that = this;
switch (_that) {
case _BookSpotState() when $default != null:
return $default(_that.requestId,_that.day,_that.venueId,_that.slotId,_that.submitting,_that.sent,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _BookSpotState implements BookSpotState {
  const _BookSpotState({required this.requestId, required this.day, this.venueId, this.slotId, this.submitting = false, this.sent = false, this.failure});
  

@override final  String requestId;
@override final  DateTime day;
@override final  String? venueId;
@override final  String? slotId;
@override@JsonKey() final  bool submitting;
@override@JsonKey() final  bool sent;
@override final  AppFailure? failure;

/// Create a copy of BookSpotState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookSpotStateCopyWith<_BookSpotState> get copyWith => __$BookSpotStateCopyWithImpl<_BookSpotState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookSpotState&&(identical(other.requestId, requestId) || other.requestId == requestId)&&(identical(other.day, day) || other.day == day)&&(identical(other.venueId, venueId) || other.venueId == venueId)&&(identical(other.slotId, slotId) || other.slotId == slotId)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.sent, sent) || other.sent == sent)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,requestId,day,venueId,slotId,submitting,sent,failure);

@override
String toString() {
  return 'BookSpotState(requestId: $requestId, day: $day, venueId: $venueId, slotId: $slotId, submitting: $submitting, sent: $sent, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$BookSpotStateCopyWith<$Res> implements $BookSpotStateCopyWith<$Res> {
  factory _$BookSpotStateCopyWith(_BookSpotState value, $Res Function(_BookSpotState) _then) = __$BookSpotStateCopyWithImpl;
@override @useResult
$Res call({
 String requestId, DateTime day, String? venueId, String? slotId, bool submitting, bool sent, AppFailure? failure
});




}
/// @nodoc
class __$BookSpotStateCopyWithImpl<$Res>
    implements _$BookSpotStateCopyWith<$Res> {
  __$BookSpotStateCopyWithImpl(this._self, this._then);

  final _BookSpotState _self;
  final $Res Function(_BookSpotState) _then;

/// Create a copy of BookSpotState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requestId = null,Object? day = null,Object? venueId = freezed,Object? slotId = freezed,Object? submitting = null,Object? sent = null,Object? failure = freezed,}) {
  return _then(_BookSpotState(
requestId: null == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as DateTime,venueId: freezed == venueId ? _self.venueId : venueId // ignore: cast_nullable_to_non_nullable
as String?,slotId: freezed == slotId ? _self.slotId : slotId // ignore: cast_nullable_to_non_nullable
as String?,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,sent: null == sent ? _self.sent : sent // ignore: cast_nullable_to_non_nullable
as bool,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure?,
  ));
}


}

// dart format on
