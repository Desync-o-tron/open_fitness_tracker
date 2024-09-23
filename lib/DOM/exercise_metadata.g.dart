// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exercise _$ExerciseFromJson(Map<String, dynamic> json) => Exercise(
      id: json['id'] as String?,
      name: json['name'] as String,
      force: $enumDecodeNullable(_$ForceEnumMap, json['force']),
      level: $enumDecodeNullable(_$LevelEnumMap, json['level']),
      mechanic: $enumDecodeNullable(_$MechanicEnumMap, json['mechanic']),
      equipment: json['equipment'] as String?,
      notes: json['notes'] as String?,
      setMetrics: (json['setMetrics'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      primaryMuscles: (json['primaryMuscles'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      secondaryMuscles: (json['secondaryMuscles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      instructions: (json['instructions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      category: json['category'] as String?,
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
    )..alternateNames = (json['alternateNames'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList();

Map<String, dynamic> _$ExerciseToJson(Exercise instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'alternateNames': instance.alternateNames,
      'force': _$ForceEnumMap[instance.force],
      'level': _$LevelEnumMap[instance.level],
      'mechanic': _$MechanicEnumMap[instance.mechanic],
      'equipment': instance.equipment,
      'notes': instance.notes,
      'setMetrics': instance.setMetrics,
      'primaryMuscles': instance.primaryMuscles,
      'secondaryMuscles': instance.secondaryMuscles,
      'instructions': instance.instructions,
      'category': instance.category,
      'images': instance.images,
    };

const _$ForceEnumMap = {
  Force.static: 'static',
  Force.pull: 'pull',
  Force.push: 'push',
};

const _$LevelEnumMap = {
  Level.beginner: 'beginner',
  Level.intermediate: 'intermediate',
  Level.expert: 'expert',
};

const _$MechanicEnumMap = {
  Mechanic.isolation: 'isolation',
  Mechanic.compound: 'compound',
};
