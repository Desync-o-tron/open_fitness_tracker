import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:open_fitness_tracker/cloud_io/firestore_sync.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

class ExSearchState {
  List<Exercise> filteredExercises = cloudStorage.exDB.exercises;
  List<String> categoriesFilter = [];
  List<String> musclesFilter = [];
  String enteredKeyword = '';

  ExSearchState([ExSearchState? state]) {
    if (state != null) {
      filteredExercises = state.filteredExercises;
      categoriesFilter = state.categoriesFilter;
      musclesFilter = state.musclesFilter;
      enteredKeyword = state.enteredKeyword;
    }
  }

  /// Every time we're going to update we re-apply every filter. not the most efficient but it's fine for now
  ExSearchState copyWithNewFilters(
      {List<String>? categoriesFilter,
      List<String>? musclesFilter,
      String? enteredKeyword}) {
    ExSearchState newState = ExSearchState(this);
    newState.filteredExercises = cloudStorage.exDB.exercises;
    newState.categoriesFilter = categoriesFilter ?? newState.categoriesFilter;
    newState.musclesFilter = musclesFilter ?? newState.musclesFilter;
    newState.enteredKeyword = enteredKeyword ?? newState.enteredKeyword;

    // filter by muscles
    List<Exercise> tempExs = [];
    for (String muscle in newState.musclesFilter) {
      for (var e in newState.filteredExercises) {
        if (e.primaryMuscles.contains(muscle) ||
            (e.secondaryMuscles != null && e.secondaryMuscles!.contains(muscle))) {
          tempExs.add(e);
        }
      }
    }
    if (tempExs.isNotEmpty) {
      newState.filteredExercises = tempExs;
    }

    for (String category in newState.categoriesFilter) {
      newState.filteredExercises =
          newState.filteredExercises.where((e) => e.category == category).toList();
    }

    // filter by keyword
    if (newState.enteredKeyword.isNotEmpty) {
      var fuseForNames = Fuzzy(cloudStorage.exDB.names,
          options: FuzzyOptions(findAllMatches: true, threshold: 0.25));
      var resultsByName = fuseForNames.search(newState.enteredKeyword);
      var matchedNames = resultsByName.map((r) => r.item as String).toSet();
      var fuseForMuscles = Fuzzy(cloudStorage.exDB.muscles,
          options: FuzzyOptions(findAllMatches: true, threshold: 0.25));
      var resultsByMuscles = fuseForMuscles.search(newState.enteredKeyword);
      var matchedMuscles = resultsByMuscles.map((r) => r.item as String).toSet();
      tempExs = [];
      for (var e in newState.filteredExercises) {
        if (matchedNames.contains(e.name)) {
          tempExs.addIfDNE(e);
        }
        if (e.primaryMuscles.any((m) => matchedMuscles.contains(m))) {
          tempExs.addIfDNE(e);
        }
      }
      newState.filteredExercises = tempExs;
    }

    return newState;
  }
}

class ExSearchCubit extends Cubit<ExSearchState> {
  ExSearchCubit() : super(ExSearchState());

  void updateFilters({List<String>? categories, List<String>? muscles, String? keyword}) {
    emit(state.copyWithNewFilters(
      categoriesFilter: categories ?? state.categoriesFilter,
      musclesFilter: muscles ?? state.musclesFilter,
      enteredKeyword: keyword ?? state.enteredKeyword,
    ));
  }
}
