import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:open_fitness_tracker/cloud_io/firestore_sync.dart';
import 'nav_bar_controller.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    User? user = cloudStorage.firebaseAuth.currentUser;
    bool isLoggedIn = user != null;

    return Scaffold(
      body: SafeArea(
        child: child,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.history,
              color: isLoggedIn ? null : Colors.grey,
            ),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_box,
              color: isLoggedIn ? null : Colors.grey,
            ),
            label: 'Training',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.fitness_center,
              color: isLoggedIn ? null : Colors.grey,
            ),
            label: 'Exercises',
          ),
        ],
        currentIndex: NavBarController.getCurrentPageIndex(context),
        onTap: (int index) {
          if (isLoggedIn || index < 1) {
            NavBarController.onItemTapped(index, context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please sign in first')),
            );
          }
        },
        selectedItemColor: Theme.of(context).colorScheme.inversePrimary,
        backgroundColor: Theme.of(context).colorScheme.primary,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Theme.of(context).colorScheme.inverseSurface,
      ),
    );
  }
}
