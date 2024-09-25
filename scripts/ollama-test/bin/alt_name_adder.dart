import 'dart:convert';
import 'dart:io';

import 'package:ollama_dart/ollama_dart.dart';

void main(List<String> args) async {
  final file =
      File('/Users/lukeknoble/depot/open_fitness_tracker/assets/data/exercises.json');
  final jsonString = await file.readAsString();
  final List<dynamic> exercises = json.decode(jsonString);

  // Filter out exercises with category "stretching"
  final filteredExercises = exercises.where((exercise) {
    return exercise['category'] != 'stretching';
  }).toList();

  // Create a new JSON file with filtered exercises
  final newFile = File(
      '/Users/lukeknoble/depot/open_fitness_tracker/assets/data/exercises_no_stretches.json');
  await newFile.writeAsString(json.encode(filteredExercises));
}

Future<Map<String, dynamic>> querySender(String exerciseName) async {
  //todo look into lowering temp and raising context
  OllamaClient client =
      OllamaClient(); //(queryParams: Map<String, dynamic>?{"junk", 2000});
  final generated = await client.generateCompletion(
    request: GenerateCompletionRequest(
      // model: 'qwen2.5:14b',
      model: 'qwen2.5:32b',
      // model: 'llama3.1:latest',
      context: [4000],
      system: """
      Respond only with those muscles that you associate with the following exercises with the key of primaryMuscles or secondaryMuscles.
      Your response should only include muscles or muscle groups from the following list. 
      Some of the list entries are overlapping, eg "calf" and "soleus" but it is good to put both if they both fit.
      It is better to be unsure and list none than to hallucinate and put something you are not sure about. 
      If you are not sure, leave the primaryMuscles and secondaryMuscles fields empty.
      
      an example response:
      {
      "inputExercise": "seated calf raise"
      "primaryMuscles": [
        "calf"
        "soleus"
      ],
      "secondaryMuscles": [
        "gastrocnemius",
      ], 
      }
      
      The List:
      [
      abdominals,
      abductors,
      adductors,
      biceps,
      calves,
      chest,
      forearms,
      glutes,
      hamstrings,
      lats,
      lowerBack,
      middleBack,
      neck,
      quadriceps,
      shoulders,
      traps,
      triceps,
      upperTraps,
      lowerTraps,
      rhomboids,
      romboids,
      neckExtensors,
      neckFlexors,
      rotatorCuffMuscles,
      hipFlexors,
      iliopsoas,
      tibialis,
      gastrocnemius,
      soleus,
      serratus,
      obliques
      ]
      """,
      prompt: exerciseName,
    ),
  );
  print(generated.response);
  return generated.toJson();
}
