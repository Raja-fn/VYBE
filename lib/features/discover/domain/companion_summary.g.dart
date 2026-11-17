// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'companion_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PromptAnswer _$PromptAnswerFromJson(Map<String, dynamic> json) =>
    _PromptAnswer(promptId: json['promptId'] as String, answer: json['answer'] as String);

Map<String, dynamic> _$PromptAnswerToJson(_PromptAnswer instance) => <String, dynamic>{
  'promptId': instance.promptId,
  'answer': instance.answer,
};

_VoiceIntro _$VoiceIntroFromJson(Map<String, dynamic> json) =>
    _VoiceIntro(path: json['path'] as String, durationSec: (json['durationSec'] as num).toInt());

Map<String, dynamic> _$VoiceIntroToJson(_VoiceIntro instance) => <String, dynamic>{
  'path': instance.path,
  'durationSec': instance.durationSec,
};

_CompanionSummary _$CompanionSummaryFromJson(Map<String, dynamic> json) => _CompanionSummary(
  uid: json['uid'] as String,
  displayName: json['displayName'] as String,
  ageYears: (json['ageYears'] as num).toInt(),
  photoPaths: (json['photoPaths'] as List<dynamic>).map((e) => e as String).toList(),
  about: json['about'] as String,
  activityTags: (json['activityTags'] as List<dynamic>).map((e) => e as String).toList(),
  planTypes: (json['planTypes'] as List<dynamic>).map((e) => e as String).toList(),
  ratingCount: (json['ratingCount'] as num).toInt(),
  meetupCount: (json['meetupCount'] as num).toInt(),
  distanceKm: (json['distanceKm'] as num).toInt(),
  spotsNearby: (json['spotsNearby'] as num).toInt(),
  gender: json['gender'] as String?,
  prompt: json['prompt'] == null ? null : PromptAnswer.fromJson(json['prompt'] as Map<String, dynamic>),
  voiceIntro: json['voiceIntro'] == null ? null : VoiceIntro.fromJson(json['voiceIntro'] as Map<String, dynamic>),
  ratingAvg: (json['ratingAvg'] as num?)?.toDouble(),
  freeNowUntil: json['freeNowUntil'] == null ? null : DateTime.parse(json['freeNowUntil'] as String),
  freeFrom: json['freeFrom'] == null ? null : DateTime.parse(json['freeFrom'] as String),
  freeUntil: json['freeUntil'] == null ? null : DateTime.parse(json['freeUntil'] as String),
  details: json['details'] == null
      ? ProfileDetails.empty
      : ProfileDetails.fromJson(json['details'] as Map<String, dynamic>),
  isSample: json['isSample'] as bool? ?? false,
);

Map<String, dynamic> _$CompanionSummaryToJson(_CompanionSummary instance) => <String, dynamic>{
  'uid': instance.uid,
  'displayName': instance.displayName,
  'ageYears': instance.ageYears,
  'photoPaths': instance.photoPaths,
  'about': instance.about,
  'activityTags': instance.activityTags,
  'planTypes': instance.planTypes,
  'ratingCount': instance.ratingCount,
  'meetupCount': instance.meetupCount,
  'distanceKm': instance.distanceKm,
  'spotsNearby': instance.spotsNearby,
  'gender': instance.gender,
  'prompt': instance.prompt,
  'voiceIntro': instance.voiceIntro,
  'ratingAvg': instance.ratingAvg,
  'freeNowUntil': instance.freeNowUntil?.toIso8601String(),
  'freeFrom': instance.freeFrom?.toIso8601String(),
  'freeUntil': instance.freeUntil?.toIso8601String(),
  'details': instance.details,
  'isSample': instance.isSample,
};
