import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider, AuthProvider;
import 'package:go_router/go_router.dart';
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
      appBar: AppBar(leading: BackButton(
        onPressed: () {
          context.go(routeNames.Community.text);
        },
      )),
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
          context.go(routeNames.Community.text);
        }),
      ],
    );
  }
}
