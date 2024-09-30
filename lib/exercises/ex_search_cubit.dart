import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:open_fitness_tracker/cloud_io/firestore_sync.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

class ExSearchState {
  final List<Exercise> allExercises;
  final List<String> allNames;
  final List<String> allMuscles;
  final List<Exercise> filteredExercises;
  final List<String> categoriesFilter;
  final List<String> musclesFilter;
  final String enteredKeyword;

  ExSearchState({
    required this.allExercises,
    required this.allNames,
    required this.allMuscles,
    this.filteredExercises = const [],
    this.categoriesFilter = const [],
    this.musclesFilter = const [],
    this.enteredKeyword = '',
  });

  ExSearchState copyWith({
    List<Exercise>? filteredExercises,
    List<String>? categoriesFilter,
    List<String>? musclesFilter,
    String? enteredKeyword,
  }) {
    return ExSearchState(
      allExercises: allExercises,
      allNames: allNames,
      allMuscles: allMuscles,
      filteredExercises: filteredExercises ?? this.filteredExercises,
      categoriesFilter: categoriesFilter ?? this.categoriesFilter,
      musclesFilter: musclesFilter ?? this.musclesFilter,
      enteredKeyword: enteredKeyword ?? this.enteredKeyword,
    );
  }
}

class ExSearchCubit extends Cubit<ExSearchState> {
  final ExercisesCubit exercisesCubit;
  late final StreamSubscription exercisesSubscription;

  ExSearchCubit({required this.exercisesCubit})
      : super(ExSearchState(
          allExercises: [],
          allNames: [],
          allMuscles: [],
        )) {
    exercisesSubscription = exercisesCubit.stream.listen((exercisesState) {
      if (exercisesState is ExercisesLoaded) {
        _initialize(exercisesState);
      }
    });
    if (exercisesCubit.state is ExercisesLoaded) {
      _initialize(exercisesCubit.state as ExercisesLoaded);
    }
  }

  void _initialize(ExercisesLoaded exercisesState) {
    final allExercises = exercisesState.exercises;
    final allNames = exercisesState.names;
    final allMuscles = exercisesState.muscles;

    emit(ExSearchState(
      allExercises: allExercises,
      allNames: allNames,
      allMuscles: allMuscles,
      filteredExercises: allExercises,
    ));
  }

  void updateFilters({
    List<String>? categories,
    List<String>? muscles,
    String? keyword,
  }) {
    final newState = state.copyWith(
      categoriesFilter: categories ?? state.categoriesFilter,
      musclesFilter: muscles ?? state.musclesFilter,
      enteredKeyword: keyword ?? state.enteredKeyword,
    );

    // Apply filters
    List<Exercise> filteredExercises = newState.allExercises;

    // Filter by muscles
    if (newState.musclesFilter.isNotEmpty) {
      filteredExercises = filteredExercises.where((exercise) {
        return exercise.primaryMuscles.any(newState.musclesFilter.contains) ||
            (exercise.secondaryMuscles != null &&
                exercise.secondaryMuscles!.any(newState.musclesFilter.contains));
      }).toList();
    }

    // Filter by categories
    if (newState.categoriesFilter.isNotEmpty) {
      filteredExercises = filteredExercises.where((exercise) {
        return newState.categoriesFilter.contains(exercise.category);
      }).toList();
    }

    // Filter by keyword
    if (newState.enteredKeyword.isNotEmpty) {
      var fuseForNames = Fuzzy(
        newState.allNames,
        options: FuzzyOptions(findAllMatches: true, threshold: 0.25),
      );
      var resultsByName = fuseForNames.search(newState.enteredKeyword);
      var matchedNames = resultsByName.map((r) => r.item).toSet();

      var fuseForMuscles = Fuzzy(
        newState.allMuscles,
        options: FuzzyOptions(findAllMatches: true, threshold: 0.25),
      );
      var resultsByMuscles = fuseForMuscles.search(newState.enteredKeyword);
      var matchedMuscles = resultsByMuscles.map((r) => r.item).toSet();

      filteredExercises = filteredExercises.where((exercise) {
        bool matchesName = matchedNames.contains(exercise.name);
        bool matchesMuscle = exercise.primaryMuscles.any(matchedMuscles.contains) ||
            (exercise.secondaryMuscles != null &&
                exercise.secondaryMuscles!.any(matchedMuscles.contains));
        return matchesName || matchesMuscle;
      }).toList();
    }

    emit(newState.copyWith(filteredExercises: filteredExercises));
  }

  @override
  Future<void> close() {
    exercisesSubscription.cancel();
    return super.close();
  }
}
