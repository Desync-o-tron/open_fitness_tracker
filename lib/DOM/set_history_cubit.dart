import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';

//todo is this dumb? can't this all be Setsofanex??
// @JsonSerializable()
// class ExHist extends SetsOfAnExercise {
//   ExHist(super.ex) : bestSet = Set(ex);
//   Set bestSet;
// }

// class SetsHistoryCubit extends Cubit<List<ExHist>> {
class SetsHistoryCubit extends Cubit<List<SetsOfAnExercise>> {
  SetsHistoryCubit() : super([]);

  void add(List<SetsOfAnExercise> soe) {
    var newState = state.toList();

    for (var setsOfAnExercise in soe) {
      // var exHist = ExHist(setsOfAnExercise.ex)..sets = setsOfAnExercise.;
      // var exHist = setsOfAnExercise as ExHist; //does this work?

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
            // throw Exception("did u forge a metric?"); //todo weirdness in strong.csv
          }
        });
      }

      newState.add(setsOfAnExercise);
      // newState.add(exHist);
    }

    emit(newState);
  }

  void clear() {
    emit([]);
  }
}
