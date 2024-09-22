// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basic_user_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BasicUserInfo _$BasicUserInfoFromJson(Map<String, dynamic> json) =>
    BasicUserInfo(
      searchableUsername: json['searchableUsername'] as String?,
      preferredDistanceUnit:
          $enumDecode(_$DistanceUnitsEnumMap, json['preferredDistanceUnit']),
      preferredMassUnit:
          $enumDecode(_$MassUnitsEnumMap, json['preferredMassUnit']),
    );

Map<String, dynamic> _$BasicUserInfoToJson(BasicUserInfo instance) =>
    <String, dynamic>{
      'searchableUsername': instance.searchableUsername,
      'preferredMassUnit': _$MassUnitsEnumMap[instance.preferredMassUnit]!,
      'preferredDistanceUnit':
          _$DistanceUnitsEnumMap[instance.preferredDistanceUnit]!,
    };

const _$DistanceUnitsEnumMap = {
  DistanceUnits.miles: 'miles',
  DistanceUnits.feet: 'feet',
  DistanceUnits.kilometers: 'kilometers',
};

const _$MassUnitsEnumMap = {
  MassUnits.kg: 'kg',
  MassUnits.lb: 'lb',
};
