import 'package:flutter/material.dart';
import 'package:open_fitness_tracker/navigation/routes.dart';
import 'package:open_fitness_tracker/theme.dart';

void main() {
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

    // return MaterialApp(
    //   title: 'Flutter Demo',
    //   theme: ThemeData(
    //     useMaterial3: true,
    //     // primaryColor: Colors.blue,
    //     // secondaryHeaderColor: Colors.green,
    //     hintColor: Colors.yellow,
    //     colorScheme: ColorScheme.fromSeed(seedColor: darkTan), //.copyWith(background: lightTan),
    //     // .copyWith(error: Colors.red)
    //     // .copyWith(background: Colors.white),
    //   ),
    //   home: WorkoutStartSelectionPage(),
    // );
  }
}
