import 'package:flutter/material.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/main.dart';
// import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:fuzzy/fuzzy.dart';

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  List<Exercise> filteredExercises = gs.exercises;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Exercises',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredExercises.length,
              itemBuilder: (context, index) {
                return ExerciseTile(exercise: filteredExercises[index]);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              onChanged: (String value) => _runFuzzySearch(value),
              decoration: const InputDecoration(
                icon: Icon(Icons.search),
                hintText: 'Search',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _runFuzzySearch(String enteredKeyword) {
    if (enteredKeyword.isEmpty) {
      setState(() {
        filteredExercises = gs.exercises;
      });
    } else {
      var fuse = Fuzzy(gs.getExerciseNames,
          options: FuzzyOptions(
            findAllMatches: true,
            threshold: 0.4,
          ));
      var results = fuse.search(enteredKeyword);
      print(results);

      // var eResult = extractAllSorted(
      //   // query: 'goolge',
      //   query: enteredKeyword,
      //   choices: ['google', 'bing', 'facebook', 'linkedin', 'twitter', 'googleplus', 'bingnews', 'plexoogl'],
      //   cutoff: 10,
      // ); // [(string google, score: 83, index: 0), (string googleplus, score: 75, index: 5), (string plexoogl, score: 43, index: 7), (string bingnews, score: 29, index: 6), (string linkedin, score: 29, index: 3), (string facebook, score: 29, index: 2), (string bing, score: 23, index: 1), (string twitter, score: 15, index: 4)]
      // print(eResult);
      var matchedNames = results.map((r) => r.item as String).toSet();
      setState(() {
        filteredExercises = filteredExercises.where((e) => matchedNames.contains(e.name)).toList();
      });
      // setState(() {
      //   filteredExercises = results.map((r) => r.item as String).cast<Exercise>().toList();
      // });
    }
  }
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
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';

// class ExercisesPage extends StatelessWidget {
//   ExercisesPage({super.key});

//   String searchQuery = '';

//   void updateSearchQuery(String newQuery) {
//     // setState(() {
//     //   searchQuery = newQuery.toLowerCase();
//     // });
//   }

//   // @override
//   // Widget build(BuildContext context) {
//   //   return Center(
//   //     child: Column(
//   //       mainAxisAlignment: MainAxisAlignment.center,
//   //       children: [
//   //         Text(
//   //           'Exercises',
//   //           style: Theme.of(context).textTheme.displayLarge,
//   //           // TextStyle(
//   //           //   fontSize: 32,
//   //           //   fontWeight: FontWeight.bold,
//   //           //   color: Colors.black,
//   //           // ),
//   //         ),
//   //         Expanded(
//   //           child: ListView.builder(
//   //             itemCount: exercises.length,
//   //             itemBuilder: (context, index) {
//   //               return ExerciseTile(exercise: exercises[index]);
//   //             },
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             'Exercises',
//             style: Theme.of(context).textTheme.displayLarge,
//             // TextStyle(
//             //   fontSize: 32,
//             //   fontWeight: FontWeight.bold,
//             //   color: Colors.black,
//             // ),
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _firestore.collection('exercisesStringy').snapshots(),
//               builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//                 if (snapshot.hasError) {
//                   return Text('Error: ${snapshot.error}');
//                 }

//                 switch (snapshot.connectionState) {
//                   case ConnectionState.waiting:
//                     return Center(child: CircularProgressIndicator());
//                   default:
//                     return ListView(
//                       children: snapshot.data!.docs.map((DocumentSnapshot document) {
//                         Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
//                         return ListTile(
//                           title: Text(data['name']), // Assuming your collection has a 'name' field
//                           // subtitle: Text(data['description']), // And a 'description' field
//                         );
//                       }).toList(),
//                     );
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ExerciseTile extends StatelessWidget {
//   final Exercise exercise;

//   const ExerciseTile({
//     super.key,
//     required this.exercise,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Text(exercise.name),
//       subtitle: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Level: ${exercise.level}'),
//           Text('Equipment: ${exercise.equipment ?? 'None'}'),
//           Text('Primary Muscles: ${exercise.primaryMuscles.join(', ')}'),
//           // Include other details as needed...
//         ],
//       ),
//       trailing: const Icon(Icons.fitness_center),
//       onTap: () {
//         // Handle tile tap if necessary
//       },
//     );
//   }
// }
