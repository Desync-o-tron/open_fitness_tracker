import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/styles.dart';
import 'package:open_fitness_tracker/training/training_page.dart';

class StartTrainingPage extends StatelessWidget {
  const StartTrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.watch<TrainingSessionCubit>().state.isOngoing) {
      return const TrainingPage();
    }
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: Center(
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
            var trainingSesh = context.read<TrainingSessionCubit>().state;
            trainingSesh.isOngoing = true;
            trainingSesh.date = DateTime.now();
            // Storage.startAutoSavingActiveTrainingSession(trainingSesh);
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const TrainingPage(),
              ),
            );
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
      ])),
    );
  }
}
