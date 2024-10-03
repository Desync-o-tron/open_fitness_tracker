import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:fuzzywuzzy/model/extracted_result.dart';
import 'package:go_router/go_router.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/cloud_io/firestore_sync.dart';
import 'package:open_fitness_tracker/importing/ex_match_listview.dart';
import 'package:open_fitness_tracker/navigation/routes.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

class ImportInspectionPage extends StatefulWidget {
  const ImportInspectionPage({super.key, required this.newTrainingSessions});
  final List<TrainingSession> newTrainingSessions;

  @override
  State<ImportInspectionPage> createState() => _ImportInspectionPageState();
}

class _ImportInspectionPageState extends State<ImportInspectionPage> {
  List<ExerciseMatchCard> matchPairs = [];
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
  }

  @override
  Widget build(BuildContext context) {
    var exercisesState = context.read<ExercisesCubit>().state;
    if (exercisesState is ExercisesLoading || exercisesState is ExercisesInitial) {
      return const Center(child: CircularProgressIndicator());
    } else if (exercisesState is ExercisesError) {
      return Center(child: Text('Error loading exercises: ${exercisesState.message}'));
    } else {
      exercisesState = exercisesState as ExercisesLoaded;
    }

    if (matchPairs.isEmpty) {
      matchPairs = _exerciseMatcher(newExs, exercisesState, 92);
      //this does not need to run twice+ if the user somehow refreshes..idk maybe just a dev problemo
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Imported ${widget.newTrainingSessions.length} sessions &\n ${newExs.length} different exercises"),
      ),
      body: MatchExercisesScrollView(
        exerciseMatches: matchPairs,
        allImportedExercises: newExs,
        confirmSelections: () => _confirmSelections(context.read<ExercisesCubit>()),
      ),
    );
  }

  List<ExerciseMatchCard> _exerciseMatcher(
      Exercises foreignExercises, ExercisesLoaded localExercises, int similarityCutoff) {
    List<ExerciseMatchCard> exerciseMatches = [];

    for (var ex in foreignExercises) {
      List<String> exNames = localExercises.names;
      List<ExtractedResult<String>> res = extractTop(
          query: ex.name, choices: exNames, cutoff: similarityCutoff, limit: 1);

      if (res.isNotEmpty) {
        String matchedExName = res.first.choice;
        Exercise? matchedEx;
        for (var existingEx in localExercises.exercises) {
          if (existingEx.name == matchedExName) {
            matchedEx = existingEx;
            break;
          }
        }
        if (matchedEx != null) {
          bool defaultAdd = false;
          if (res.first.score == 100) defaultAdd = true;
          exerciseMatches.add(ExerciseMatchCard(
            foreignExercise: ex,
            matchedExercise: matchedEx,
            isConfirmed: defaultAdd,
            preferForeignExerciseName: defaultAdd,
          ));
        }
      } else {
        exerciseMatches.add(ExerciseMatchCard(
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

  void _confirmSelections(ExercisesCubit exercisesCubit) async {
    Strings exNamestoRm = [];

    bool firstTimeNoMatch = true;
    for (var match in matchPairs) {
      if (match.bDiscard) {
        exNamestoRm.add(match.foreignExercise.name);
        continue;
      }
      if (match.matchedExercise == null) {
        if (firstTimeNoMatch) {
          firstTimeNoMatch = false;
          bool? result = await _confirmCreatingNewExercisesDialog(context);
          if (result == null || !result) {
            return;
          }
        }
        //otherwise lets put em in the DB!
        exercisesCubit.addExercises([match.foreignExercise]);
        continue;
      }

      //otherwise we're mapping the foreign ex to our ex.
      final exercisesState = (exercisesCubit.state as ExercisesLoaded);
      Exercise exToUpdate = exercisesState.exercises.firstWhere(
          (e) => e.name == match.matchedExercise!.name,
          orElse: () => match.matchedExercise!);

      // ignore: prefer_conditional_assignment
      if (exToUpdate.alternateNames == null) {
        exToUpdate.alternateNames = [];
      }

      if (match.preferForeignExerciseName) {
        exToUpdate.alternateNames!.addIfDNE(exToUpdate.name);
        exToUpdate.name = match.foreignExercise.name;
      } else {
        exToUpdate.alternateNames!.addIfDNE(match.foreignExercise.name);
      }

      exercisesCubit.addExercises([exToUpdate]);
    }
    var cleanedTrainingSessions =
        _removeUnwantedExercisesFromIncomingTrainingData(exNamestoRm);

    final histCubit = context.read<TrainingHistoryCubit>();
    for (var session in cleanedTrainingSessions) {
      histCubit.addTrainingSessionToHistory(session);
    }
    histCubit.loadUserTrainingHistory(useCache: true);

    if (mounted) {
      //i think this should be fine, what's a dialog going to do?
      context.push(routeNames.History.text);
    } else {
      //todo error handling?
      throw Exception("todo help me..import still worked, just go back");
    }
  }

  Future<bool?> _confirmCreatingNewExercisesDialog(
    BuildContext context,
  ) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("beep boop"),
          content: const Text(
            "Create new exercises from any unnassigned exercises?",
            textAlign: TextAlign.center,
            textScaler: TextScaler.linear(1.25),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  List<TrainingSession> _removeUnwantedExercisesFromIncomingTrainingData(
      Strings unwantedExercisesNames) {
    List<TrainingSession> cleanedTrainingSessions = [];
    for (var sesh in widget.newTrainingSessions) {
      List<SetsOfAnExercise> cleanedSetsOfEx = [];
      for (var setsOfAnEx in sesh.trainingData) {
        bool shouldAdd = true;
        for (var exName in unwantedExercisesNames) {
          if (setsOfAnEx.ex.name == exName) {
            shouldAdd = false;
          }
        }
        if (shouldAdd) {
          cleanedSetsOfEx.add(setsOfAnEx);
        }
      }
      if (cleanedSetsOfEx.isEmpty) continue;
      // if we rm all the crap in a training session, lets just rm the session too.
      cleanedTrainingSessions
          .add(TrainingSession.copy(sesh)..trainingData = cleanedSetsOfEx);
    }
    return cleanedTrainingSessions;
  }
}
