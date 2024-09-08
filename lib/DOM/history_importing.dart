import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'training_metadata.dart';
import 'exercise_metadata.dart';

Future<List<TrainingSession>> importStrongCsv(String filePath) async {
  // Read the CSV file
  final List<String> rows = File(filePath).readAsLinesSync();
  // final rows2 = const CsvToListConverter().convert(rows);

  // final input = File(filePath).readAsStringSync();
  // final input = File(filePath).readAsLinesSync();
  // final rows = const CsvToListConverter().convert(input, eol: '\n');
  // // Remove header row
  rows.removeAt(0);

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
    // List<List<String>>
    final rowList = const CsvToListConverter().convert(row, shouldParseNumbers: false); // as List<String>;
    // for (var rowStr in rows) {
    //   var row = rowStr.split(',');
    final date = DateFormat("yyyy-MM-dd HH:mm:ss").parse(rowList[0][0]);
    final workoutName = rowList[0][1];
    final duration = parseStrongWorkoutDuration(rowList[0][2]);
    final exerciseName = rowList[0][3];
    // final _setOrder = int.parse(rowList[0][4]); // unused
    final weight = double.tryParse(rowList[0][5]) ?? 0;
    final reps = int.tryParse(rowList[0][6]) ?? 0;
    final distance = double.tryParse(rowList[0][7]) ?? 0;
    final seconds = int.tryParse(rowList[0][8]) ?? 0;
    final notes = rowList[0][9];
    final workoutNotes = rowList[0][10];
    // final date = DateFormat("yyyy-MM-dd HH:mm:ss").parse(row[0]);
    // final workoutName = row[1];
    // final duration = parseStrongWorkoutDuration(row[2]);
    // final exerciseName = row[3];
    // // final _setOrder = int.parse(row[4]); // unused
    // final weight = double.tryParse(row[5]) ?? 0;
    // final reps = int.tryParse(row[6]) ?? 0;
    // final distance = double.tryParse(row[7]) ?? 0;
    // final seconds = int.tryParse(row[8]) ?? 0;
    // final notes = row[9];
    // final workoutNotes = row[10];

    if ((duration != session.duration || session.name != workoutName || date != session.dateTime) &&
        !firstRun) {
      sessions.add(session);

      session.name = workoutName;
      session.dateOfLastEdit = date;
      session.dateTime = date;
      session.duration = duration;
      session.notes = workoutNotes;
    }

    if (exerciseName != exercise.name) {
      exercise = Exercise(
        name: exerciseName,
        setMetrics: ['reps', 'weight', 'distance', 'time'],
        equipment: 'todo',
        primaryMuscles: ['todo'],
        // notes: notes, //todo add this in!
      );
      setsOfExercise = SetsOfAnExercise(exercise);
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
//todo save the header.. if it ever changes, lets make a pub/sub topic on gcs or some error medium to lmk!!!