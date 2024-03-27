import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:open_fitness_tracker/navigation/routes.dart';

class NavBarController {
  static Map<int, String> navBarRoutes = {
    // -1: routeNames.None.text,
    0: routeNames.Community.text,
    1: routeNames.History.text,
    2: routeNames.Training.text,
    3: routeNames.Exercises.text,
  };

  static int getCurrentPageIndex(BuildContext context) {
    try {
      final String currentPageName = GoRouterState.of(context).uri.toString();
      int pageIndex = 0;
      navBarRoutes.forEach((int index, String routeName) {
        if (currentPageName == routeName) {
          pageIndex = index;
        }
      });
      return pageIndex;
    } catch (e) {
      return -1;
    }
  }

  static void onItemTapped(int index, BuildContext context) {
    if (navBarRoutes.containsKey(index)) {
      GoRouter.of(context).go(navBarRoutes[index]!);
    }
  }
}
