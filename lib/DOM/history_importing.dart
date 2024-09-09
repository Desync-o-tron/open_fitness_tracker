import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'training_metadata.dart';
import 'exercise_metadata.dart';

List<TrainingSession> importStrongCsv(String filePath) {
  final List<String> rows = File(filePath).readAsLinesSync();
  rows.removeAt(0); //todo we should save teh header & compare it to see if it ever changes and bricks shit
  //todo save the header.. if it ever changes, lets make a pub/sub topic on gcs or some error medium to lmk!!!
  List<TrainingSession> sessions = [];
  Exercise exercise = Exercise(
    name: "temp",
    setMetrics: ['reps', 'weight', 'distance', 'time'],
    equipment: 'temp',
    primaryMuscles: ['temp'],
  );
  TrainingSession session = TrainingSession(
    name: "temp",
    date: DateTime.now(),
  );
  SetsOfAnExercise setsOfExercise = SetsOfAnExercise(exercise);
  bool firstRun = true;
  for (var row in rows) {
    final rowList = const CsvToListConverter().convert(row, shouldParseNumbers: false); // as List<String>;
    final date = DateFormat("yyyy-MM-dd HH:mm:ss").parse(rowList[0][0]);
    final workoutName = rowList[0][1];
    final duration = parseStrongWorkoutDuration(rowList[0][2]);
    final exerciseName = rowList[0][3];
    // final _setOrder = int.parse(rowList[0][4]); // unused..why this here
    final weight = double.tryParse(rowList[0][5]) ?? 0;
    final reps = int.tryParse(rowList[0][6]) ?? 0;
    final distance = double.tryParse(rowList[0][7]) ?? 0;
    final seconds = int.tryParse(rowList[0][8]) ?? 0;
    // final notes = rowList[0][9]; //todo add me
    final workoutNotes = rowList[0][10];

    if ((duration != session.duration || session.name != workoutName || date != session.dateTime) &&
        !firstRun) {
      sessions.add(session);

      session.name = workoutName;
      session.dateOfLastEdit = date;
      session.dateTime = date;
      session.duration = duration;
      session.notes = workoutNotes;
    }

    if (exerciseName != exercise.name && !firstRun) {
      List<String> setMetrics = []; // ['reps', 'weight', 'distance', 'time'];
      //I hope we dont condition on the nully-ness of set.reps, etc..
      //strong is going to give a value of 0 instead of null for things.
      for (var set in setsOfExercise.sets) {
        if (set.reps! > 0) {
          setMetrics.add("reps");
        }
        if (set.weight! > 0) {
          setMetrics.add("weight");
        }
        if (set.distance! > 0) {
          setMetrics.add("distance");
        }
        if (set.time! > 0) {
          setMetrics.add("time");
        }
      }
      setsOfExercise.ex.setMetrics = setMetrics;
      session.trainingData.add(setsOfExercise);
    }

    final set = Set(exercise)
      ..reps = reps
      ..weight = weight
      ..distance = distance
      ..time = seconds.toDouble()
      ..completed = true;

    setsOfExercise.sets.add(set);

    firstRun = false;
  }

  return sessions;
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
