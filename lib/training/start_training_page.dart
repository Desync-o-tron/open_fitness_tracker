import 'package:flutter/material.dart';
import 'package:open_fitness_tracker/styles.dart';

class StartTrainingPage extends StatelessWidget {
  const StartTrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(children: [
      const Text('Start Training',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          )),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: () {
          // Handle button press
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32.0),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 20.0),
          child: Text(
            'Start a Training Sesh',
            style: largeButtonTextStyle,
          ),
        ),
      ),
    ]));
  }
}
