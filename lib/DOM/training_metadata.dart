import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';

class TrainingSession {
  String? id;
  String? name;
  Duration? duration;
  DateTime? date;
  String? notes;
  List<ExerciseSets> trainingData = [];
}

class ExerciseSets {
  final Exercise ex;
  final Set prevSet; //also functions as a header template
  List<Set> sets = [];

  ExerciseSets(this.ex) : prevSet = Set(ex);
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
