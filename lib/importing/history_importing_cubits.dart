import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
part 'history_importing_cubits.g.dart';

/*
to generate new g.dart files run:
dart run build_runner build --delete-conflicting-outputs
to do it continuously run:
dart run build_runner watch --delete-conflicting-outputs
*/

@JsonSerializable()
class ExerciseMatchCard {
  int matchID = -1;
  final Exercise foreignExercise;
  Exercise? matchedExercise;
  bool isConfirmed;
  bool preferForeignExerciseName;
  bool bDiscard;

  ExerciseMatchCard({
    required this.foreignExercise,
    this.matchedExercise,
    this.isConfirmed = false,
    this.preferForeignExerciseName = false,
    this.bDiscard = false,
  });
  factory ExerciseMatchCard.fromJson(Map<String, dynamic> json) =>
      _$ExerciseMatchCardFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseMatchCardToJson(this);
}

class ImportedExerciseMatchesCubit extends HydratedCubit<List<ExerciseMatchCard>> {
  ImportedExerciseMatchesCubit() : super([]);

  void addMatches(List<ExerciseMatchCard> newMatches) {
    final updatedMatches = List<ExerciseMatchCard>.from(state)..addAll(newMatches);
    for (int i = 0; i < updatedMatches.length; ++i) {
      var match = updatedMatches[i];
      match.matchID = i;
    }
    emit(updatedMatches);
  }

  void updateMatch(ExerciseMatchCard updated) {
    final updatedMatches = List<ExerciseMatchCard>.from(state);
    final index =
        updatedMatches.indexWhere((existing) => existing.matchID == updated.matchID);
    if (index != -1) {
      updatedMatches[index] = updated;
      emit(updatedMatches);
    } else {
      //I don't love how I'm using this cubit really.
      throw Exception("I'm dumb");
    }
  }

  void deleteAll() {
    emit([]);
  }

  @override
  List<ExerciseMatchCard>? fromJson(Map<String, dynamic> json) {
    if (json['ImportedExerciseMatches'] != null) {
      return (json['ImportedExerciseMatches'] as List)
          .map((e) => ExerciseMatchCard.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return null;
  }

  @override
  Map<String, dynamic>? toJson(List<ExerciseMatchCard> state) {
    return {
      'ImportedExerciseMatches': state.map((match) => match.toJson()).toList(),
    };
  }
}

class ImportedTrainingSessionsCubit extends HydratedCubit<List<TrainingSession>> {
  ImportedTrainingSessionsCubit() : super([]);

  void addSessions(List<TrainingSession> newSessions) {
    final updatedSessions = List<TrainingSession>.from(state)..addAll(newSessions);
    emit(updatedSessions);
  }

  List<TrainingSession> getSessions() {
    return state;
  }

  void deleteSessions() {
    emit([]);
  }

  @override
  List<TrainingSession>? fromJson(Map<String, dynamic> json) {
    if (json['ImportedTrainingSessions'] != null) {
      return (json['ImportedTrainingSessions'] as List)
          .map((e) => TrainingSession.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return null;
  }

  @override
  Map<String, dynamic>? toJson(List<TrainingSession> state) {
    return {
      'ImportedTrainingSessions': state.map((session) => session.toJson()).toList(),
    };
  }
}
