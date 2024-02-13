// ignore: camel_case_types
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

// ignore: camel_case_types
class gExs {
  static get exercises => _exercises;
  static get categories => _categories;
  static get muscles => _muscles;
  static get names => _names;
  static addExercises(List<Exercise> exercises) {
    for (var exercise in exercises) {
      _exercises.addIfDNE(exercise);
      _names.addIfDNE(exercise.name);
      _categories.addIfDNE(exercise.category);
      _muscles.addAllIfDNE(exercise.primaryMuscles);
      // _muscles.addAllIfDNE(exercise.secondaryMuscles); //todo?
    }
  }

  static final List<String> _names = [];
  static final List<String> _categories = [];
  static final List<String> _muscles = [];
  static final List<Exercise> _exercises = [];
}

Future<void> loadExerciseData() async {
  String jsonString = await rootBundle.loadString('assets/data/exercises.json');
  gExs.addExercises((json.decode(jsonString) as List).map((e) => Exercise.fromJson(e)).toList());
}
