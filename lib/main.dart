import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/cloud_io/firestore_sync.dart';
import 'package:open_fitness_tracker/exercises/create_new_exercise/create_new_ex_modal.dart';
import 'package:open_fitness_tracker/exercises/ex_search_cubit.dart';
import 'package:open_fitness_tracker/firebase_options.dart';
import 'package:open_fitness_tracker/navigation/routes.dart';
import 'package:open_fitness_tracker/DOM/exercise_db.dart';
import 'package:open_fitness_tracker/styles.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ExDB.init(); //todo migrate to firestore

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  myStorage.refreshTrainingHistoryCacheIfItsBeenXHours(12);

  HydratedStorage hydratedStorage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );
  HydratedBloc.storage = hydratedStorage;

  runApp(const MyApp());
}

Timer? trainingDurationTimer;

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
          create: (_) => CreateNewExCubit(),
        ),
      ],
      child: Builder(builder: (context) {
        trainingDurationTimer = Timer.periodic(
          const Duration(seconds: 1),
          (timer) {
            context.read<TrainingSessionCubit>().updateDuration();
          },
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
