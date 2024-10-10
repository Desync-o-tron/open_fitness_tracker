// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_importing_cubits.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseMatchCard _$ExerciseMatchCardFromJson(Map<String, dynamic> json) =>
    ExerciseMatchCard(
      foreignExercise:
          Exercise.fromJson(json['foreignExercise'] as Map<String, dynamic>),
      matchedExercise: json['matchedExercise'] == null
          ? null
          : Exercise.fromJson(json['matchedExercise'] as Map<String, dynamic>),
      isConfirmed: json['isConfirmed'] as bool? ?? false,
      preferForeignExerciseName:
          json['preferForeignExerciseName'] as bool? ?? false,
      bDiscard: json['bDiscard'] as bool? ?? false,
    )..matchID = (json['matchID'] as num).toInt();

Map<String, dynamic> _$ExerciseMatchCardToJson(ExerciseMatchCard instance) =>
    <String, dynamic>{
      'matchID': instance.matchID,
      'foreignExercise': instance.foreignExercise,
      'matchedExercise': instance.matchedExercise,
      'isConfirmed': instance.isConfirmed,
      'preferForeignExerciseName': instance.preferForeignExerciseName,
      'bDiscard': instance.bDiscard,
    };
