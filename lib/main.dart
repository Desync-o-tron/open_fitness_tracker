import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/exercises/create_new_exercise/create_new_ex_modal.dart';
import 'package:open_fitness_tracker/exercises/ex_search_cubit.dart';
import 'package:open_fitness_tracker/firebase_options.dart';
import 'package:open_fitness_tracker/navigation/routes.dart';
import 'package:open_fitness_tracker/DOM/exercise_db.dart';
import 'package:open_fitness_tracker/styles.dart';
import 'package:path_provider/path_provider.dart';

import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider, AuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

const googleWebClientId = '211289236675-k3i6icakr22iqlu63ponloimuh75506a.apps.googleusercontent.com';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ExDB.init();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb ? HydratedStorage.webStorageDirectory : await getApplicationDocumentsDirectory(),
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 'https://www.googleapis.com/auth/contacts.readonly',
  const List<String> scopes = <String>[
    'email',
    'https://www.googleapis.com/auth/userinfo.email',
    'profile',
    'https://www.googleapis.com/auth/userinfo.profile',
  ];

  // GoogleSignIn _googleSignIn = GoogleSignIn(
  //   // Optional clientId
  //   // clientId: 'your-client_id.apps.googleusercontent.com',
  //   clientId: googleWebClientId,
  //   scopes: scopes,
  // );

  // try {
  //   await _googleSignIn.signIn();
  // } catch (error) {
  //   print(error);
  // }

  runApp(const MyApp());
}

Timer? trainingDurationTimer;

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
        trainingDurationTimer = Timer.periodic(
          const Duration(seconds: 1),
          (timer) {
            context.read<TrainingSessionCubit>().updateDuration();
          },
        );

        // return const MaterialApp(
        //   home: SignInPage(),
        // );

        // return MaterialApp.router(
        //   theme: myTheme,
        //   routerConfig: routerConfig,
        //   title: 'Open Fitness Tracker',
        // );

        final List<AuthProvider<AuthListener, AuthCredential>> providers = [
          EmailAuthProvider(),
          // GoogleAuthProvider()
          GoogleProvider(clientId: googleWebClientId),
        ];
        //   FirebaseUIAuth.configureProviders([
        //     GoogleProvider(clientId: googleWebClientId),
        //   ]);

        return MaterialApp(
          initialRoute: FirebaseAuth.instance.currentUser == null ? '/sign-in' : '/profile',
          routes: {
            '/sign-in': (context) {
              return SignInScreen(
                providers: providers,
                actions: [
                  AuthStateChangeAction<SignedIn>((context, state) {
                    Navigator.pushReplacementNamed(context, '/profile');
                  }),
                ],
              );
            },
            '/profile': (context) {
              return ProfileScreen(
                providers: providers,
                actions: [
                  SignedOutAction((context) {
                    Navigator.pushReplacementNamed(context, '/sign-in');
                  }),
                ],
              );
            },
          },
        );
      }),
    );
  }
}
