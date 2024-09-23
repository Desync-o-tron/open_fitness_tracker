import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExDB {
  static get exercises => _exercises;
  static get categories => _categories;
  static get muscles => _muscles;
  static get names => _names;
  static get equipment => _equipment;

  static final List<String> _names = [];
  static final List<String> _categories = [];
  static final List<String> _muscles = [];
  static final List<String> _equipment = [];
  static final List<Exercise> _exercises = [];

  //todo can we make this async?
  static addExercises(List<Exercise> exercises) {
    for (var exercise in exercises) {
      _exercises.addIfDNE(exercise);
      _names.addIfDNE(exercise.name);
      _categories.addIfDNE(exercise.category);
      _equipment.addIfDNE(exercise.equipment);
      _muscles.addAllIfDNE(exercise.primaryMuscles);
      if (exercise.secondaryMuscles != null) {
        _muscles.addAllIfDNE(exercise.secondaryMuscles!);
      }
    }
    _saveExercises(); //this might be a bit slow idk.
  }

  //todo add error handling to all this
  static late final SharedPreferences _prefs;

  static init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadExercises();
  }

  static void _loadExercises() async {
    if (_prefs.containsKey('exercises_no_stretches')) {
      addExercises(
        (json.decode(_prefs.getString('exercises_no_stretches')!) as List)
            .map((e) => Exercise.fromJson(e))
            .toList(),
      );
    } else {
      String jsonString =
          await rootBundle.loadString('assets/data/exercises_no_stretches.json');
      addExercises(
          (json.decode(jsonString) as List).map((e) => Exercise.fromJson(e)).toList());
    }
  }

  static Future<void> _saveExercises() async {
    await _prefs.setString('exercises_no_stretches', json.encode(exercises));
  }
}
