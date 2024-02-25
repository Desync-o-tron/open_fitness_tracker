// ignore_for_file: constant_identifier_names, camel_case_types
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:open_fitness_tracker/community/community_page.dart';
import 'package:open_fitness_tracker/exercises/ex_search_page.dart';
import 'package:open_fitness_tracker/history/history_page.dart';
import 'package:open_fitness_tracker/navigation/page_not_found_page.dart';
import 'package:open_fitness_tracker/navigation/scaffold_with_nav_bar.dart';
import 'package:open_fitness_tracker/training/start_training_page.dart';
import 'package:open_fitness_tracker/training/training_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

enum routeNames {
  Community("/Community"),
  History("/History"),
  Training("/Training"),
  Exercises("/Exercises"),
  Temp("/Temp"),
  Home("/");

  const routeNames(this.text);
  final String text;
}

final GoRouter routerConfig = GoRouter(
  errorBuilder: (context, state) => const ScaffoldWithNavBar(child: PageNotFoundPage()),
  navigatorKey: _rootNavigatorKey,
  initialLocation: routeNames.Temp.text,
  // initialLocation: routeNames.Training.text, //////////<--- This is the initial route
  // initialLocation: routeNames.Exercises.text, //////////<--- This is the initial route
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (BuildContext context, GoRouterState state, Widget child) => ScaffoldWithNavBar(child: child),
      routes: [
        GoRoute(
          path: routeNames.Home.text,
          builder: (BuildContext context, GoRouterState state) => const StartTrainingPage(),
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
          builder: (BuildContext context, GoRouterState state) => const StartTrainingPage(),
        ),
        GoRoute(
          path: routeNames.Exercises.text,
          builder: (BuildContext context, GoRouterState state) => const ExercisesPage(),
        ),
        GoRoute(
          //temp
          path: routeNames.Temp.text,
          builder: (BuildContext context, GoRouterState state) => const TrainingPage(),
        ),
      ],
    ),
  ],
);
