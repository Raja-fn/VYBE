// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatThread {

 String get id; String get otherUid; String get otherName; String get seekerUid; String get companionUid; ChatStatus get status; MessageType get lastType; String get lastText; DateTime get lastAt; int get unread;
/// Create a copy of ChatThread
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatThreadCopyWith<ChatThread> get copyWith => _$ChatThreadCopyWithImpl<ChatThread>(this as ChatThread, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatThread&&(identical(other.id, id) || other.id == id)&&(identical(other.otherUid, otherUid) || other.otherUid == otherUid)&&(identical(other.otherName, otherName) || other.otherName == otherName)&&(identical(other.seekerUid, seekerUid) || other.seekerUid == seekerUid)&&(identical(other.companionUid, companionUid) || other.companionUid == companionUid)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastType, lastType) || other.lastType == lastType)&&(identical(other.lastText, lastText) || other.lastText == lastText)&&(identical(other.lastAt, lastAt) || other.lastAt == lastAt)&&(identical(other.unread, unread) || other.unread == unread));
}


@override
int get hashCode => Object.hash(runtimeType,id,otherUid,otherName,seekerUid,companionUid,status,lastType,lastText,lastAt,unread);

@override
String toString() {
  return 'ChatThread(id: $id, otherUid: $otherUid, otherName: $otherName, seekerUid: $seekerUid, companionUid: $companionUid, status: $status, lastType: $lastType, lastText: $lastText, lastAt: $lastAt, unread: $unread)';
}


}

/// @nodoc
abstract mixin class $ChatThreadCopyWith<$Res>  {
  factory $ChatThreadCopyWith(ChatThread value, $Res Function(ChatThread) _then) = _$ChatThreadCopyWithImpl;
@useResult
$Res call({
 String id, String otherUid, String otherName, String seekerUid, String companionUid, ChatStatus status, MessageType lastType, String lastText, DateTime lastAt, int unread
});




}
/// @nodoc
class _$ChatThreadCopyWithImpl<$Res>
    implements $ChatThreadCopyWith<$Res> {
  _$ChatThreadCopyWithImpl(this._self, this._then);

  final ChatThread _self;
  final $Res Function(ChatThread) _then;

/// Create a copy of ChatThread
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? otherUid = null,Object? otherName = null,Object? seekerUid = null,Object? companionUid = null,Object? status = null,Object? lastType = null,Object? lastText = null,Object? lastAt = null,Object? unread = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,otherUid: null == otherUid ? _self.otherUid : otherUid // ignore: cast_nullable_to_non_nullable
as String,otherName: null == otherName ? _self.otherName : otherName // ignore: cast_nullable_to_non_nullable
as String,seekerUid: null == seekerUid ? _self.seekerUid : seekerUid // ignore: cast_nullable_to_non_nullable
as String,companionUid: null == companionUid ? _self.companionUid : companionUid // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChatStatus,lastType: null == lastType ? _self.lastType : lastType // ignore: cast_nullable_to_non_nullable
as MessageType,lastText: null == lastText ? _self.lastText : lastText // ignore: cast_nullable_to_non_nullable
as String,lastAt: null == lastAt ? _self.lastAt : lastAt // ignore: cast_nullable_to_non_nullable
as DateTime,unread: null == unread ? _self.unread : unread // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatThread].
extension ChatThreadPatterns on ChatThread {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatThread value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatThread() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatThread value)  $default,){
final _that = this;
switch (_that) {
case _ChatThread():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatThread value)?  $default,){
final _that = this;
switch (_that) {
case _ChatThread() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String otherUid,  String otherName,  String seekerUid,  String companionUid,  ChatStatus status,  MessageType lastType,  String lastText,  DateTime lastAt,  int unread)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatThread() when $default != null:
return $default(_that.id,_that.otherUid,_that.otherName,_that.seekerUid,_that.companionUid,_that.status,_that.lastType,_that.lastText,_that.lastAt,_that.unread);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String otherUid,  String otherName,  String seekerUid,  String companionUid,  ChatStatus status,  MessageType lastType,  String lastText,  DateTime lastAt,  int unread)  $default,) {final _that = this;
switch (_that) {
case _ChatThread():
return $default(_that.id,_that.otherUid,_that.otherName,_that.seekerUid,_that.companionUid,_that.status,_that.lastType,_that.lastText,_that.lastAt,_that.unread);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String otherUid,  String otherName,  String seekerUid,  String companionUid,  ChatStatus status,  MessageType lastType,  String lastText,  DateTime lastAt,  int unread)?  $default,) {final _that = this;
switch (_that) {
case _ChatThread() when $default != null:
return $default(_that.id,_that.otherUid,_that.otherName,_that.seekerUid,_that.companionUid,_that.status,_that.lastType,_that.lastText,_that.lastAt,_that.unread);case _:
  return null;

}
}

}

/// @nodoc


class _ChatThread implements ChatThread {
  const _ChatThread({required this.id, required this.otherUid, required this.otherName, required this.seekerUid, required this.companionUid, required this.status, required this.lastType, required this.lastText, required this.lastAt, required this.unread});
  

@override final  String id;
@override final  String otherUid;
@override final  String otherName;
@override final  String seekerUid;
@override final  String companionUid;
@override final  ChatStatus status;
@override final  MessageType lastType;
@override final  String lastText;
@override final  DateTime lastAt;
@override final  int unread;

/// Create a copy of ChatThread
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatThreadCopyWith<_ChatThread> get copyWith => __$ChatThreadCopyWithImpl<_ChatThread>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatThread&&(identical(other.id, id) || other.id == id)&&(identical(other.otherUid, otherUid) || other.otherUid == otherUid)&&(identical(other.otherName, otherName) || other.otherName == otherName)&&(identical(other.seekerUid, seekerUid) || other.seekerUid == seekerUid)&&(identical(other.companionUid, companionUid) || other.companionUid == companionUid)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastType, lastType) || other.lastType == lastType)&&(identical(other.lastText, lastText) || other.lastText == lastText)&&(identical(other.lastAt, lastAt) || other.lastAt == lastAt)&&(identical(other.unread, unread) || other.unread == unread));
}


@override
int get hashCode => Object.hash(runtimeType,id,otherUid,otherName,seekerUid,companionUid,status,lastType,lastText,lastAt,unread);

@override
String toString() {
  return 'ChatThread(id: $id, otherUid: $otherUid, otherName: $otherName, seekerUid: $seekerUid, companionUid: $companionUid, status: $status, lastType: $lastType, lastText: $lastText, lastAt: $lastAt, unread: $unread)';
}


}

/// @nodoc
abstract mixin class _$ChatThreadCopyWith<$Res> implements $ChatThreadCopyWith<$Res> {
  factory _$ChatThreadCopyWith(_ChatThread value, $Res Function(_ChatThread) _then) = __$ChatThreadCopyWithImpl;
@override @useResult
$Res call({
 String id, String otherUid, String otherName, String seekerUid, String companionUid, ChatStatus status, MessageType lastType, String lastText, DateTime lastAt, int unread
});




}
/// @nodoc
class __$ChatThreadCopyWithImpl<$Res>
    implements _$ChatThreadCopyWith<$Res> {
  __$ChatThreadCopyWithImpl(this._self, this._then);

  final _ChatThread _self;
  final $Res Function(_ChatThread) _then;

/// Create a copy of ChatThread
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? otherUid = null,Object? otherName = null,Object? seekerUid = null,Object? companionUid = null,Object? status = null,Object? lastType = null,Object? lastText = null,Object? lastAt = null,Object? unread = null,}) {
  return _then(_ChatThread(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,otherUid: null == otherUid ? _self.otherUid : otherUid // ignore: cast_nullable_to_non_nullable
as String,otherName: null == otherName ? _self.otherName : otherName // ignore: cast_nullable_to_non_nullable
as String,seekerUid: null == seekerUid ? _self.seekerUid : seekerUid // ignore: cast_nullable_to_non_nullable
as String,companionUid: null == companionUid ? _self.companionUid : companionUid // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChatStatus,lastType: null == lastType ? _self.lastType : lastType // ignore: cast_nullable_to_non_nullable
as MessageType,lastText: null == lastText ? _self.lastText : lastText // ignore: cast_nullable_to_non_nullable
as String,lastAt: null == lastAt ? _self.lastAt : lastAt // ignore: cast_nullable_to_non_nullable
as DateTime,unread: null == unread ? _self.unread : unread // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$ChatMessage {

 String get id; MessageType get type; DateTime get createdAt; String? get senderUid; String? get text;/// System messages: what happened (e.g. "chat_started") and its credit cost.
 String? get systemKind; int? get credits;/// Booking cards.
 String? get bookingId; String? get planType; DateTime? get startAt; String? get venueName;
/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageCopyWith<ChatMessage> get copyWith => _$ChatMessageCopyWithImpl<ChatMessage>(this as ChatMessage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.senderUid, senderUid) || other.senderUid == senderUid)&&(identical(other.text, text) || other.text == text)&&(identical(other.systemKind, systemKind) || other.systemKind == systemKind)&&(identical(other.credits, credits) || other.credits == credits)&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.venueName, venueName) || other.venueName == venueName));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,createdAt,senderUid,text,systemKind,credits,bookingId,planType,startAt,venueName);

@override
String toString() {
  return 'ChatMessage(id: $id, type: $type, createdAt: $createdAt, senderUid: $senderUid, text: $text, systemKind: $systemKind, credits: $credits, bookingId: $bookingId, planType: $planType, startAt: $startAt, venueName: $venueName)';
}


}

/// @nodoc
abstract mixin class $ChatMessageCopyWith<$Res>  {
  factory $ChatMessageCopyWith(ChatMessage value, $Res Function(ChatMessage) _then) = _$ChatMessageCopyWithImpl;
@useResult
$Res call({
 String id, MessageType type, DateTime createdAt, String? senderUid, String? text, String? systemKind, int? credits, String? bookingId, String? planType, DateTime? startAt, String? venueName
});




}
/// @nodoc
class _$ChatMessageCopyWithImpl<$Res>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._self, this._then);

  final ChatMessage _self;
  final $Res Function(ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? createdAt = null,Object? senderUid = freezed,Object? text = freezed,Object? systemKind = freezed,Object? credits = freezed,Object? bookingId = freezed,Object? planType = freezed,Object? startAt = freezed,Object? venueName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MessageType,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,senderUid: freezed == senderUid ? _self.senderUid : senderUid // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,systemKind: freezed == systemKind ? _self.systemKind : systemKind // ignore: cast_nullable_to_non_nullable
as String?,credits: freezed == credits ? _self.credits : credits // ignore: cast_nullable_to_non_nullable
as int?,bookingId: freezed == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String?,planType: freezed == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as String?,startAt: freezed == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime?,venueName: freezed == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessage].
extension ChatMessagePatterns on ChatMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessage value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessage value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  MessageType type,  DateTime createdAt,  String? senderUid,  String? text,  String? systemKind,  int? credits,  String? bookingId,  String? planType,  DateTime? startAt,  String? venueName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.id,_that.type,_that.createdAt,_that.senderUid,_that.text,_that.systemKind,_that.credits,_that.bookingId,_that.planType,_that.startAt,_that.venueName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  MessageType type,  DateTime createdAt,  String? senderUid,  String? text,  String? systemKind,  int? credits,  String? bookingId,  String? planType,  DateTime? startAt,  String? venueName)  $default,) {final _that = this;
switch (_that) {
case _ChatMessage():
return $default(_that.id,_that.type,_that.createdAt,_that.senderUid,_that.text,_that.systemKind,_that.credits,_that.bookingId,_that.planType,_that.startAt,_that.venueName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  MessageType type,  DateTime createdAt,  String? senderUid,  String? text,  String? systemKind,  int? credits,  String? bookingId,  String? planType,  DateTime? startAt,  String? venueName)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.id,_that.type,_that.createdAt,_that.senderUid,_that.text,_that.systemKind,_that.credits,_that.bookingId,_that.planType,_that.startAt,_that.venueName);case _:
  return null;

}
}

}

/// @nodoc


class _ChatMessage implements ChatMessage {
  const _ChatMessage({required this.id, required this.type, required this.createdAt, this.senderUid, this.text, this.systemKind, this.credits, this.bookingId, this.planType, this.startAt, this.venueName});
  

@override final  String id;
@override final  MessageType type;
@override final  DateTime createdAt;
@override final  String? senderUid;
@override final  String? text;
/// System messages: what happened (e.g. "chat_started") and its credit cost.
@override final  String? systemKind;
@override final  int? credits;
/// Booking cards.
@override final  String? bookingId;
@override final  String? planType;
@override final  DateTime? startAt;
@override final  String? venueName;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageCopyWith<_ChatMessage> get copyWith => __$ChatMessageCopyWithImpl<_ChatMessage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.senderUid, senderUid) || other.senderUid == senderUid)&&(identical(other.text, text) || other.text == text)&&(identical(other.systemKind, systemKind) || other.systemKind == systemKind)&&(identical(other.credits, credits) || other.credits == credits)&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.venueName, venueName) || other.venueName == venueName));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,createdAt,senderUid,text,systemKind,credits,bookingId,planType,startAt,venueName);

@override
String toString() {
  return 'ChatMessage(id: $id, type: $type, createdAt: $createdAt, senderUid: $senderUid, text: $text, systemKind: $systemKind, credits: $credits, bookingId: $bookingId, planType: $planType, startAt: $startAt, venueName: $venueName)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageCopyWith<$Res> implements $ChatMessageCopyWith<$Res> {
  factory _$ChatMessageCopyWith(_ChatMessage value, $Res Function(_ChatMessage) _then) = __$ChatMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, MessageType type, DateTime createdAt, String? senderUid, String? text, String? systemKind, int? credits, String? bookingId, String? planType, DateTime? startAt, String? venueName
});




}
/// @nodoc
class __$ChatMessageCopyWithImpl<$Res>
    implements _$ChatMessageCopyWith<$Res> {
  __$ChatMessageCopyWithImpl(this._self, this._then);

  final _ChatMessage _self;
  final $Res Function(_ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? createdAt = null,Object? senderUid = freezed,Object? text = freezed,Object? systemKind = freezed,Object? credits = freezed,Object? bookingId = freezed,Object? planType = freezed,Object? startAt = freezed,Object? venueName = freezed,}) {
  return _then(_ChatMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MessageType,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,senderUid: freezed == senderUid ? _self.senderUid : senderUid // ignore: cast_nullable_to_non_nullable
as String?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,systemKind: freezed == systemKind ? _self.systemKind : systemKind // ignore: cast_nullable_to_non_nullable
as String?,credits: freezed == credits ? _self.credits : credits // ignore: cast_nullable_to_non_nullable
as int?,bookingId: freezed == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String?,planType: freezed == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as String?,startAt: freezed == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime?,venueName: freezed == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
