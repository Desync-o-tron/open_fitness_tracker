import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:open_fitness_tracker/firebase_options.dart';
import 'package:open_fitness_tracker/navigation/routes.dart';
import 'package:open_fitness_tracker/styles.dart';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<void> loadExerciseData() async {
  String jsonString = await rootBundle.loadString('assets/data/my_data.json');
  final jsonResponse = json.decode(jsonString);
  // Use the jsonResponse as needed
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
