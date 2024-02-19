import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';

class TrainingSession {
  String? id;
  String? name;
  Duration? duration;
  DateTime? date;
  String? notes;
  List<SetsOfAnExercise> trainingData = [];

  TrainingSession copyWith({required List<SetsOfAnExercise> trainingData}) {
    return TrainingSession()
      ..id = id
      ..name = name
      ..duration = duration
      ..date = date
      ..notes = notes
      ..trainingData = trainingData;
  }
}

class SetsOfAnExercise {
  final Exercise ex;
  final Set prevSet; //also functions as a header template
  List<Set> sets = [];

  SetsOfAnExercise(this.ex) : prevSet = Set(ex) {
    if (sets.isEmpty) sets.add(Set(ex));
  }
}

class Set {
  final Exercise ex;
  num? reps;
  num? time;
  num? weight;
  num? distance;
  num? speed;
  bool completed = false;
  //todo add units.  weight, distance, speed, time etc..

  Set(this.ex) {
    if (ex.setMetrics!.contains('reps')) reps = 0;
    if (ex.setMetrics!.contains('weight')) weight = 0;
    if (ex.setMetrics!.contains('time')) time = 0;
    if (ex.setMetrics!.contains('distance')) distance = 0;
    if (ex.setMetrics!.contains('speed')) speed = 0;
    //todo
    //if contains anythign else, throw error
  }
}

class TrainingSessionCubit extends Cubit<TrainingSession> {
  TrainingSessionCubit() : super(TrainingSession()) {
    var bench = Exercise(
      name: "Bench Press",
      equipment: "Barbell",
      primaryMuscles: ["Chest", "Triceps"],
      setMetrics: ["reps", "weight"],
    );
    var squat = Exercise(
      name: "Squat",
      equipment: "Barbell",
      primaryMuscles: ["Quadriceps", "Glutes"],
      setMetrics: ["reps", "weight"],
    );
    // var exampleExerciseSet = SetsOfAnExercise(bench);
    // var exampleExerciseSet2 = SetsOfAnExercise(squat);
    // exampleExerciseSet.prevSet = Set(exampleExerciseSet.ex);
    // exampleExerciseSet2.sets.add(Set(exampleExerciseSet2.ex));
    state.trainingData.add(SetsOfAnExercise(bench));
    state.trainingData.add(SetsOfAnExercise(squat));
    //lets add some example sets
    // Set set1 = Set(exampleExerciseSet.ex);
    Set benchSet = state.trainingData[0].sets[0];
    benchSet.reps = 10;
    benchSet.weight = 135;
    // exampleExerciseSet.sets.add(set1);
  }

  void addExercise(Exercise ex) {
    state.trainingData.add(SetsOfAnExercise(ex));
    emit(state);
  }

  // void removeExercise(Exercise ex) {
  //   state.trainingData.removeWhere((element) => element.ex == ex);
  //   emit(state);
  // }

  void addSet(Exercise ex) {
    var newTrainingData = state.trainingData.toList();
    newTrainingData.firstWhere((element) => element.ex == ex).sets.add(Set(ex));
    emit(state.copyWith(trainingData: newTrainingData));
  }

  // void removeSet(Exercise ex, Set set) {
  //   state.trainingData
  //       .firstWhere((element) => element.ex == ex)
  //       .sets
  //       .remove(set);
  //   emit(state);
  // }

  void updateSet(Exercise ex, Set set, int setIndex) {
    var newTrainingData = state.trainingData.toList();
    newTrainingData.firstWhere((element) => element.ex == ex).sets[setIndex] = set;
    emit(state.copyWith(trainingData: newTrainingData));
  }
}
