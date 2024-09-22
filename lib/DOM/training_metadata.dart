import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:json_annotation/json_annotation.dart';
part 'training_metadata.g.dart';

/*
to generate new g.dart files run:
dart run build_runner build --delete-conflicting-outputs
to do it continuously run:
dart run build_runner watch --delete-conflicting-outputs
*/

@JsonSerializable(explicitToJson: true)
class TrainingSession {
  String id;
  @JsonKey(toJson: _dateTimetoJson, fromJson: _dateTimefromJson)
  DateTime dateOfLastEdit;
  @JsonKey(toJson: _dateTimetoJson, fromJson: _dateTimefromJson)
  DateTime date;
  bool isOngoing = false;
  String name;
  Duration duration;
  String? notes;
  List<SetsOfAnExercise> trainingData = [];

  TrainingSession({
    String? id,
    Duration? duration,
    DateTime? date,
    bool? isOngoing,
    String? name,
    String? notes,
    List<SetsOfAnExercise>? trainingData,
    DateTime? dateOfLastEdit,
  })  : id = id ?? DateTime.now().toIso8601String(),
        duration = duration ?? const Duration(),
        date = date ?? DateTime.now(),
        isOngoing = isOngoing ?? false,
        name = name ?? '',
        notes = notes ?? '',
        trainingData = trainingData ?? [],
        dateOfLastEdit =
            dateOfLastEdit ?? DateTime.now(); //does this logic make sense? i think so.

  TrainingSession.copy(TrainingSession sesh)
      : id = sesh.id,
        duration = sesh.duration,
        date = sesh.date,
        name = sesh.name,
        notes = sesh.notes,
        isOngoing = sesh.isOngoing,
        trainingData = List<SetsOfAnExercise>.from(sesh.trainingData),
        dateOfLastEdit = sesh.dateOfLastEdit;

  //todo this copyWith kinda sucks bc I have to copy all the fields manually
  TrainingSession copyWith({required List<SetsOfAnExercise> trainingData}) {
    return TrainingSession(
      id: id,
      name: name,
      duration: duration,
      date: date,
      notes: notes,
      isOngoing: isOngoing,
      trainingData: trainingData,
      dateOfLastEdit: dateOfLastEdit,
    );
  }

  // @override
  // bool operator ==(Object other) {
  //   if (identical(this, other)) return true;
  //   return other is TrainingSession &&
  //       other.id == id &&
  //       other.dateOfLastEdit == dateOfLastEdit &&

  //       ;
  // }

  // @override
  // int get hashCode => id.hashCode ^ dateOfLastEdit.hashCode;

  factory TrainingSession.fromJson(Map<String, dynamic> json) =>
      _$TrainingSessionFromJson(json);
  Map<String, dynamic> toJson() => _$TrainingSessionToJson(this);

  static int _dateTimetoJson(DateTime value) => value.millisecondsSinceEpoch;
  static DateTime _dateTimefromJson(int value) =>
      DateTime.fromMillisecondsSinceEpoch(value);
}

@JsonSerializable(explicitToJson: true)
class SetsOfAnExercise {
  Exercise ex;
  Set prevSet; //also functions as a header template
  List<Set> sets = [];

  SetsOfAnExercise(this.ex) : prevSet = Set(ex) {
    if (sets.isEmpty) sets.add(Set(ex));
  }

  factory SetsOfAnExercise.fromJson(Map<String, dynamic> json) =>
      _$SetsOfAnExerciseFromJson(json);
  Map<String, dynamic> toJson() => _$SetsOfAnExerciseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Set {
  // @JsonKey(includeToJson: false)
  Exercise ex;
  late String id; //just the datetime for now
  num? reps;
  num? time;
  num? weight;
  num? distance;
  num? speed;
  bool completed = false;
  //todo add units.  weight, distance, speed, time etc..

  Set(this.ex) {
    id = DateTime.now().toIso8601String();
    if (ex.setMetrics!.contains('reps')) reps = 0;
    if (ex.setMetrics!.contains('weight')) weight = 0;
    if (ex.setMetrics!.contains('time')) time = 0;
    if (ex.setMetrics!.contains('distance')) distance = 0;
    if (ex.setMetrics!.contains('speed')) speed = 0;
    //todo
    //if contains anythign else, throw error
  }

  factory Set.fromJson(Map<String, dynamic> json) => _$SetFromJson(json);
  Map<String, dynamic> toJson() => _$SetToJson(this);
}

class TrainingSessionCubit extends HydratedCubit<TrainingSession> {
  TrainingSessionCubit() : super(TrainingSession()) {
    // var bench = Exercise(
    //   name: "Bench Press",
    //   equipment: "Barbell",
    //   primaryMuscles: ["Chest", "Triceps"],
    //   setMetrics: ["reps", "weight"],
    // );
    // var squat = Exercise(
    //   name: "Squat",
    //   equipment: "Barbell",
    //   primaryMuscles: ["Quadriceps", "Glutes"],
    //   setMetrics: ["reps", "weight"],
    // );
    // state.trainingData.addIfDNE(SetsOfAnExercise(bench));
    // state.trainingData.addIfDNE(SetsOfAnExercise(squat));
    // //lets add some example sets
    // Set benchSet = state.trainingData[0].sets[0];
    // benchSet.reps = 10;
    // benchSet.weight = 135;

    // state.isOngoing = true;
  }

  void addExercise(Exercise ex) {
    var newState = TrainingSession.copy(state);
    newState.trainingData.add(SetsOfAnExercise(ex));
    emit(newState);
  }

  void removeExercise(Exercise ex) {
    var newState = TrainingSession.copy(state);
    newState.trainingData.removeWhere((element) => element.ex == ex);
    emit(newState); //.trainingData.removeWhere((element) => element.ex == ex));
  }

  void addSet(Exercise ex) {
    var newTrainingData = state.trainingData.toList();
    newTrainingData.firstWhere((element) => element.ex == ex).sets.add(Set(ex));
    emit(state.copyWith(trainingData: newTrainingData));
  }

  void removeSet(Exercise ex, String setId) {
    TrainingSession newState = TrainingSession.copy(state);
    SetsOfAnExercise setsOfAnExercise =
        newState.trainingData.firstWhere((element) => element.ex == ex);
    bool removed = false;
    for (var i = 0; i < setsOfAnExercise.sets.length; i++) {
      if (setsOfAnExercise.sets[i].id == setId) {
        setsOfAnExercise.sets.removeAt(i);
        removed = true;
        break;
      }
    }
    if (!removed) {
      // todo error handling
    }
    emit(newState);
  }

  void updateSet(Exercise ex, Set set, int setIndex) {
    var newTrainingData = state.trainingData.toList();

    bool found = false;
    for (var i = 0; i < newTrainingData.length; i++) {
      if (newTrainingData[i].ex.name == ex.name) {
        newTrainingData[i].sets[setIndex] = set;
        found = true;
        break;
      }
    }
    if (!found) {
      //todo error handling
      throw Exception('set not found');
    }

    emit(state.copyWith(trainingData: newTrainingData));
  }

  void reset() {
    emit(TrainingSession(trainingData: [], date: DateTime.now()));
  }

  void updateDuration() {
    TrainingSession newState = TrainingSession.copy(state);
    newState.duration = DateTime.now().difference(state.date);
    emit(newState);
  }

  void updateNotes(String value) {
    TrainingSession newState = TrainingSession.copy(state);
    newState.notes = value;
    emit(newState);
  }

  @override
  TrainingSession? fromJson(Map<String, dynamic> json) {
    return TrainingSession.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(TrainingSession state) {
    return state.toJson();
  }
}
