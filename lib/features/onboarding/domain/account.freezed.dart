// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VerificationSteps {

@JsonKey(unknownEnumValue: StepStatus.notStarted) StepStatus get phone;@JsonKey(unknownEnumValue: StepStatus.notStarted) StepStatus get selfie;@JsonKey(unknownEnumValue: StepStatus.notStarted) StepStatus get id;
/// Create a copy of VerificationSteps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerificationStepsCopyWith<VerificationSteps> get copyWith => _$VerificationStepsCopyWithImpl<VerificationSteps>(this as VerificationSteps, _$identity);

  /// Serializes this VerificationSteps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VerificationSteps&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.selfie, selfie) || other.selfie == selfie)&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,phone,selfie,id);

@override
String toString() {
  return 'VerificationSteps(phone: $phone, selfie: $selfie, id: $id)';
}


}

/// @nodoc
abstract mixin class $VerificationStepsCopyWith<$Res>  {
  factory $VerificationStepsCopyWith(VerificationSteps value, $Res Function(VerificationSteps) _then) = _$VerificationStepsCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: StepStatus.notStarted) StepStatus phone,@JsonKey(unknownEnumValue: StepStatus.notStarted) StepStatus selfie,@JsonKey(unknownEnumValue: StepStatus.notStarted) StepStatus id
});




}
/// @nodoc
class _$VerificationStepsCopyWithImpl<$Res>
    implements $VerificationStepsCopyWith<$Res> {
  _$VerificationStepsCopyWithImpl(this._self, this._then);

  final VerificationSteps _self;
  final $Res Function(VerificationSteps) _then;

/// Create a copy of VerificationSteps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phone = null,Object? selfie = null,Object? id = null,}) {
  return _then(_self.copyWith(
phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as StepStatus,selfie: null == selfie ? _self.selfie : selfie // ignore: cast_nullable_to_non_nullable
as StepStatus,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as StepStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [VerificationSteps].
extension VerificationStepsPatterns on VerificationSteps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VerificationSteps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VerificationSteps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VerificationSteps value)  $default,){
final _that = this;
switch (_that) {
case _VerificationSteps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VerificationSteps value)?  $default,){
final _that = this;
switch (_that) {
case _VerificationSteps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: StepStatus.notStarted)  StepStatus phone, @JsonKey(unknownEnumValue: StepStatus.notStarted)  StepStatus selfie, @JsonKey(unknownEnumValue: StepStatus.notStarted)  StepStatus id)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VerificationSteps() when $default != null:
return $default(_that.phone,_that.selfie,_that.id);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: StepStatus.notStarted)  StepStatus phone, @JsonKey(unknownEnumValue: StepStatus.notStarted)  StepStatus selfie, @JsonKey(unknownEnumValue: StepStatus.notStarted)  StepStatus id)  $default,) {final _that = this;
switch (_that) {
case _VerificationSteps():
return $default(_that.phone,_that.selfie,_that.id);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: StepStatus.notStarted)  StepStatus phone, @JsonKey(unknownEnumValue: StepStatus.notStarted)  StepStatus selfie, @JsonKey(unknownEnumValue: StepStatus.notStarted)  StepStatus id)?  $default,) {final _that = this;
switch (_that) {
case _VerificationSteps() when $default != null:
return $default(_that.phone,_that.selfie,_that.id);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VerificationSteps implements VerificationSteps {
  const _VerificationSteps({@JsonKey(unknownEnumValue: StepStatus.notStarted) required this.phone, @JsonKey(unknownEnumValue: StepStatus.notStarted) required this.selfie, @JsonKey(unknownEnumValue: StepStatus.notStarted) required this.id});
  factory _VerificationSteps.fromJson(Map<String, dynamic> json) => _$VerificationStepsFromJson(json);

@override@JsonKey(unknownEnumValue: StepStatus.notStarted) final  StepStatus phone;
@override@JsonKey(unknownEnumValue: StepStatus.notStarted) final  StepStatus selfie;
@override@JsonKey(unknownEnumValue: StepStatus.notStarted) final  StepStatus id;

/// Create a copy of VerificationSteps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerificationStepsCopyWith<_VerificationSteps> get copyWith => __$VerificationStepsCopyWithImpl<_VerificationSteps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerificationStepsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VerificationSteps&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.selfie, selfie) || other.selfie == selfie)&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,phone,selfie,id);

@override
String toString() {
  return 'VerificationSteps(phone: $phone, selfie: $selfie, id: $id)';
}


}

/// @nodoc
abstract mixin class _$VerificationStepsCopyWith<$Res> implements $VerificationStepsCopyWith<$Res> {
  factory _$VerificationStepsCopyWith(_VerificationSteps value, $Res Function(_VerificationSteps) _then) = __$VerificationStepsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: StepStatus.notStarted) StepStatus phone,@JsonKey(unknownEnumValue: StepStatus.notStarted) StepStatus selfie,@JsonKey(unknownEnumValue: StepStatus.notStarted) StepStatus id
});




}
/// @nodoc
class __$VerificationStepsCopyWithImpl<$Res>
    implements _$VerificationStepsCopyWith<$Res> {
  __$VerificationStepsCopyWithImpl(this._self, this._then);

  final _VerificationSteps _self;
  final $Res Function(_VerificationSteps) _then;

/// Create a copy of VerificationSteps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phone = null,Object? selfie = null,Object? id = null,}) {
  return _then(_VerificationSteps(
phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as StepStatus,selfie: null == selfie ? _self.selfie : selfie // ignore: cast_nullable_to_non_nullable
as StepStatus,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as StepStatus,
  ));
}


}


/// @nodoc
mixin _$Account {

 String get uid;@JsonKey(unknownEnumValue: AccountType.member) AccountType get accountType;@JsonKey(unknownEnumValue: VerificationStatus.pending) VerificationStatus get verificationStatus; VerificationSteps get verificationSteps;@JsonKey(unknownEnumValue: AccountStatus.active) AccountStatus get accountStatus; String? get verificationReason; String? get displayName; int? get ageYears;/// Profile photos as storage paths ("photos/<uid>/<id>.jpg"), main first.
 List<String> get photoPaths;
/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountCopyWith<Account> get copyWith => _$AccountCopyWithImpl<Account>(this as Account, _$identity);

  /// Serializes this Account to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Account&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.accountType, accountType) || other.accountType == accountType)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.verificationSteps, verificationSteps) || other.verificationSteps == verificationSteps)&&(identical(other.accountStatus, accountStatus) || other.accountStatus == accountStatus)&&(identical(other.verificationReason, verificationReason) || other.verificationReason == verificationReason)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.ageYears, ageYears) || other.ageYears == ageYears)&&const DeepCollectionEquality().equals(other.photoPaths, photoPaths));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,accountType,verificationStatus,verificationSteps,accountStatus,verificationReason,displayName,ageYears,const DeepCollectionEquality().hash(photoPaths));

@override
String toString() {
  return 'Account(uid: $uid, accountType: $accountType, verificationStatus: $verificationStatus, verificationSteps: $verificationSteps, accountStatus: $accountStatus, verificationReason: $verificationReason, displayName: $displayName, ageYears: $ageYears, photoPaths: $photoPaths)';
}


}

/// @nodoc
abstract mixin class $AccountCopyWith<$Res>  {
  factory $AccountCopyWith(Account value, $Res Function(Account) _then) = _$AccountCopyWithImpl;
@useResult
$Res call({
 String uid,@JsonKey(unknownEnumValue: AccountType.member) AccountType accountType,@JsonKey(unknownEnumValue: VerificationStatus.pending) VerificationStatus verificationStatus, VerificationSteps verificationSteps,@JsonKey(unknownEnumValue: AccountStatus.active) AccountStatus accountStatus, String? verificationReason, String? displayName, int? ageYears, List<String> photoPaths
});


$VerificationStepsCopyWith<$Res> get verificationSteps;

}
/// @nodoc
class _$AccountCopyWithImpl<$Res>
    implements $AccountCopyWith<$Res> {
  _$AccountCopyWithImpl(this._self, this._then);

  final Account _self;
  final $Res Function(Account) _then;

/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? accountType = null,Object? verificationStatus = null,Object? verificationSteps = null,Object? accountStatus = null,Object? verificationReason = freezed,Object? displayName = freezed,Object? ageYears = freezed,Object? photoPaths = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,accountType: null == accountType ? _self.accountType : accountType // ignore: cast_nullable_to_non_nullable
as AccountType,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as VerificationStatus,verificationSteps: null == verificationSteps ? _self.verificationSteps : verificationSteps // ignore: cast_nullable_to_non_nullable
as VerificationSteps,accountStatus: null == accountStatus ? _self.accountStatus : accountStatus // ignore: cast_nullable_to_non_nullable
as AccountStatus,verificationReason: freezed == verificationReason ? _self.verificationReason : verificationReason // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,ageYears: freezed == ageYears ? _self.ageYears : ageYears // ignore: cast_nullable_to_non_nullable
as int?,photoPaths: null == photoPaths ? _self.photoPaths : photoPaths // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VerificationStepsCopyWith<$Res> get verificationSteps {
  
  return $VerificationStepsCopyWith<$Res>(_self.verificationSteps, (value) {
    return _then(_self.copyWith(verificationSteps: value));
  });
}
}


/// Adds pattern-matching-related methods to [Account].
extension AccountPatterns on Account {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Account value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Account() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Account value)  $default,){
final _that = this;
switch (_that) {
case _Account():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Account value)?  $default,){
final _that = this;
switch (_that) {
case _Account() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid, @JsonKey(unknownEnumValue: AccountType.member)  AccountType accountType, @JsonKey(unknownEnumValue: VerificationStatus.pending)  VerificationStatus verificationStatus,  VerificationSteps verificationSteps, @JsonKey(unknownEnumValue: AccountStatus.active)  AccountStatus accountStatus,  String? verificationReason,  String? displayName,  int? ageYears,  List<String> photoPaths)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Account() when $default != null:
return $default(_that.uid,_that.accountType,_that.verificationStatus,_that.verificationSteps,_that.accountStatus,_that.verificationReason,_that.displayName,_that.ageYears,_that.photoPaths);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid, @JsonKey(unknownEnumValue: AccountType.member)  AccountType accountType, @JsonKey(unknownEnumValue: VerificationStatus.pending)  VerificationStatus verificationStatus,  VerificationSteps verificationSteps, @JsonKey(unknownEnumValue: AccountStatus.active)  AccountStatus accountStatus,  String? verificationReason,  String? displayName,  int? ageYears,  List<String> photoPaths)  $default,) {final _that = this;
switch (_that) {
case _Account():
return $default(_that.uid,_that.accountType,_that.verificationStatus,_that.verificationSteps,_that.accountStatus,_that.verificationReason,_that.displayName,_that.ageYears,_that.photoPaths);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid, @JsonKey(unknownEnumValue: AccountType.member)  AccountType accountType, @JsonKey(unknownEnumValue: VerificationStatus.pending)  VerificationStatus verificationStatus,  VerificationSteps verificationSteps, @JsonKey(unknownEnumValue: AccountStatus.active)  AccountStatus accountStatus,  String? verificationReason,  String? displayName,  int? ageYears,  List<String> photoPaths)?  $default,) {final _that = this;
switch (_that) {
case _Account() when $default != null:
return $default(_that.uid,_that.accountType,_that.verificationStatus,_that.verificationSteps,_that.accountStatus,_that.verificationReason,_that.displayName,_that.ageYears,_that.photoPaths);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Account extends Account {
  const _Account({required this.uid, @JsonKey(unknownEnumValue: AccountType.member) required this.accountType, @JsonKey(unknownEnumValue: VerificationStatus.pending) required this.verificationStatus, required this.verificationSteps, @JsonKey(unknownEnumValue: AccountStatus.active) required this.accountStatus, this.verificationReason, this.displayName, this.ageYears, final  List<String> photoPaths = const []}): _photoPaths = photoPaths,super._();
  factory _Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

@override final  String uid;
@override@JsonKey(unknownEnumValue: AccountType.member) final  AccountType accountType;
@override@JsonKey(unknownEnumValue: VerificationStatus.pending) final  VerificationStatus verificationStatus;
@override final  VerificationSteps verificationSteps;
@override@JsonKey(unknownEnumValue: AccountStatus.active) final  AccountStatus accountStatus;
@override final  String? verificationReason;
@override final  String? displayName;
@override final  int? ageYears;
/// Profile photos as storage paths ("photos/<uid>/<id>.jpg"), main first.
 final  List<String> _photoPaths;
/// Profile photos as storage paths ("photos/<uid>/<id>.jpg"), main first.
@override@JsonKey() List<String> get photoPaths {
  if (_photoPaths is EqualUnmodifiableListView) return _photoPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photoPaths);
}


/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountCopyWith<_Account> get copyWith => __$AccountCopyWithImpl<_Account>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Account&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.accountType, accountType) || other.accountType == accountType)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.verificationSteps, verificationSteps) || other.verificationSteps == verificationSteps)&&(identical(other.accountStatus, accountStatus) || other.accountStatus == accountStatus)&&(identical(other.verificationReason, verificationReason) || other.verificationReason == verificationReason)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.ageYears, ageYears) || other.ageYears == ageYears)&&const DeepCollectionEquality().equals(other._photoPaths, _photoPaths));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,accountType,verificationStatus,verificationSteps,accountStatus,verificationReason,displayName,ageYears,const DeepCollectionEquality().hash(_photoPaths));

@override
String toString() {
  return 'Account(uid: $uid, accountType: $accountType, verificationStatus: $verificationStatus, verificationSteps: $verificationSteps, accountStatus: $accountStatus, verificationReason: $verificationReason, displayName: $displayName, ageYears: $ageYears, photoPaths: $photoPaths)';
}


}

/// @nodoc
abstract mixin class _$AccountCopyWith<$Res> implements $AccountCopyWith<$Res> {
  factory _$AccountCopyWith(_Account value, $Res Function(_Account) _then) = __$AccountCopyWithImpl;
@override @useResult
$Res call({
 String uid,@JsonKey(unknownEnumValue: AccountType.member) AccountType accountType,@JsonKey(unknownEnumValue: VerificationStatus.pending) VerificationStatus verificationStatus, VerificationSteps verificationSteps,@JsonKey(unknownEnumValue: AccountStatus.active) AccountStatus accountStatus, String? verificationReason, String? displayName, int? ageYears, List<String> photoPaths
});


@override $VerificationStepsCopyWith<$Res> get verificationSteps;

}
/// @nodoc
class __$AccountCopyWithImpl<$Res>
    implements _$AccountCopyWith<$Res> {
  __$AccountCopyWithImpl(this._self, this._then);

  final _Account _self;
  final $Res Function(_Account) _then;

/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? accountType = null,Object? verificationStatus = null,Object? verificationSteps = null,Object? accountStatus = null,Object? verificationReason = freezed,Object? displayName = freezed,Object? ageYears = freezed,Object? photoPaths = null,}) {
  return _then(_Account(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,accountType: null == accountType ? _self.accountType : accountType // ignore: cast_nullable_to_non_nullable
as AccountType,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as VerificationStatus,verificationSteps: null == verificationSteps ? _self.verificationSteps : verificationSteps // ignore: cast_nullable_to_non_nullable
as VerificationSteps,accountStatus: null == accountStatus ? _self.accountStatus : accountStatus // ignore: cast_nullable_to_non_nullable
as AccountStatus,verificationReason: freezed == verificationReason ? _self.verificationReason : verificationReason // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,ageYears: freezed == ageYears ? _self.ageYears : ageYears // ignore: cast_nullable_to_non_nullable
as int?,photoPaths: null == photoPaths ? _self._photoPaths : photoPaths // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VerificationStepsCopyWith<$Res> get verificationSteps {
  
  return $VerificationStepsCopyWith<$Res>(_self.verificationSteps, (value) {
    return _then(_self.copyWith(verificationSteps: value));
  });
}
}

// dart format on
