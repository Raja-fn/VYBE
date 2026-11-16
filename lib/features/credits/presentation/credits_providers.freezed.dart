// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credits_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PurchaseNotice {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseNotice);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PurchaseNotice()';
}


}

/// @nodoc
class $PurchaseNoticeCopyWith<$Res>  {
$PurchaseNoticeCopyWith(PurchaseNotice _, $Res Function(PurchaseNotice) __);
}


/// Adds pattern-matching-related methods to [PurchaseNotice].
extension PurchaseNoticePatterns on PurchaseNotice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CreditsAddedNotice value)?  creditsAdded,TResult Function( PlanActiveNotice value)?  planActive,TResult Function( PlanAtRenewalNotice value)?  planAtRenewal,TResult Function( AlreadyAddedNotice value)?  alreadyAdded,TResult Function( PendingNotice value)?  pending,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CreditsAddedNotice() when creditsAdded != null:
return creditsAdded(_that);case PlanActiveNotice() when planActive != null:
return planActive(_that);case PlanAtRenewalNotice() when planAtRenewal != null:
return planAtRenewal(_that);case AlreadyAddedNotice() when alreadyAdded != null:
return alreadyAdded(_that);case PendingNotice() when pending != null:
return pending(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CreditsAddedNotice value)  creditsAdded,required TResult Function( PlanActiveNotice value)  planActive,required TResult Function( PlanAtRenewalNotice value)  planAtRenewal,required TResult Function( AlreadyAddedNotice value)  alreadyAdded,required TResult Function( PendingNotice value)  pending,}){
final _that = this;
switch (_that) {
case CreditsAddedNotice():
return creditsAdded(_that);case PlanActiveNotice():
return planActive(_that);case PlanAtRenewalNotice():
return planAtRenewal(_that);case AlreadyAddedNotice():
return alreadyAdded(_that);case PendingNotice():
return pending(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CreditsAddedNotice value)?  creditsAdded,TResult? Function( PlanActiveNotice value)?  planActive,TResult? Function( PlanAtRenewalNotice value)?  planAtRenewal,TResult? Function( AlreadyAddedNotice value)?  alreadyAdded,TResult? Function( PendingNotice value)?  pending,}){
final _that = this;
switch (_that) {
case CreditsAddedNotice() when creditsAdded != null:
return creditsAdded(_that);case PlanActiveNotice() when planActive != null:
return planActive(_that);case PlanAtRenewalNotice() when planAtRenewal != null:
return planAtRenewal(_that);case AlreadyAddedNotice() when alreadyAdded != null:
return alreadyAdded(_that);case PendingNotice() when pending != null:
return pending(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int credits)?  creditsAdded,TResult Function( PlanTier tier,  int credits)?  planActive,TResult Function( PlanTier tier)?  planAtRenewal,TResult Function()?  alreadyAdded,TResult Function()?  pending,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CreditsAddedNotice() when creditsAdded != null:
return creditsAdded(_that.credits);case PlanActiveNotice() when planActive != null:
return planActive(_that.tier,_that.credits);case PlanAtRenewalNotice() when planAtRenewal != null:
return planAtRenewal(_that.tier);case AlreadyAddedNotice() when alreadyAdded != null:
return alreadyAdded();case PendingNotice() when pending != null:
return pending();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int credits)  creditsAdded,required TResult Function( PlanTier tier,  int credits)  planActive,required TResult Function( PlanTier tier)  planAtRenewal,required TResult Function()  alreadyAdded,required TResult Function()  pending,}) {final _that = this;
switch (_that) {
case CreditsAddedNotice():
return creditsAdded(_that.credits);case PlanActiveNotice():
return planActive(_that.tier,_that.credits);case PlanAtRenewalNotice():
return planAtRenewal(_that.tier);case AlreadyAddedNotice():
return alreadyAdded();case PendingNotice():
return pending();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int credits)?  creditsAdded,TResult? Function( PlanTier tier,  int credits)?  planActive,TResult? Function( PlanTier tier)?  planAtRenewal,TResult? Function()?  alreadyAdded,TResult? Function()?  pending,}) {final _that = this;
switch (_that) {
case CreditsAddedNotice() when creditsAdded != null:
return creditsAdded(_that.credits);case PlanActiveNotice() when planActive != null:
return planActive(_that.tier,_that.credits);case PlanAtRenewalNotice() when planAtRenewal != null:
return planAtRenewal(_that.tier);case AlreadyAddedNotice() when alreadyAdded != null:
return alreadyAdded();case PendingNotice() when pending != null:
return pending();case _:
  return null;

}
}

}

/// @nodoc


class CreditsAddedNotice implements PurchaseNotice {
  const CreditsAddedNotice(this.credits);
  

 final  int credits;

/// Create a copy of PurchaseNotice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreditsAddedNoticeCopyWith<CreditsAddedNotice> get copyWith => _$CreditsAddedNoticeCopyWithImpl<CreditsAddedNotice>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreditsAddedNotice&&(identical(other.credits, credits) || other.credits == credits));
}


@override
int get hashCode => Object.hash(runtimeType,credits);

@override
String toString() {
  return 'PurchaseNotice.creditsAdded(credits: $credits)';
}


}

/// @nodoc
abstract mixin class $CreditsAddedNoticeCopyWith<$Res> implements $PurchaseNoticeCopyWith<$Res> {
  factory $CreditsAddedNoticeCopyWith(CreditsAddedNotice value, $Res Function(CreditsAddedNotice) _then) = _$CreditsAddedNoticeCopyWithImpl;
@useResult
$Res call({
 int credits
});




}
/// @nodoc
class _$CreditsAddedNoticeCopyWithImpl<$Res>
    implements $CreditsAddedNoticeCopyWith<$Res> {
  _$CreditsAddedNoticeCopyWithImpl(this._self, this._then);

  final CreditsAddedNotice _self;
  final $Res Function(CreditsAddedNotice) _then;

/// Create a copy of PurchaseNotice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? credits = null,}) {
  return _then(CreditsAddedNotice(
null == credits ? _self.credits : credits // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class PlanActiveNotice implements PurchaseNotice {
  const PlanActiveNotice(this.tier, this.credits);
  

 final  PlanTier tier;
 final  int credits;

/// Create a copy of PurchaseNotice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlanActiveNoticeCopyWith<PlanActiveNotice> get copyWith => _$PlanActiveNoticeCopyWithImpl<PlanActiveNotice>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlanActiveNotice&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.credits, credits) || other.credits == credits));
}


@override
int get hashCode => Object.hash(runtimeType,tier,credits);

@override
String toString() {
  return 'PurchaseNotice.planActive(tier: $tier, credits: $credits)';
}


}

/// @nodoc
abstract mixin class $PlanActiveNoticeCopyWith<$Res> implements $PurchaseNoticeCopyWith<$Res> {
  factory $PlanActiveNoticeCopyWith(PlanActiveNotice value, $Res Function(PlanActiveNotice) _then) = _$PlanActiveNoticeCopyWithImpl;
@useResult
$Res call({
 PlanTier tier, int credits
});




}
/// @nodoc
class _$PlanActiveNoticeCopyWithImpl<$Res>
    implements $PlanActiveNoticeCopyWith<$Res> {
  _$PlanActiveNoticeCopyWithImpl(this._self, this._then);

  final PlanActiveNotice _self;
  final $Res Function(PlanActiveNotice) _then;

/// Create a copy of PurchaseNotice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? tier = null,Object? credits = null,}) {
  return _then(PlanActiveNotice(
null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as PlanTier,null == credits ? _self.credits : credits // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class PlanAtRenewalNotice implements PurchaseNotice {
  const PlanAtRenewalNotice(this.tier);
  

 final  PlanTier tier;

/// Create a copy of PurchaseNotice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlanAtRenewalNoticeCopyWith<PlanAtRenewalNotice> get copyWith => _$PlanAtRenewalNoticeCopyWithImpl<PlanAtRenewalNotice>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlanAtRenewalNotice&&(identical(other.tier, tier) || other.tier == tier));
}


@override
int get hashCode => Object.hash(runtimeType,tier);

@override
String toString() {
  return 'PurchaseNotice.planAtRenewal(tier: $tier)';
}


}

/// @nodoc
abstract mixin class $PlanAtRenewalNoticeCopyWith<$Res> implements $PurchaseNoticeCopyWith<$Res> {
  factory $PlanAtRenewalNoticeCopyWith(PlanAtRenewalNotice value, $Res Function(PlanAtRenewalNotice) _then) = _$PlanAtRenewalNoticeCopyWithImpl;
@useResult
$Res call({
 PlanTier tier
});




}
/// @nodoc
class _$PlanAtRenewalNoticeCopyWithImpl<$Res>
    implements $PlanAtRenewalNoticeCopyWith<$Res> {
  _$PlanAtRenewalNoticeCopyWithImpl(this._self, this._then);

  final PlanAtRenewalNotice _self;
  final $Res Function(PlanAtRenewalNotice) _then;

/// Create a copy of PurchaseNotice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? tier = null,}) {
  return _then(PlanAtRenewalNotice(
null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as PlanTier,
  ));
}


}

/// @nodoc


class AlreadyAddedNotice implements PurchaseNotice {
  const AlreadyAddedNotice();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlreadyAddedNotice);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PurchaseNotice.alreadyAdded()';
}


}




/// @nodoc


class PendingNotice implements PurchaseNotice {
  const PendingNotice();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingNotice);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PurchaseNotice.pending()';
}


}




/// @nodoc
mixin _$PurchaseFlowState {

/// The product waiting on the store or the server.
 String? get busyProductId; PurchaseNotice? get notice; AppFailure? get failure;/// A paid purchase the server could not confirm yet (e.g. offline).
 StorePurchase? get unconfirmed;
/// Create a copy of PurchaseFlowState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseFlowStateCopyWith<PurchaseFlowState> get copyWith => _$PurchaseFlowStateCopyWithImpl<PurchaseFlowState>(this as PurchaseFlowState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseFlowState&&(identical(other.busyProductId, busyProductId) || other.busyProductId == busyProductId)&&(identical(other.notice, notice) || other.notice == notice)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.unconfirmed, unconfirmed) || other.unconfirmed == unconfirmed));
}


@override
int get hashCode => Object.hash(runtimeType,busyProductId,notice,failure,unconfirmed);

@override
String toString() {
  return 'PurchaseFlowState(busyProductId: $busyProductId, notice: $notice, failure: $failure, unconfirmed: $unconfirmed)';
}


}

/// @nodoc
abstract mixin class $PurchaseFlowStateCopyWith<$Res>  {
  factory $PurchaseFlowStateCopyWith(PurchaseFlowState value, $Res Function(PurchaseFlowState) _then) = _$PurchaseFlowStateCopyWithImpl;
@useResult
$Res call({
 String? busyProductId, PurchaseNotice? notice, AppFailure? failure, StorePurchase? unconfirmed
});


$PurchaseNoticeCopyWith<$Res>? get notice;

}
/// @nodoc
class _$PurchaseFlowStateCopyWithImpl<$Res>
    implements $PurchaseFlowStateCopyWith<$Res> {
  _$PurchaseFlowStateCopyWithImpl(this._self, this._then);

  final PurchaseFlowState _self;
  final $Res Function(PurchaseFlowState) _then;

/// Create a copy of PurchaseFlowState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? busyProductId = freezed,Object? notice = freezed,Object? failure = freezed,Object? unconfirmed = freezed,}) {
  return _then(_self.copyWith(
busyProductId: freezed == busyProductId ? _self.busyProductId : busyProductId // ignore: cast_nullable_to_non_nullable
as String?,notice: freezed == notice ? _self.notice : notice // ignore: cast_nullable_to_non_nullable
as PurchaseNotice?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure?,unconfirmed: freezed == unconfirmed ? _self.unconfirmed : unconfirmed // ignore: cast_nullable_to_non_nullable
as StorePurchase?,
  ));
}
/// Create a copy of PurchaseFlowState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PurchaseNoticeCopyWith<$Res>? get notice {
    if (_self.notice == null) {
    return null;
  }

  return $PurchaseNoticeCopyWith<$Res>(_self.notice!, (value) {
    return _then(_self.copyWith(notice: value));
  });
}
}


/// Adds pattern-matching-related methods to [PurchaseFlowState].
extension PurchaseFlowStatePatterns on PurchaseFlowState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseFlowState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseFlowState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseFlowState value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseFlowState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseFlowState value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseFlowState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? busyProductId,  PurchaseNotice? notice,  AppFailure? failure,  StorePurchase? unconfirmed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseFlowState() when $default != null:
return $default(_that.busyProductId,_that.notice,_that.failure,_that.unconfirmed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? busyProductId,  PurchaseNotice? notice,  AppFailure? failure,  StorePurchase? unconfirmed)  $default,) {final _that = this;
switch (_that) {
case _PurchaseFlowState():
return $default(_that.busyProductId,_that.notice,_that.failure,_that.unconfirmed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? busyProductId,  PurchaseNotice? notice,  AppFailure? failure,  StorePurchase? unconfirmed)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseFlowState() when $default != null:
return $default(_that.busyProductId,_that.notice,_that.failure,_that.unconfirmed);case _:
  return null;

}
}

}

/// @nodoc


class _PurchaseFlowState implements PurchaseFlowState {
  const _PurchaseFlowState({this.busyProductId, this.notice, this.failure, this.unconfirmed});
  

/// The product waiting on the store or the server.
@override final  String? busyProductId;
@override final  PurchaseNotice? notice;
@override final  AppFailure? failure;
/// A paid purchase the server could not confirm yet (e.g. offline).
@override final  StorePurchase? unconfirmed;

/// Create a copy of PurchaseFlowState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseFlowStateCopyWith<_PurchaseFlowState> get copyWith => __$PurchaseFlowStateCopyWithImpl<_PurchaseFlowState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseFlowState&&(identical(other.busyProductId, busyProductId) || other.busyProductId == busyProductId)&&(identical(other.notice, notice) || other.notice == notice)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.unconfirmed, unconfirmed) || other.unconfirmed == unconfirmed));
}


@override
int get hashCode => Object.hash(runtimeType,busyProductId,notice,failure,unconfirmed);

@override
String toString() {
  return 'PurchaseFlowState(busyProductId: $busyProductId, notice: $notice, failure: $failure, unconfirmed: $unconfirmed)';
}


}

/// @nodoc
abstract mixin class _$PurchaseFlowStateCopyWith<$Res> implements $PurchaseFlowStateCopyWith<$Res> {
  factory _$PurchaseFlowStateCopyWith(_PurchaseFlowState value, $Res Function(_PurchaseFlowState) _then) = __$PurchaseFlowStateCopyWithImpl;
@override @useResult
$Res call({
 String? busyProductId, PurchaseNotice? notice, AppFailure? failure, StorePurchase? unconfirmed
});


@override $PurchaseNoticeCopyWith<$Res>? get notice;

}
/// @nodoc
class __$PurchaseFlowStateCopyWithImpl<$Res>
    implements _$PurchaseFlowStateCopyWith<$Res> {
  __$PurchaseFlowStateCopyWithImpl(this._self, this._then);

  final _PurchaseFlowState _self;
  final $Res Function(_PurchaseFlowState) _then;

/// Create a copy of PurchaseFlowState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? busyProductId = freezed,Object? notice = freezed,Object? failure = freezed,Object? unconfirmed = freezed,}) {
  return _then(_PurchaseFlowState(
busyProductId: freezed == busyProductId ? _self.busyProductId : busyProductId // ignore: cast_nullable_to_non_nullable
as String?,notice: freezed == notice ? _self.notice : notice // ignore: cast_nullable_to_non_nullable
as PurchaseNotice?,failure: freezed == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as AppFailure?,unconfirmed: freezed == unconfirmed ? _self.unconfirmed : unconfirmed // ignore: cast_nullable_to_non_nullable
as StorePurchase?,
  ));
}

/// Create a copy of PurchaseFlowState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PurchaseNoticeCopyWith<$Res>? get notice {
    if (_self.notice == null) {
    return null;
  }

  return $PurchaseNoticeCopyWith<$Res>(_self.notice!, (value) {
    return _then(_self.copyWith(notice: value));
  });
}
}

// dart format on
