// import 'package:firebase_core/firebase_core.dart';
// import 'package:open_fitness_tracker/firebase_options.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:open_fitness_tracker/navigation/routes.dart';
import 'package:open_fitness_tracker/state.dart';
import 'package:open_fitness_tracker/styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadExerciseData();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(const ProviderScope(child: MyApp()));
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
