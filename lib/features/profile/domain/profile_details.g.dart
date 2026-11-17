// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProfileDetails _$ProfileDetailsFromJson(
  Map<String, dynamic> json,
) => _ProfileDetails(
  about: json['about'] as String?,
  city: json['city'] as String?,
  languages:
      (json['languages'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  education: json['education'] as String?,
  profession: json['profession'] as String?,
  interests:
      (json['interests'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  personality:
      (json['personality'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  socialEnergy: json['socialEnergy'] as String?,
  drinking: json['drinking'] as String?,
  smoking: json['smoking'] as String?,
  fitness: json['fitness'] as String?,
);

Map<String, dynamic> _$ProfileDetailsToJson(_ProfileDetails instance) =>
    <String, dynamic>{
      'about': instance.about,
      'city': instance.city,
      'languages': instance.languages,
      'education': instance.education,
      'profession': instance.profession,
      'interests': instance.interests,
      'personality': instance.personality,
      'socialEnergy': instance.socialEnergy,
      'drinking': instance.drinking,
      'smoking': instance.smoking,
      'fitness': instance.fitness,
    };
