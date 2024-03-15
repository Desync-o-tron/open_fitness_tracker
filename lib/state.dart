// ignore: camel_case_types
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: camel_case_types
class gExs {
  static get exercises => _exercises;
  static get categories => _categories;
  static get muscles => _muscles;
  static get names => _names;
  static get equipment => _equipment;

  static addExercises(List<Exercise> exercises) {
    for (var exercise in exercises) {
      _exercises.addIfDNE(exercise);
      _names.addIfDNE(exercise.name);
      _categories.addIfDNE(exercise.category);
      _equipment.addIfDNE(exercise.equipment);
      _muscles.addAllIfDNE(exercise.primaryMuscles);
      if (exercise.secondaryMuscles != null) _muscles.addAllIfDNE(exercise.secondaryMuscles!);
    }
    Storage.saveExercises();
  }

  static final List<String> _names = [];
  static final List<String> _categories = [];
  static final List<String> _muscles = [];
  static final List<String> _equipment = [];
  static final List<Exercise> _exercises = [];
}

class Storage {
  static late final SharedPreferences _prefs;
  static bool autoSave = false;

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
    if (_prefs.containsKey('activeTrainingSession')) {
      TrainingSession sesh =
          TrainingSession.fromJson(json.decode(_prefs.getString('activeTrainingSession')!));
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
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  static Future<void> _saveActiveTrainingSession(TrainingSession sesh) async {
    await _prefs.setString('activeTrainingSession', json.encode(sesh)); //todo add error handling
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
