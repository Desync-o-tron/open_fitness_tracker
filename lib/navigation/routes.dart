// ignore_for_file: constant_identifier_names, camel_case_types
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:open_fitness_tracker/cloud_io/firestore_sync.dart';
import 'package:open_fitness_tracker/community/community_page.dart';
import 'package:open_fitness_tracker/community/profile_page.dart';
import 'package:open_fitness_tracker/community/settings_page.dart';
import 'package:open_fitness_tracker/exercises/ex_search_page.dart';
import 'package:open_fitness_tracker/history/history_page.dart';
import 'package:open_fitness_tracker/importing/import_training_first_page.dart';
import 'package:open_fitness_tracker/navigation/page_not_found_page.dart';
import 'package:open_fitness_tracker/navigation/scaffold_with_nav_bar.dart';
import 'package:open_fitness_tracker/training/start_training_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

enum routeNames {
  Community("/Community"),
  History("/History"),
  Training("/Training"),
  Exercises("/Exercises"),
  SignIn("/SignIn"),
  Profile("/Profile"),
  UserSettings("/UserSettings"),
  VerifyEmail("/VerifyEmail"),
  ImportExternalAppHistory("/ImportExternalAppHistory"),

  None("/None"),
  Temp("/Temp"),
  Home("/");

  const routeNames(this.text);
  final String text;
}

final GoRouter routerConfig = GoRouter(
  errorBuilder: (context, state) => const ScaffoldWithNavBar(child: PageNotFoundPage()),
  navigatorKey: _rootNavigatorKey,
  // initialLocation: routeNames.Temp.text,
  // initialLocation: routeNames.Training.text, //////////<--- This is the initial route
  // initialLocation: routeNames.Exercises.text, //////////<--- This is the initial route
  initialLocation: routeNames.History.text, //////////<--- This is the initial route
  // initialLocation: routeNames.Community.text, //////////<--- This is the initial route
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (BuildContext context, GoRouterState state, Widget child) =>
          ScaffoldWithNavBar(child: child),
      routes: [
        GoRoute(
          path: routeNames.Home.text,
          builder: (BuildContext context, GoRouterState state) =>
              const StartTrainingPage(),
        ),
        GoRoute(
          path: routeNames.Community.text,
          builder: (BuildContext context, GoRouterState state) => const CommunityPage(),
        ),
        GoRoute(
          path: routeNames.History.text,
          builder: (BuildContext context, GoRouterState state) => const HistoryPage(),
        ),
        GoRoute(
          path: routeNames.Training.text,
          builder: (BuildContext context, GoRouterState state) =>
              const StartTrainingPage(),
        ),
        GoRoute(
          path: routeNames.Exercises.text,
          builder: (BuildContext context, GoRouterState state) => ExerciseSearchPage(),
        ),
        GoRoute(
          path: routeNames.SignIn.text,
          builder: (BuildContext context, GoRouterState state) =>
              const SignInScreenWrapper(),
        ),
        GoRoute(
          path: routeNames.Profile.text,
          builder: (BuildContext context, GoRouterState state) =>
              const ProfileScreenWrapper(),
        ),
        GoRoute(
          path: routeNames.UserSettings.text,
          builder: (BuildContext context, GoRouterState state) => const SettingsPage(),
        ),
        GoRoute(
          path: routeNames.VerifyEmail.text,
          builder: (BuildContext context, GoRouterState state) =>
              const EmailVerificationScreenWrapper(),
        ),
        GoRoute(
          path: routeNames.ImportExternalAppHistory.text,
          builder: (BuildContext context, GoRouterState state) =>
              const ImportTrainingDataPage(),
        ),
        GoRoute(
          path: routeNames.Temp.text,
          builder: (BuildContext context, GoRouterState state) =>
              const ImportTrainingDataPage(),
        ),
      ],
    ),
  ],
  //todo is this slow?
  // redirect to the login page if the user is not logged in
  redirect: (BuildContext context, GoRouterState state) async {
    final bool loggedIn = CloudStorage.firebaseAuth.currentUser != null;
    if (!loggedIn) {
      return routeNames.SignIn.text;
    } else if (!CloudStorage.firebaseAuth.currentUser!.emailVerified) {
      if (state.matchedLocation == routeNames.SignIn.text ||
          state.matchedLocation == routeNames.Profile.text ||
          state.matchedLocation == routeNames.VerifyEmail.text) {
        return null;
      } else {
        return routeNames.Profile.text;
      }
    }
    // otherwise no need to redirect at all
    return null;
    //todo I should probably check my codebase for using navigator.of ... b/c it probably won't trigger my redirect.
  },
);
