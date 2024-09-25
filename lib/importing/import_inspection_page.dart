import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:fuzzywuzzy/model/extracted_result.dart';
import 'package:open_fitness_tracker/DOM/exercise_db.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/exercises/ex_tile.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

class ImportInspectionPage extends StatefulWidget {
  const ImportInspectionPage({super.key, required this.newTrainingSessions});
  final List<TrainingSession> newTrainingSessions;

  @override
  State<ImportInspectionPage> createState() => _ImportInspectionPageState();
}

class _ImportInspectionPageState extends State<ImportInspectionPage> {
  List<Exercise> idealMatchExs = [];
  List<Exercise> similarMatchExs = [];

  @override
  void initState() {
    super.initState();
    List<Exercise> newExs = [];
    List<String> newExNames = [];

    for (var sesh in widget.newTrainingSessions) {
      for (SetsOfAnExercise setsOfAnExercise in sesh.trainingData) {
        Exercise ex = setsOfAnExercise.ex;
        if (!newExNames.contains(ex.name)) {
          newExs.add(ex);
          newExNames.add(ex.name);
        }
      }
    }

    idealMatchExs = _exerciseMatcher(newExs, 100);
    List<Exercise> newExsSansMatches =
        newExs.where((ex) => !idealMatchExs.contains(ex)).toList();
    similarMatchExs = _exerciseMatcher(newExsSansMatches, 90);
  }

  @override
  Widget build(BuildContext context) {
    /*first iteration ideas:
    show the number of training sessions & then a list of
    all the new exercises you're about to import.

    impl:
    for exercises,
      if the name matches exactly.. then no problem, just add the history in.
      else
        get the muscles and the name
        do fuzzy search to find similar names
        if there is any decent overlap in muscles and name similarity w/ other ex,
          map this ex to the existing one & assign this name in the new ex's alternateNames.
        OR
          ask ML to do the whole search
        else, it's a new ex.. no problem.

    */
    return Scaffold(
      appBar: AppBar(
        title: Text("Imported ${widget.newTrainingSessions.length} sessions."),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 5),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PerfectMatchExercises(exercises: idealMatchExs),
                MatchExercises(exercises: similarMatchExs),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Exercise> _exerciseMatcher(List<Exercise> foreignExercises, int similarityCutoff) {
    List<Exercise> similarExercises = [];
    List<String> nameMatches = [];

    for (var ex in foreignExercises) {
      List<String> exNames = ExDB.names;
      List<ExtractedResult<String>> res = extractTop(
          query: ex.name, choices: exNames, cutoff: similarityCutoff, limit: 1);

      if (res.isNotEmpty) {
        nameMatches.addIfDNE(res.first.choice);
      }
    }

    for (var exName in nameMatches) {
      for (var ex in ExDB.exercises) {
        if (exName == ex.name) {
          similarExercises.add(ex);
        }
      }
    }

    return similarExercises;
  }
}

class MatchExercises extends StatelessWidget {
  final List<Exercise> exercises;

  const MatchExercises({super.key, required this.exercises});

  @override
  Widget build(BuildContext context) {
    if (exercises.isEmpty) return Container();
    return Column(
      children: [
        const Text(
          textAlign: TextAlign.center,
          "confirm these matches:",
          style: TextStyle(
            fontSize: 20, // Adjust this value for your desired "medium" size
            fontWeight: FontWeight.w600, // Makes the text semi-bold
            color: Colors.black87, // Optional: adjust the color as needed
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Container(
              decoration: BoxDecoration(border: Border.all()),
              height: 400,
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  return ExerciseTile(exercise: exercises[index]);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class PerfectMatchExercises extends StatelessWidget {
  final List<Exercise> exercises;

  const PerfectMatchExercises({super.key, required this.exercises});

  @override
  Widget build(BuildContext context) {
    if (exercises.isEmpty) return Container();
    return Column(
      children: [
        const Text(
          textAlign: TextAlign.center,
          "perfect match exercises:",
          style: TextStyle(
            fontSize: 20, // Adjust this value for your desired "medium" size
            fontWeight: FontWeight.w600, // Makes the text semi-bold
            color: Colors.black87, // Optional: adjust the color as needed
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Container(
              decoration: BoxDecoration(border: Border.all()),
              height: 200,
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  return ExerciseTile(exercise: exercises[index]);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
