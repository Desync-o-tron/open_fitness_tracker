import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
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

  FirebaseApp firebase = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  HydratedStorage hydratedStorage = await HydratedStorage.build(
    storageDirectory: kIsWeb ? HydratedStorage.webStorageDirectory : await getApplicationDocumentsDirectory(),
  );
  HydratedBloc.storage = hydratedStorage;

  runApp(const MyApp());
}

Timer? trainingDurationTimer;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // _myAsyncMethod() async {
  //   var ff = FirebaseFirestore.instance;
  //   final user = <String, dynamic>{"first": "hmm!", "last": "Lovelace", "born": 1815};
  //   // await ff.collection("users").get().then((event) {
  //   //   for (var doc in event.docs) {
  //   //     print("${doc.id} => ${doc.data()}");
  //   //   }
  //   // });
  //   // Add a new document with a generated ID
  //   ff
  //       .collection("users")
  //       .add(user)
  //       .then((DocumentReference doc) => print('DocumentSnapshot added with ID: ${doc.id}'));

  //   var usrCollection = ff.collection('users');
  //   // var athing = await usrCollection.get();

  //   // await usrCollection.add({"aoeu": "sth"});
  //   var usrdoc = usrCollection.doc("0qYo6ihSKsh8s6dsLksQ2N6WLek2");
  //   await usrdoc.set({"buttttX new": "stuff"}); //, SetOptions());
  //   try {
  //     var newcol = usrdoc.collection("newcol");
  //     await newcol.add({"akey": "aval"});
  //   } catch (e) {
  //     print('crap');
  //   }
  //   print("object");
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   _myAsyncMethod();
  // }

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
            // context.read<TrainingSessionCubit>().updateDuration();
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
