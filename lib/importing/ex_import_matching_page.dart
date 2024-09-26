import 'package:flutter/material.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:fuzzywuzzy/model/extracted_result.dart';
import 'package:go_router/go_router.dart';
import 'package:open_fitness_tracker/DOM/exercise_db.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/importing/ex_match_listview.dart';
import 'package:open_fitness_tracker/navigation/routes.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

//TODO make a delete button on the exercisematch

class ImportInspectionPage extends StatefulWidget {
  const ImportInspectionPage({super.key, required this.newTrainingSessions});
  final List<TrainingSession> newTrainingSessions;

  @override
  State<ImportInspectionPage> createState() => _ImportInspectionPageState();
}

class _ImportInspectionPageState extends State<ImportInspectionPage> {
  List<ExerciseMatch> matchPairs = [];
  Exercises newExs = [];

  @override
  void initState() {
    super.initState();
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
    matchPairs = _exerciseMatcher(newExs, 90);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Imported ${widget.newTrainingSessions.length} sessions &\n ${newExs.length} different exercises"),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 5),
        child: MatchExercisesScrollView(
            exerciseMatches: matchPairs,
            allImportedExercises: newExs,
            confirmSelections: _confirmSelections),
      ),
    );
  }

  List<ExerciseMatch> _exerciseMatcher(Exercises foreignExercises, int similarityCutoff) {
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
            preferForeignExerciseName: defaultAdd,
          ));
        }
      } else {
        exerciseMatches.add(ExerciseMatch(
            foreignExercise: ex, matchedExercise: null, isConfirmed: false));
      }
    }
    exerciseMatches.sort((a, b) {
      //todo would be cute if we prioritized exerises with more history.
      int score = 0;
      if (a.matchedExercise == null) {
        score += 2;
      }
      if (b.matchedExercise == null) {
        score -= 2;
      }
      if (a.isConfirmed) score--;
      if (b.isConfirmed) score++;
      return score;
    });

    return exerciseMatches;
  }

  void _confirmSelections() {
    List<ExerciseMatch> confirmedMatches =
        matchPairs.where((match) => match.isConfirmed).toList();

    for (var match in confirmedMatches) {
      var matchedEx = match.matchedExercise;
      if (matchedEx != null) {
        Exercise exToUpdate = ExDB.exercises
            .firstWhere((e) => e.name == matchedEx.name, orElse: () => matchedEx);

        exToUpdate.alternateNames ??= [];

        if (match.preferForeignExerciseName) {
          exToUpdate.alternateNames!.addIfDNE(exToUpdate.name);
          exToUpdate.name = match.foreignExercise.name;
        } else {
          exToUpdate.alternateNames!.addIfDNE(match.foreignExercise.name);
        }

        ExDB.addExercises([exToUpdate]);
      }
    }

    List<Exercise> unmatchedExercises = [];

    for (var importedEx in newExs) {
      bool found = false;
      for (var match in confirmedMatches) {
        if (match.foreignExercise.name == importedEx.name) {
          found = true;
          break;
        }
      }
      if (!found) {
        unmatchedExercises.add(importedEx);
      }
    }

    context.push(routeNames.History.text);
  }
}
