// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingSession _$TrainingSessionFromJson(Map<String, dynamic> json) =>
    TrainingSession(
      id: json['id'] as String?,
      duration: json['duration'] == null
          ? null
          : Duration(microseconds: (json['duration'] as num).toInt()),
      date: TrainingSession._dateTimefromJson((json['date'] as num).toInt()),
      isOngoing: json['isOngoing'] as bool?,
      name: json['name'] as String?,
      notes: json['notes'] as String?,
      trainingData: (json['trainingData'] as List<dynamic>?)
          ?.map((e) => SetsOfAnExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      dateOfLastEdit: TrainingSession._dateTimefromJson(
          (json['dateOfLastEdit'] as num).toInt()),
    );

Map<String, dynamic> _$TrainingSessionToJson(TrainingSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dateOfLastEdit':
          TrainingSession._dateTimetoJson(instance.dateOfLastEdit),
      'date': TrainingSession._dateTimetoJson(instance.date),
      'isOngoing': instance.isOngoing,
      'name': instance.name,
      'duration': instance.duration.inMicroseconds,
      'notes': instance.notes,
      'trainingData': instance.trainingData.map((e) => e.toJson()).toList(),
    };

SetsOfAnExercise _$SetsOfAnExerciseFromJson(Map<String, dynamic> json) =>
    SetsOfAnExercise(
      Exercise.fromJson(json['ex'] as Map<String, dynamic>),
    )
      ..prevSet = Set.fromJson(json['prevSet'] as Map<String, dynamic>)
      ..sets = (json['sets'] as List<dynamic>)
          .map((e) => Set.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$SetsOfAnExerciseToJson(SetsOfAnExercise instance) =>
    <String, dynamic>{
      'ex': instance.ex.toJson(),
      'prevSet': instance.prevSet.toJson(),
      'sets': instance.sets.map((e) => e.toJson()).toList(),
    };

Set _$SetFromJson(Map<String, dynamic> json) => Set(
      Exercise.fromJson(json['ex'] as Map<String, dynamic>),
    )
      ..id = json['id'] as String
      ..reps = json['reps'] as num?
      ..time = json['time'] as num?
      ..weight = json['weight'] as num?
      ..distance = json['distance'] as num?
      ..speed = json['speed'] as num?
      ..massUnits = $enumDecodeNullable(_$MassUnitsEnumMap, json['massUnits'])
      ..distanceUnits =
          $enumDecodeNullable(_$DistanceUnitsEnumMap, json['distanceUnits'])
      ..completed = json['completed'] as bool;

Map<String, dynamic> _$SetToJson(Set instance) => <String, dynamic>{
      'ex': instance.ex.toJson(),
      'id': instance.id,
      'reps': instance.reps,
      'time': instance.time,
      'weight': instance.weight,
      'distance': instance.distance,
      'speed': instance.speed,
      'massUnits': _$MassUnitsEnumMap[instance.massUnits],
      'distanceUnits': _$DistanceUnitsEnumMap[instance.distanceUnits],
      'completed': instance.completed,
    };

const _$MassUnitsEnumMap = {
  MassUnits.kg: 'kg',
  MassUnits.lb: 'lb',
};

const _$DistanceUnitsEnumMap = {
  DistanceUnits.miles: 'miles',
  DistanceUnits.feet: 'feet',
  DistanceUnits.kilometers: 'kilometers',
};
