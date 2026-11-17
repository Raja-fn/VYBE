// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Preferences _$PreferencesFromJson(Map<String, dynamic> json) => _Preferences(
  gender: $enumDecode(_$GenderEnumMap, json['gender']),
  showMe: $enumDecode(_$ShowMeEnumMap, json['showMe']),
  ageMin: (json['ageMin'] as num).toInt(),
  ageMax: (json['ageMax'] as num).toInt(),
  showGender: json['showGender'] as bool,
  whoCanRequest: $enumDecode(_$WhoCanRequestEnumMap, json['whoCanRequest']),
);

Map<String, dynamic> _$PreferencesToJson(_Preferences instance) =>
    <String, dynamic>{
      'gender': _$GenderEnumMap[instance.gender]!,
      'showMe': _$ShowMeEnumMap[instance.showMe]!,
      'ageMin': instance.ageMin,
      'ageMax': instance.ageMax,
      'showGender': instance.showGender,
      'whoCanRequest': _$WhoCanRequestEnumMap[instance.whoCanRequest]!,
    };

const _$GenderEnumMap = {
  Gender.woman: 'woman',
  Gender.man: 'man',
  Gender.nonBinary: 'non_binary',
  Gender.undisclosed: 'undisclosed',
};

const _$ShowMeEnumMap = {
  ShowMe.women: 'women',
  ShowMe.men: 'men',
  ShowMe.everyone: 'everyone',
};

const _$WhoCanRequestEnumMap = {
  WhoCanRequest.everyone: 'everyone',
  WhoCanRequest.women: 'women',
  WhoCanRequest.men: 'men',
};
