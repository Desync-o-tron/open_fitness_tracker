import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';

class ExerciseSets {
  final Exercise ex;
  List<Set> sets = [];
  ExerciseSets(this.ex);
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

class TrainingSession {
  String? id;
  String? name;
  DateTime? date;
  List<ExerciseSets> trainingData = [];
}
