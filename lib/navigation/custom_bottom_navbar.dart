// import 'package:flutter/material.dart';

// class CustomBottomNavBar extends StatelessWidget {
//   final int selectedIndex;
//   final Function(int) onItemTapped;

//   const CustomBottomNavBar({
//     super.key,
//     required this.selectedIndex,
//     required this.onItemTapped,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       items: const <BottomNavigationBarItem>[
//         BottomNavigationBarItem(
//           icon: Icon(Icons.group),
//           label: 'Community',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.history),
//           label: 'History',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.add_box),
//           label: 'Workout',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.fitness_center),
//           label: 'Exercises',
//         ),
//       ],
//       currentIndex: selectedIndex,
//       onTap: onItemTapped,
//       selectedItemColor: Theme.of(context).colorScheme.inversePrimary,
//       backgroundColor: Theme.of(context).colorScheme.primary,
//       type: BottomNavigationBarType.fixed,
//       unselectedItemColor: Theme.of(context).colorScheme.inverseSurface,
//     );
//   }
// }
