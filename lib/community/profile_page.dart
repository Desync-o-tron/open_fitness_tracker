import 'dart:io';

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider, AuthProvider;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:open_fitness_tracker/cloud_io/firestore_sync.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';
import 'package:open_fitness_tracker/firebase_options.dart';
import 'package:open_fitness_tracker/navigation/routes.dart';
import 'package:flutter/foundation.dart';

const googleiOSClientId =
    '211289236675-ukl69kitoa47hbvfi84kku4ka9s6buf0.apps.googleusercontent.com'; //not a secret.
String get googleClientId {
  return switch (defaultTargetPlatform) {
    TargetPlatform.iOS => googleiOSClientId,
    TargetPlatform.android => DefaultFirebaseOptions.android.apiKey,
    // real weird, macOS will get triggered if using web on mac..
    // TargetPlatform.macOS => throw Exception('run flutterfire config for mac when ready'),
    // TargetPlatform.windows => throw Exception('run flutterfire config for win  when ready'),
    // TargetPlatform.linux => throw Exception('no support yet in 2024'),
    _ => DefaultFirebaseOptions.web.apiKey,
  };
}

final List<AuthProvider<AuthListener, AuthCredential>> providers = [
  if (kIsWeb || Platform.isMacOS || Platform.isIOS) AppleProvider(),
  EmailAuthProvider(),
  GoogleProvider(clientId: googleClientId),
];

class ProfileScreenWrapper extends StatelessWidget {
  const ProfileScreenWrapper({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileScreen(
      showDeleteConfirmationDialog: true,
      showUnlinkConfirmationDialog: true,
      providers: providers,
      actions: [
        SignedOutAction((BuildContext context) {
          context.pushReplacement(routeNames.SignIn.text);
        }),
      ],
      appBar: AppBar(
        leading: Navigator.of(context).canPop()
            ? BackButton(
                onPressed: () {
                  context.pop();
                },
              )
            : Container(),
      ),
      children: [
        if (!CloudStorage.firebaseAuth.currentUser!.emailVerified)
          MyGenericButton(
            onPressed: () {
              context.push(routeNames.VerifyEmail.text);
            },
            label: 'Send Email Verification',
          ),
      ],
    );
  }
}

class SignInScreenWrapper extends StatelessWidget {
  const SignInScreenWrapper({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      auth: CloudStorage.firebaseAuth,
      providers: providers,
      // todo maybe migrate this function somewhere..routes.dart orrr firebase_sync.dart?
      //idk. it's a bit hidden here.

      // I double check auth in routes.dart now, but...synergy.
      // I'm too dumb to get it to work only there. that's fine I think
      actions: [
        AuthStateChangeAction((context, state) {
          final user = switch (state) {
            SignedIn(user: final user) => user,
            CredentialLinked(user: final user) => user,
            UserCreated(credential: final cred) => cred.user,
            _ => null,
          };
          switch (user) {
            case User(emailVerified: true):
              {
                final trainingHistoryCubit = context.read<TrainingHistoryCubit>();
                if (trainingHistoryCubit.state is TrainingHistoryError) {
                  trainingHistoryCubit.loadUserTrainingHistory();
                }
                final exercisesCubit = context.read<ExercisesCubit>();
                if (exercisesCubit.state is TrainingHistoryError) {
                  exercisesCubit.loadExercises();
                }
                appRouter.pushReplacement(routeNames.Profile.text);
              }
            case User(emailVerified: false, email: final String _):
              appRouter.pushReplacement(routeNames.VerifyEmail.text);
          }
        })
      ],
    );
  }
}

class EmailVerificationScreenWrapper extends StatelessWidget {
  const EmailVerificationScreenWrapper({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return EmailVerificationScreen(
      actions: [
        EmailVerifiedAction(() {
          context.pushReplacement(routeNames.Profile.text);
        }),
        AuthCancelledAction((context) {
          context.pushReplacement(routeNames.Profile.text);
        }),
      ],
    );
  }
}
