import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:fuzzywuzzy/model/extracted_result.dart';
import 'package:open_fitness_tracker/DOM/exercise_db.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';
import 'package:open_fitness_tracker/exercises/ex_tile.dart';

class ImportInspectionPage extends StatefulWidget {
  const ImportInspectionPage({super.key, required this.newTrainingSessions});
  final List<TrainingSession> newTrainingSessions;

  @override
  State<ImportInspectionPage> createState() => _ImportInspectionPageState();
}

class _ImportInspectionPageState extends State<ImportInspectionPage> {
  List<ExerciseMatch> similarMatchExs = [];

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

    similarMatchExs = _exerciseMatcher(newExs, 90);
  }

  @override
  Widget build(BuildContext context) {
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
                MatchExercises(exerciseMatches: similarMatchExs),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<ExerciseMatch> _exerciseMatcher(
      List<Exercise> foreignExercises, int similarityCutoff) {
    List<ExerciseMatch> exerciseMatches = [];

    for (var ex in foreignExercises) {
      List<String> exNames = ExDB.names;
      List<ExtractedResult<String>> res = extractTop(
          query: ex.name, choices: exNames, cutoff: similarityCutoff, limit: 1);

      if (res.isNotEmpty) {
        String matchedExName = res.first.choice;
        Exercise? matchedEx;
        for (var existingEx in ExDB.exercises) {
          if (existingEx.name == matchedExName) {
            matchedEx = existingEx;
            break;
          }
        }
        if (matchedEx != null) {
          bool defaultAdd = false;
          if (res.first.score == 100) defaultAdd = true;
          exerciseMatches.add(ExerciseMatch(
            foreignExercise: ex,
            matchedExercise: matchedEx,
            isConfirmed: defaultAdd,
          ));
        }
      }
    }

    return exerciseMatches;
  }
}

// Class to hold foreign and matched exercises along with confirmation status
class ExerciseMatch {
  final Exercise foreignExercise;
  final Exercise matchedExercise;
  bool isConfirmed;

  ExerciseMatch({
    required this.foreignExercise,
    required this.matchedExercise,
    this.isConfirmed = false,
  });
}

class MatchExercises extends StatefulWidget {
  final List<ExerciseMatch> exerciseMatches;

  const MatchExercises({super.key, required this.exerciseMatches});

  @override
  // ignore: library_private_types_in_public_api
  _MatchExercisesState createState() => _MatchExercisesState();
}

class _MatchExercisesState extends State<MatchExercises> {
  @override
  Widget build(BuildContext context) {
    if (widget.exerciseMatches.isEmpty) return Container();

    return Column(
      children: [
        const Text(
          textAlign: TextAlign.center,
          "First, confirm these similar exercise matches with our database:",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(border: Border.all()),
          height: 400,
          child: ListView.builder(
            itemCount: widget.exerciseMatches.length,
            itemBuilder: (context, index) {
              return _buildExerciseMatchBox(index);
            },
          ),
        ),
        const SizedBox(height: 10),
        MyGenericButton(
          onPressed: _confirmSelections,
          label: "Confirm Selections",
        ),
      ],
    );
  }

  Widget _buildExerciseMatchBox(int index) {
    ExerciseMatch exerciseMatch = widget.exerciseMatches[index];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                ExerciseTile(exercise: exerciseMatch.foreignExercise),
                const SizedBox(height: 8.0),
                ExerciseTile(exercise: exerciseMatch.matchedExercise),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Accept?'),
                Switch(
                  value: exerciseMatch.isConfirmed,
                  activeColor: Colors.red,
                  onChanged: (bool value) {
                    setState(() {
                      exerciseMatch.isConfirmed = value;
                    });
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSelections() {
    // Process the confirmed selections
    List<ExerciseMatch> confirmedMatches =
        widget.exerciseMatches.where((match) => match.isConfirmed).toList();
    // Implement your logic here
    print('Confirmed matches: ${confirmedMatches.length}');
  }
}
