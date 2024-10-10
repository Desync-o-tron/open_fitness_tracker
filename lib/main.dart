import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:open_fitness_tracker/DOM/basic_user_info.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/cloud_io/firestore_sync.dart';
import 'package:open_fitness_tracker/exercises/create_new_exercise/create_new_ex_modal.dart';
import 'package:open_fitness_tracker/exercises/ex_search_cubit.dart';
import 'package:open_fitness_tracker/firebase_options.dart';
import 'package:open_fitness_tracker/importing/history_importing_cubits.dart';
import 'package:open_fitness_tracker/navigation/routes.dart';
import 'package:open_fitness_tracker/styles.dart';
import 'package:path_provider/path_provider.dart';

/*
todo 
I just want to see if the damn pages load & waht load times are like..
are firebase sign ins rate limited?
*/
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  CloudStorage.init();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );

  runApp(const MyApp());
}

Timer? trainingDurationTimer;

class MyApp extends StatelessWidget {
  final FirebaseFirestore? fakeFirestore;
  final FirebaseAuth? fakeFirebaseAuth;
  const MyApp({
    this.fakeFirestore,
    this.fakeFirebaseAuth,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TrainingSessionCubit()),
        BlocProvider(create: (_) => CreateNewExCubit()),
        BlocProvider(create: (_) => BasicUserInfoCubit()),
        BlocProvider(create: (_) => ImportedTrainingSessionsCubit()),
        BlocProvider(create: (_) => ImportedExerciseMatchesCubit()),
        BlocProvider(
          create: (_) => ExercisesCubit()..loadExercises(useCache: false),
          lazy: false,
        ),
        BlocProvider(
          create: (_) => ExSearchCubit(exercisesCubit: context.read<ExercisesCubit>()),
        ),
        BlocProvider(
          create: (_) => TrainingHistoryCubit()..loadUserTrainingHistory(useCache: false),
          lazy: false,
        ),
      ],
      child: Builder(builder: (context) {
        //setup stoof:
        if (fakeFirestore == null) {
          //then this is not a smoke test.
          // if we want to do bigger app tests..maybe we can enable this
          trainingDurationTimer = Timer.periodic(
            const Duration(seconds: 1),
            (timer) {
              context.read<TrainingSessionCubit>().updateDuration();
            },
          );
        } else {
          CloudStorage.init(fakeFirestore, fakeFirebaseAuth);
        }

        //and so we begin:
        return MaterialApp.router(
          theme: myTheme,
          routerConfig: appRouter,
          title: 'Open Fitness Tracker',
        );
      }),
    );
  }
}
