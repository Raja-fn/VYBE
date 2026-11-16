// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discover_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DiscoverState {

 PlanType get plan;/// Companions skipped in this session, per plan.
 Set<String> get skipped;
/// Create a copy of DiscoverState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscoverStateCopyWith<DiscoverState> get copyWith => _$DiscoverStateCopyWithImpl<DiscoverState>(this as DiscoverState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscoverState&&(identical(other.plan, plan) || other.plan == plan)&&const DeepCollectionEquality().equals(other.skipped, skipped));
}


@override
int get hashCode => Object.hash(runtimeType,plan,const DeepCollectionEquality().hash(skipped));

@override
String toString() {
  return 'DiscoverState(plan: $plan, skipped: $skipped)';
}


}

/// @nodoc
abstract mixin class $DiscoverStateCopyWith<$Res>  {
  factory $DiscoverStateCopyWith(DiscoverState value, $Res Function(DiscoverState) _then) = _$DiscoverStateCopyWithImpl;
@useResult
$Res call({
 PlanType plan, Set<String> skipped
});




}
/// @nodoc
class _$DiscoverStateCopyWithImpl<$Res>
    implements $DiscoverStateCopyWith<$Res> {
  _$DiscoverStateCopyWithImpl(this._self, this._then);

  final DiscoverState _self;
  final $Res Function(DiscoverState) _then;

/// Create a copy of DiscoverState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? plan = null,Object? skipped = null,}) {
  return _then(_self.copyWith(
plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as PlanType,skipped: null == skipped ? _self.skipped : skipped // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [DiscoverState].
extension DiscoverStatePatterns on DiscoverState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiscoverState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiscoverState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiscoverState value)  $default,){
final _that = this;
switch (_that) {
case _DiscoverState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiscoverState value)?  $default,){
final _that = this;
switch (_that) {
case _DiscoverState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PlanType plan,  Set<String> skipped)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiscoverState() when $default != null:
return $default(_that.plan,_that.skipped);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PlanType plan,  Set<String> skipped)  $default,) {final _that = this;
switch (_that) {
case _DiscoverState():
return $default(_that.plan,_that.skipped);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PlanType plan,  Set<String> skipped)?  $default,) {final _that = this;
switch (_that) {
case _DiscoverState() when $default != null:
return $default(_that.plan,_that.skipped);case _:
  return null;

}
}

}

/// @nodoc


class _DiscoverState implements DiscoverState {
  const _DiscoverState({this.plan = PlanType.coffee, final  Set<String> skipped = const <String>{}}): _skipped = skipped;
  

@override@JsonKey() final  PlanType plan;
/// Companions skipped in this session, per plan.
 final  Set<String> _skipped;
/// Companions skipped in this session, per plan.
@override@JsonKey() Set<String> get skipped {
  if (_skipped is EqualUnmodifiableSetView) return _skipped;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_skipped);
}


/// Create a copy of DiscoverState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiscoverStateCopyWith<_DiscoverState> get copyWith => __$DiscoverStateCopyWithImpl<_DiscoverState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiscoverState&&(identical(other.plan, plan) || other.plan == plan)&&const DeepCollectionEquality().equals(other._skipped, _skipped));
}


@override
int get hashCode => Object.hash(runtimeType,plan,const DeepCollectionEquality().hash(_skipped));

@override
String toString() {
  return 'DiscoverState(plan: $plan, skipped: $skipped)';
}


}

/// @nodoc
abstract mixin class _$DiscoverStateCopyWith<$Res> implements $DiscoverStateCopyWith<$Res> {
  factory _$DiscoverStateCopyWith(_DiscoverState value, $Res Function(_DiscoverState) _then) = __$DiscoverStateCopyWithImpl;
@override @useResult
$Res call({
 PlanType plan, Set<String> skipped
});




}
/// @nodoc
class __$DiscoverStateCopyWithImpl<$Res>
    implements _$DiscoverStateCopyWith<$Res> {
  __$DiscoverStateCopyWithImpl(this._self, this._then);

  final _DiscoverState _self;
  final $Res Function(_DiscoverState) _then;

/// Create a copy of DiscoverState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? plan = null,Object? skipped = null,}) {
  return _then(_DiscoverState(
plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as PlanType,skipped: null == skipped ? _self._skipped : skipped // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}

// dart format on
