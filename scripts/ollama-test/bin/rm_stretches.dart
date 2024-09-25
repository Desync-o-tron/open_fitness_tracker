// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

void main() async {
  // Read the original JSON file
  final file = File(
      '/Users/lukeknoble/depot/open_fitness_tracker/scripts/ollama-test/exercises_with_more_muscles_qwen2.5:32b.json');
  final jsonString = await file.readAsString();
  final List<dynamic> exercises = json.decode(jsonString);

  // Filter out exercises with category "stretching"
  final filteredExercises = exercises.where((exercise) {
    return exercise['category'] != 'stretching';
  }).toList();

  // Create a new JSON file with filtered exercises
  final newFile = File(
      '/Users/lukeknoble/depot/open_fitness_tracker/scripts/ollama-test/exercises_with_more_muscles_no_stretches__qwen2.5:32b.json');
  await newFile.writeAsString(json.encode(filteredExercises));

  print('New JSON file created: filtered_exercises.json');
}
