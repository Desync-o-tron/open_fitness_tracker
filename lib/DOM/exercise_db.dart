// ignore: camel_case_types
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
      if (exercise.secondaryMuscles != null) _muscles.addAllIfDNE(exercise.secondaryMuscles!);
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
    if (_prefs.containsKey('exercises')) {
      addExercises(
          (json.decode(_prefs.getString('exercises')!) as List).map((e) => Exercise.fromJson(e)).toList());
    } else {
      String jsonString = await rootBundle.loadString('assets/data/exercises.json');
      addExercises((json.decode(jsonString) as List).map((e) => Exercise.fromJson(e)).toList());
    }
  }

  static Future<void> _saveExercises() async {
    await _prefs.setString('exercises', json.encode(exercises));
  }
}


/*
class Storage {
  static late final SharedPreferences _prefs;
  static bool autoSave = false;
  static const String activeTrainingSessionKey = 'activeTrainingSession';

  //todo add error handling to all this
  static init() async {
    _prefs = await SharedPreferences.getInstance();
    populateExerciseData();
  }

  static Future<void> saveExercises() async {
    await _prefs.setString('exercises', json.encode(gExs.exercises));
  }

  static Future<void> populateExerciseData() async {
    if (_prefs.containsKey('exercises')) {
      gExs.addExercises(
          (json.decode(_prefs.getString('exercises')!) as List).map((e) => Exercise.fromJson(e)).toList());
    } else {
      String jsonString = await rootBundle.loadString('assets/data/exercises.json');
      gExs.addExercises((json.decode(jsonString) as List).map((e) => Exercise.fromJson(e)).toList());
    }
  }

  static Future<TrainingSession?> loadActiveTrainingSession() async {
    if (_prefs.containsKey(activeTrainingSessionKey)) {
      TrainingSession sesh =
          TrainingSession.fromJson(json.decode(_prefs.getString(activeTrainingSessionKey)!));
      if (sesh.isOngoing) {
        return sesh;
      }
    }
    return null;
  }

  static Future<void> startAutoSavingActiveTrainingSession(TrainingSession sesh) async {
    autoSave = true;
    while (autoSave) {
      _saveActiveTrainingSession(sesh);
      await Future.delayed(const Duration(seconds: 1)); //todo can we profile this? can we do 100ms?
    }
  }

  static Future<void> _saveActiveTrainingSession(TrainingSession sesh) async {
    await _prefs.setString(activeTrainingSessionKey, json.encode(sesh)); //todo add error handling
  }

  static void loadCurrentTrainingSesh(
    BuildContext context,
    TrainingSessionCubit trainingSessionCubit,
  ) async {
    TrainingSession? sesh = await loadActiveTrainingSession();
    if (sesh != null) {
      trainingSessionCubit.state.copyFrom(sesh);
    }
  }
}
*/