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

@JsonSerializable()
class TrainingSession {
  String? id;
  bool isOngoing = false;
  String name;
  Duration duration;
  DateTime dateTime;
  String? notes;
  List<SetsOfAnExercise> trainingData = [];

  TrainingSession({
    String? id,
    bool? isOngoing,
    String? name,
    Duration? duration,
    DateTime? date,
    String? notes,
    List<SetsOfAnExercise>? trainingData,
  })  : id = id ?? '',
        isOngoing = isOngoing ?? false,
        name = name ?? '',
        duration = duration ?? const Duration(),
        dateTime = date ?? DateTime.now(),
        notes = notes ?? '',
        trainingData = trainingData ?? [];

  void copyFrom(TrainingSession sesh) {
    id = sesh.id;
    name = sesh.name;
    duration = sesh.duration;
    dateTime = sesh.dateTime;
    notes = sesh.notes;
    isOngoing = sesh.isOngoing;
    trainingData = sesh.trainingData;
  }

  //todo this copyWith kinda sucks bc I have to copy all the fields manually
  TrainingSession copyWith({required List<SetsOfAnExercise> trainingData}) {
    return TrainingSession(
      id: id,
      name: name,
      duration: duration,
      date: dateTime,
      notes: notes,
      isOngoing: isOngoing,
      trainingData: trainingData,
    );
  }

  factory TrainingSession.fromJson(Map<String, dynamic> json) => _$TrainingSessionFromJson(json);
  Map<String, dynamic> toJson() => _$TrainingSessionToJson(this);
}

@JsonSerializable()
class SetsOfAnExercise {
  /*final*/ Exercise ex;
  /*final*/ Set prevSet; //also functions as a header template
  List<Set> sets = [];

  SetsOfAnExercise(this.ex) : prevSet = Set(ex) {
    if (sets.isEmpty) sets.add(Set(ex));
  }

  factory SetsOfAnExercise.fromJson(Map<String, dynamic> json) => _$SetsOfAnExerciseFromJson(json);
  Map<String, dynamic> toJson() => _$SetsOfAnExerciseToJson(this);
}

@JsonSerializable()
class Set {
  /*final*/ Exercise ex;
  late /*final*/ String id; //just the datetime for now
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

class TrainingHistoryCubit extends HydratedCubit<List<TrainingSession>> {
  TrainingHistoryCubit() : super([]);

  void addSession(TrainingSession sesh) {
    state.add(sesh);
    emit(state);
  }

  @override
  List<TrainingSession>? fromJson(Map<String, dynamic> json) {
    List<TrainingSession> seshes = [];
    for (var sesh in json['trainingHistory']) {
      seshes.add(TrainingSession.fromJson(sesh));
    }
    return seshes;
  }

  @override
  Map<String, dynamic>? toJson(List<TrainingSession> state) {
    List<Map<String, dynamic>> seshes = [];
    for (var sesh in state) {
      seshes.add(sesh.toJson());
    }
    return {'trainingHistory': seshes};
  }
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
    state.trainingData.add(SetsOfAnExercise(ex));
    emit(state);
  }

  void removeExercise(Exercise ex) {
    state.trainingData.removeWhere((element) => element.ex == ex);
    emit(state);
  }

  void addSet(Exercise ex) {
    var newTrainingData = state.trainingData.toList();
    newTrainingData.firstWhere((element) => element.ex == ex).sets.add(Set(ex));
    emit(state.copyWith(trainingData: newTrainingData));
  }

  void removeSet(Exercise ex, String setId) {
    SetsOfAnExercise setsOfAnExercise = state.trainingData.firstWhere((element) => element.ex == ex);
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
    emit(state);
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

  @override
  TrainingSession? fromJson(Map<String, dynamic> json) {
    return TrainingSession.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(TrainingSession state) {
    return state.toJson();
  }

  void updateDuration() async {
    state.duration = DateTime.now().difference(state.dateTime);
    emit(state);
  }
}
