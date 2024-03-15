// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingSession _$TrainingSessionFromJson(Map<String, dynamic> json) =>
    TrainingSession(
      id: json['id'] as String?,
      isOngoing: json['isOngoing'] as bool? ?? false,
      name: json['name'] as String?,
      duration: json['duration'] == null
          ? null
          : Duration(microseconds: json['duration'] as int),
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
      trainingData: (json['trainingData'] as List<dynamic>?)
              ?.map((e) => SetsOfAnExercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TrainingSessionToJson(TrainingSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'isOngoing': instance.isOngoing,
      'name': instance.name,
      'duration': instance.duration?.inMicroseconds,
      'date': instance.date?.toIso8601String(),
      'notes': instance.notes,
      'trainingData': instance.trainingData,
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
      'ex': instance.ex,
      'prevSet': instance.prevSet,
      'sets': instance.sets,
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
      ..completed = json['completed'] as bool;

Map<String, dynamic> _$SetToJson(Set instance) => <String, dynamic>{
      'ex': instance.ex,
      'id': instance.id,
      'reps': instance.reps,
      'time': instance.time,
      'weight': instance.weight,
      'distance': instance.distance,
      'speed': instance.speed,
      'completed': instance.completed,
    };
