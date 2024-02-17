// import 'package:firebase_core/firebase_core.dart';
// import 'package:open_fitness_tracker/firebase_options.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_fitness_tracker/exercises/ex_search_page.dart';
import 'package:open_fitness_tracker/navigation/routes.dart';
import 'package:open_fitness_tracker/state.dart';
import 'package:open_fitness_tracker/styles.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadExerciseData();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(const MyApp());
}

final myColorScheme = ColorScheme.fromSwatch(
  primarySwatch: MaterialColor(
    darkTan.value,
    <int, Color>{
      50: darkTan,
      100: darkTan,
      200: darkTan,
      300: darkTan,
      400: darkTan,
      500: darkTan,
      600: darkTan,
      700: darkTan,
      800: darkTan,
      900: darkTan,
    },
  ),
  accentColor: mediumGreen,
  cardColor: darkTan,
  backgroundColor: mediumTan,
  errorColor: darkTan,
  brightness: Brightness.light,
);

final myTheme = ThemeData(
  useMaterial3: true,
  // colorScheme: myColorScheme,
  colorScheme: ColorScheme.fromSeed(seedColor: darkTan),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //this is weird but the providers I create in my gorouter routes are not available in dialogs /:
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ExSearchCubit(),
        ),
      ],
      child: MaterialApp.router(
        theme: myTheme,
        routerConfig: routerConfig,
        title: 'Open Fitness Tracker',
      ),
    );
  }
}
