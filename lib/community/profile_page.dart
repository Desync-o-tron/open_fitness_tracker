import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider, AuthProvider;
import 'package:go_router/go_router.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';
import 'package:open_fitness_tracker/navigation/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:open_fitness_tracker/api_keys.dart';

String get googleClientId {
  return switch (defaultTargetPlatform) {
    TargetPlatform.iOS || TargetPlatform.macOS => googleiOSClientId,
    TargetPlatform.android => googleAndroidClientId,
    _ => googleWebClientId,
  };
}

final List<AuthProvider<AuthListener, AuthCredential>> providers = [
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
