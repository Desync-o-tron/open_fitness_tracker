import 'package:cloud_firestore/cloud_firestore.dart';
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

  String searchQuery = '';

  void updateSearchQuery(String newQuery) {
    // setState(() {
    //   searchQuery = newQuery.toLowerCase();
    // });
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Text(
  //           'Exercises',
  //           style: Theme.of(context).textTheme.displayLarge,
  //           // TextStyle(
  //           //   fontSize: 32,
  //           //   fontWeight: FontWeight.bold,
  //           //   color: Colors.black,
  //           // ),
  //         ),
  //         Expanded(
  //           child: ListView.builder(
  //             itemCount: exercises.length,
  //             itemBuilder: (context, index) {
  //               return ExerciseTile(exercise: exercises[index]);
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('exercisesStringy').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    return ListView(
                      children: snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                        return ListTile(
                          title: Text(data['name']), // Assuming your collection has a 'name' field
                          // subtitle: Text(data['description']), // And a 'description' field
                        );
                      }).toList(),
                    );
                }
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
