// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basic_user_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BasicUserInfo _$BasicUserInfoFromJson(Map<String, dynamic> json) =>
    BasicUserInfo(
      searchableUsername: json['searchableUsername'] as String?,
      preferredDistanceUnit: $enumDecodeNullable(
              _$DistanceUnitsEnumMap, json['preferredDistanceUnit']) ??
          DistanceUnits.miles,
      preferredMassUnit:
          $enumDecodeNullable(_$MassUnitsEnumMap, json['preferredMassUnit']) ??
              MassUnits.lb,
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
