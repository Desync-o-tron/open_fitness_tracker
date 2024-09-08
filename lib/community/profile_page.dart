import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider, AuthProvider;
import 'package:go_router/go_router.dart';
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
  AppleProvider(),
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
        SignedOutAction((context) {
          context.go(routeNames.Community.text);
        }),
      ],
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            context.pop();
          },
        ),
      ),
      children: [
        if (!FirebaseAuth.instance.currentUser!.emailVerified)
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
      providers: providers,
      actions: [
        AuthStateChangeAction<SignedIn>((context, state) {
          if (!state.user!.emailVerified) {
            context.push(routeNames.VerifyEmail.text);
          } else {
            context.go(routeNames.Community.text);
          }
        }),
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
      // actionCodeSettings: ActionCodeSettings(),
      actions: [
        EmailVerifiedAction(() {
          context.go(routeNames.Profile.text);
        }),
        AuthCancelledAction((context) {
          context.pop();
        }),
      ],
    );
  }
}
