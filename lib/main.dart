import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/exercises/create_new_exercise/create_new_ex_modal.dart';
import 'package:open_fitness_tracker/exercises/ex_search_cubit.dart';
import 'package:open_fitness_tracker/navigation/routes.dart';
import 'package:open_fitness_tracker/state.dart';
import 'package:open_fitness_tracker/styles.dart';
import 'package:open_fitness_tracker/state.dart' as appState;
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await appState.Storage.init();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb ? HydratedStorage.webStorageDirectory : await getApplicationDocumentsDirectory(),
  );
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ExSearchCubit(),
        ),
        BlocProvider(
          create: (_) => TrainingSessionCubit(),
        ),
        BlocProvider(
          create: (_) => TrainingHistoryCubit(),
        ),
        BlocProvider(
          create: (_) => CreateNewExCubit(),
        ),
      ],
      child: Builder(builder: (context) {
        appState.Storage.loadCurrentTrainingSesh(
          context,
          context.read<TrainingSessionCubit>(),
        );
        return MaterialApp.router(
          theme: myTheme,
          routerConfig: routerConfig,
          title: 'Open Fitness Tracker',
        );
      }),
    );
  }
}
