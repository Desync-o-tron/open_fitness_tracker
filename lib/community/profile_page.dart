import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider, AuthProvider;
import 'package:go_router/go_router.dart';
import 'package:open_fitness_tracker/navigation/routes.dart';

const googleWebClientId = '211289236675-k3i6icakr22iqlu63ponloimuh75506a.apps.googleusercontent.com';

final List<AuthProvider<AuthListener, AuthCredential>> providers = [
  EmailAuthProvider(),
  GoogleProvider(clientId: googleWebClientId),
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
