import 'package:flutter/material.dart';

class ExercisesPage extends StatelessWidget {
  ExercisesPage({super.key});

  final List<Exercise> exercises = [
    Exercise(
      id: 'cable_crossover_01',
      name: 'Cable Crossover',
      force: 'static',
      level: 'intermediate',
      mechanic: 'compound',
      equipment: 'cable',
      primaryMuscles: ['chest'],
      secondaryMuscles: ['shoulders', 'triceps'],
      instructions: ['Stand between two pulleys...', 'Extend arms...'],
      category: 'strength',
      images: ['image1.jpg', 'image2.jpg'],
    ),
    // Add more exercises here...
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Exercises',
            style: Theme.of(context).textTheme.displayLarge,
            // TextStyle(
            //   fontSize: 32,
            //   fontWeight: FontWeight.bold,
            //   color: Colors.black,
            // ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                return ExerciseTile(exercise: exercises[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Exercise {
  String id;
  String name;
  String? force;
  String level;
  String? mechanic;
  String? equipment;
  List<String> primaryMuscles;
  List<String> secondaryMuscles;
  List<String> instructions;
  String category;
  List<String> images;

  Exercise({
    required this.id,
    required this.name,
    this.force,
    required this.level,
    this.mechanic,
    this.equipment,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.instructions,
    required this.category,
    required this.images,
  });
}

class ExerciseTile extends StatelessWidget {
  final Exercise exercise;

  const ExerciseTile({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(exercise.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Level: ${exercise.level}'),
          Text('Equipment: ${exercise.equipment ?? 'None'}'),
          Text('Primary Muscles: ${exercise.primaryMuscles.join(', ')}'),
          // Include other details as needed...
        ],
      ),
      trailing: const Icon(Icons.fitness_center),
      onTap: () {
        // Handle tile tap if necessary
      },
    );
  }
}
