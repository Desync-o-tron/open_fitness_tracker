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
  await ExDB.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  HydratedStorage hydratedStorage = await HydratedStorage.build(
    storageDirectory: kIsWeb ? HydratedStorage.webStorageDirectory : await getApplicationDocumentsDirectory(),
  );

  HydratedBloc.storage = hydratedStorage;
  cloudStorage = FirestoreHydratedStorageSync(hydratedStorage);
  cloudStorage.sync();

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
          create: (_) => TrainingHistoryCubit(),
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

        cloudStorage.setOnHistoryUpdate(() {
          //just need to get the visual state update to trigger..
          TrainingSession tempSesh = TrainingSession();
          context.read<TrainingHistoryCubit>().addSession(tempSesh);
          context.read<TrainingHistoryCubit>().removeSession(tempSesh);

          //lets just update the traininghistorycubit here too & see what happens!
          //storage.write(historyKey, {'trainingHistory': stringifiedHistory});
          // var json = cloudStorage.storage.read('TrainingHistoryCubit');

          // for (var str in json['trainingHistory']) {
          //   context.read<TrainingHistoryCubit>().addSession(TrainingSession.fromJson(str));
          // }
        });

        return MaterialApp.router(
          theme: myTheme,
          routerConfig: routerConfig,
          title: 'Open Fitness Tracker',
        );
      }),
    );
  }
}
