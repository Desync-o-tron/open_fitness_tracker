import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_fitness_tracker/navigation/routes.dart';

class NavBarController {
  static Map<int, String> navBarRoutes = {
    0: routeNames.Community.text,
    1: routeNames.History.text,
    2: routeNames.Training.text,
    3: routeNames.Exercises.text,
  };

  static int getCurrentPageIndex(BuildContext context) {
    final String currentPageName = GoRouterState.of(context).uri.toString();
    int pageIndex = 0;
    navBarRoutes.forEach((int index, String routeName) {
      if (currentPageName == routeName) {
        pageIndex = index;
      }
    });
    return pageIndex;
  }

  static void onItemTapped(int index, BuildContext context) {
    if (navBarRoutes.containsKey(index)) {
      GoRouter.of(context).go(navBarRoutes[index]!);
    }
  }
}
