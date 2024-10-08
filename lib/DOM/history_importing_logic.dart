import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'training_metadata.dart';
import 'exercise_metadata.dart';

List<TrainingSession> importStrongCsv(String filepathORfileStr, Units units,
    [bool forTesting = false]) {
  final List<String> rows;
  if (kIsWeb || forTesting) {
    rows = filepathORfileStr.split("\n");
    if (rows.last.isEmpty) {
      rows.removeLast();
    }
  } else {
    rows = File(filepathORfileStr).readAsLinesSync();
  }
  rows.removeAt(0);

  //todo save the header.. if it ever changes, lets make a pub/sub topic on gcs or some error medium to lmk!!!
  List<TrainingSession> sessions = [];
  Exercise exercise = Exercise(name: "temp");
  TrainingSession session = TrainingSession(name: "temp", date: DateTime.now());
  SetsOfAnExercise setsOfExercise = SetsOfAnExercise(exercise)..sets = [];
  bool firstRun = true;

  for (int i = 0; i < rows.length; i++) {
    var row = rows[i];
    var rowList = const CsvToListConverter().convert(row, shouldParseNumbers: false);
    final date = DateFormat("yyyy-MM-dd HH:mm:ss").parse(rowList[0][0]);
    final workoutName = rowList[0][1];
    final duration = parseStrongWorkoutDuration(rowList[0][2]);
    final exerciseName = rowList[0][3];
    // final _setOrder = int.parse(rowList[0][4]); // todo unused..why this here
    final weightRaw = double.tryParse(rowList[0][5]) ?? 0;
    final weight = double.parse(weightRaw.toStringAsFixed(2));
    final reps = int.tryParse(rowList[0][6]) ?? 0;
    final distanceRaw = double.tryParse(rowList[0][7]) ?? 0;
    final distance = double.parse(distanceRaw.toStringAsFixed(2));
    final seconds = int.tryParse(rowList[0][8]) ?? 0;
    final notes = rowList[0][9];
    final workoutNotes = rowList[0][10];

    if (firstRun) {
      firstRun = false;
      exercise = Exercise(name: exerciseName, notes: notes);
      setsOfExercise = SetsOfAnExercise(exercise)..sets = [];
      session = TrainingSession(
        name: workoutName,
        dateOfLastEdit: date,
        date: date,
        duration: duration,
        notes: workoutNotes,
      );
    }
    bool newExercise = false;
    if (exerciseName != exercise.name) {
      newExercise = true;
    }

    if ((i == rows.length - 1)) {
      print("object");
    }

    //todo implement notes history.
    exercise = Exercise(name: exerciseName, notes: notes);
    final set = Set(exercise)
      ..reps = reps
      ..weight = weight
      ..distance = distance
      ..time = seconds.toDouble()
      ..massUnits = units.preferredMassUnit
      ..distanceUnits = units.preferredDistanceUnit
      ..completed = true;

    if (!newExercise) {
      setsOfExercise.sets.add(set);
    }
    if ((newExercise) || (i == rows.length - 1)) {
      session.trainingData.add(setsOfExercise);
      setsOfExercise = SetsOfAnExercise(exercise)..sets = [set];
      if ((i == rows.length - 1) && !isNewSession(session, duration, workoutName, date)) {
        session.trainingData.add(setsOfExercise);
      }
    }

    // if (isNewSession(session, duration, workoutName, date) || (i == rows.length - 1)) {
    //   sessions.add(session);
    // }
    if (isNewSession(session, duration, workoutName, date)) {
      sessions.add(session);
      session = TrainingSession(
        name: workoutName,
        dateOfLastEdit: date,
        date: date,
        duration: duration,
        notes: workoutNotes,
        trainingData: [setsOfExercise],
      );
    }
    if (i == rows.length - 1) {
      sessions.add(session);
    }
  }

  //TODO lets run through all the sessions and update the setMetrics.
  // setMetrics: ['reps', 'weight', 'distance', 'time'],

  return sessions;
}

bool isNewSession(
    TrainingSession session, Duration duration, workoutName, DateTime date) {
  return duration != session.duration ||
      workoutName != session.name ||
      date != session.date;
}

void setupSetMetrics(SetsOfAnExercise setsOfExercise) {
  List<String> setMetrics = [];
  //strong is going to give a value of 0 instead of null for things.
  for (var set in setsOfExercise.sets) {
    if (set.reps! > 0) setMetrics.add("reps");
    if (set.weight! > 0) setMetrics.add("weight");
    if (set.distance! > 0) setMetrics.add("distance");
    if (set.time! > 0) setMetrics.add("time");
  }
  for (var set in setsOfExercise.sets) {
    if (!setMetrics.contains('reps')) set.reps = null;
    if (!setMetrics.contains('weight')) set.weight = null;
    if (!setMetrics.contains('distance')) set.distance = null;
    if (!setMetrics.contains('time')) set.time = null;
  }
  setsOfExercise.ex.setMetrics = setMetrics;
  setsOfExercise.prevSet = Set(setsOfExercise.ex);
  // setsOfExercise.prevSet = setsOfExercise.sets.last;
  //TODO this is bs. need a function to run after we have sorted sets by time.
}

Duration parseStrongWorkoutDuration(String s) {
  int hours = 0;
  int minutes = 0;
  int seconds = 0;
  List<String> parts = s.split(' ');

  for (String part in parts) {
    if (part.contains('h')) {
      part = part.replaceFirst(RegExp(r'h'), '');
      hours = int.parse(part);
    } else if (part.contains('m')) {
      part = part.replaceFirst(RegExp(r'm'), '');
      minutes = int.parse(part);
    } else if (part.contains('s')) {
      part = part.replaceFirst(RegExp(r's'), '');
      seconds = int.parse(part);
    } else {
      throw Exception('Could not parse strong workout duration: $s');
    }
  }
  return Duration(hours: hours, minutes: minutes, seconds: seconds);
}
//todo break this and make sure it fails well..

class Units {
  MassUnits preferredMassUnit = MassUnits.lb;
  DistanceUnits preferredDistanceUnit = DistanceUnits.miles;
}
