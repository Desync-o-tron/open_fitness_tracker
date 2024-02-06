// import 'package:firebase_core/firebase_core.dart';
// import 'package:open_fitness_tracker/firebase_options.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:open_fitness_tracker/navigation/routes.dart';
import 'package:open_fitness_tracker/styles.dart';
import 'dart:convert';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:flutter/services.dart' show rootBundle;

class gs {
  static List<Exercise> exercises = [];
  static List<String> getExerciseNames = exercises.map((e) => e.name).toList();
}

Future<void> loadExerciseData() async {
  String jsonString = await rootBundle.loadString('assets/data/exercises.json');
  gs.exercises = (json.decode(jsonString) as List).map((e) => Exercise.fromJson(e)).toList();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadExerciseData();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: darkTan)),
      routerConfig: routerConfig,
      title: 'Open Fitness Tracker',
    );
  }
}
