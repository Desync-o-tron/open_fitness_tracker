import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider, AuthProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';
import 'package:open_fitness_tracker/navigation/routes.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        CommunityPageTitle(),
        SignInOrProfileWidget(),
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
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) setState(() {});
    });
    if (FirebaseAuth.instance.currentUser == null) {
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
      return MyGenericButton(
        onPressed: () => context.push(routeNames.Profile.text),
        label: "Profile",
      );
    }
  }
}

class CommunityPageTitle extends StatelessWidget {
  const CommunityPageTitle({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10.0),
      child: Text(
        'Community',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
