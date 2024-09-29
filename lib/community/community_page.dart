import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider, AuthProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_fitness_tracker/cloud_io/firestore_sync.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';
import 'package:open_fitness_tracker/community/charts.dart';
import 'package:open_fitness_tracker/navigation/routes.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const CommunityPageTitle(),
        const SignInOrProfileWidget(),
        Container(height: 50),
        const CoolChart(),
      ],
    );
  }
}

class SignInOrProfileWidget extends StatefulWidget {
  const SignInOrProfileWidget({super.key});

  @override
  State<SignInOrProfileWidget> createState() => _SignInOrProfileWidgetState();
}

class _SignInOrProfileWidgetState extends State<SignInOrProfileWidget> {
  @override
  Widget build(BuildContext context) {
    CloudStorage.firebaseAuth.authStateChanges().listen((User? user) {
      if (mounted) setState(() {});
    });
    if (CloudStorage.firebaseAuth.currentUser == null) {
      return Column(
        children: [
          const Text(
            'Sign in to backup your training & exercise data!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          MyGenericButton(
            onPressed: () {
              context.push(routeNames.SignIn.text);
            },
            label: 'Sign in',
          ),
        ],
      );
    } else {
      return Column(
        children: [
          MyGenericButton(
            onPressed: () => context.push(routeNames.Profile.text),
            label: "Profile",
          ),
          MyGenericButton(
            onPressed: () => context.push(routeNames.UserSettings.text),
            label: "Settings",
          ),
        ],
      );
    }
  }
}

class CommunityPageTitle extends StatelessWidget {
  const CommunityPageTitle({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10.0),
        child: Text(
          'Community & Stats',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
