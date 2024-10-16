import 'dart:async';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/cloud_io/firestore_sync.dart';

class SetsHistoryCubit extends Cubit<List<SetsOfAnExercise>> {
  final TrainingHistoryCubit trainingHistoryCubit;
  late StreamSubscription<TrainingHistoryState> trainingHistoryCubitSubscription;

  SetsHistoryCubit(this.trainingHistoryCubit) : super([]) {
    trainingHistoryCubitSubscription = trainingHistoryCubit.stream.listen(
      (TrainingHistoryState event) {
        clear();
        if (event is TrainingHistoryLoaded) {
          add(setHistoryFromTrainingHistory(event.sessions));
        }
      },
    );
  }

  void add(List<SetsOfAnExercise> soe) {
    var newState = state.toList();

    for (var setsOfAnExercise in soe) {
      // Find the best set based on the highest weight lifted or something
      if (setsOfAnExercise.sets.isNotEmpty) {
        // exHist.bestSet = setsOfAnExercise.sets.reduce((Set current, Set next) {
        setsOfAnExercise.bestSet = setsOfAnExercise.sets.reduce((Set current, Set next) {
          //todo this is a bit crude. powerlifters would probably like this, but if I do a 1rm, I'm not sure I want it as my top set.
          //I care more about 5reps+
          //also, distance & speed? hmm.. time?? needs some thought.
          if (current.weight != null) {
            return (current.weight! > next.weight!) ? current : next;
          } else if (current.distance != null && next.distance != null) {
            return (current.distance! > next.distance!) ? current : next;
          } else if (current.speed != null && next.speed != null) {
            return (current.speed! > next.speed!) ? current : next;
          } else {
            return current;
          }
        });
      }

      newState.add(setsOfAnExercise);
    }

    emit(newState);
  }

  void clear() {
    emit([]);
  }
}

List<SetsOfAnExercise> setHistoryFromTrainingHistory(List<TrainingSession> sessions) {
  List<SetsOfAnExercise> exercisesHist = [];
  for (var sesh in sessions) {
    for (SetsOfAnExercise setsOfAnExercise in sesh.trainingData) {
      SetsOfAnExercise anExHist = exercisesHist.firstWhere(
        (hist) => hist.ex.name == setsOfAnExercise.ex.name,
        orElse: () => SetsOfAnExercise(setsOfAnExercise.ex), //make empty one
      );
      if (anExHist.sets.isEmpty) {
        exercisesHist.add(anExHist);
      }
      anExHist.sets.addAll(setsOfAnExercise.sets);
      exercisesHist.add(anExHist);
    }
  }
  return exercisesHist;
}
