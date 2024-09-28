// ignore_for_file: prefer_adjacent_string_concatenation

import 'dart:convert';
import 'dart:io';
import 'package:ollama_dart/ollama_dart.dart';
//!!!
//todo run again with qwen..see if the shit is as good as ya had it the first time

void main(List<String> args) async {
  final file = File(
      '/Users/lukeknoble/depot/open_fitness_tracker/assets/data/exercises_no_stretches.json');
  final jsonString = await file.readAsString();
  final List<dynamic> exercises = json.decode(jsonString);
  // final modelName = "qwen2.5:32b"; //nicest so far?
  // final modelName = "gemma2:27b";
  final modelName = "llama3.1:latest";
  final newFile =
      File('./muscle_associator/exercises_with_more_muscles_${modelName}_v2.json');
  final infoFile = File('./muscle_associator/info_$modelName.txt');
  var newFileIOsync = newFile.openWrite();
  var infoIOsync = infoFile.openWrite();
  newFileIOsync.write("["); //making a list

  int numBadResponses = 0;
  for (int i = 0; i < exercises.length; i++) {
    var ex = exercises[i];
    var exName = ex["name"];
    print("processed: $i/${exercises.length}");

    try {
      var resp = await querySender(exName, modelName);

      List primaryMuscles = resp["primaryMuscles"];
      List secondaryMuscles = resp["secondaryMuscles"];
      for (var muscle in primaryMuscles) {
        if (!muscleList.contains(muscle)) {
          print("a New Muscle Appeared: \n $muscle");
          infoIOsync.writeln(muscle + "\n");
        }
      }
      for (var muscle in secondaryMuscles) {
        if (!muscleList.contains(muscle)) {
          print("a New Muscle Appeared: \n $muscle");
          infoIOsync.writeln(muscle + "\n");
        }
      }
      ex["primaryMuscles"] = primaryMuscles;
      ex["secondaryMuscles"] = secondaryMuscles;
    } catch (e) {
      infoIOsync.writeln("err: ");
      infoIOsync.writeln("$e\n");

      if (++numBadResponses > 4) {
        numBadResponses = 0;
        ex["todo"] = "too many bad responses.";
      } else if (i != 0) {
        //retry
        --i;
        continue;
      }
    }
    numBadResponses = 0;
    newFileIOsync.write(json.encode(ex));
    newFileIOsync.write(",");
  }
  newFileIOsync.write("]");
}

Future<Map<String, dynamic>> querySender(String exerciseName, String modelName) async {
  //todo look into lowering temp and raising context
  //(queryParams: Map<String, dynamic>?{"junk", 2000});
  OllamaClient client = OllamaClient();

  String systemPrompt = """
      Respond only with those muscles that you associate with the following exercises with the key of primaryMuscles or secondaryMuscles.
      Your response should only include muscles or muscle groups from the following list. 
      Some of the list entries are overlapping, eg "calf" and "soleus" but it is good to put both if they both fit.
      It is better to be unsure and list none than to hallucinate and put something you are not sure about. 
      If you are not sure, leave the primaryMuscles and secondaryMuscles fields empty.
      DO NOT add any extra text or fields.
      DO NOT add a label or markdown formatting, eg. ```json ...```
      an example response:
      {
      "inputExercise": "seated calf raise",
      "primaryMuscles": [
        "calf",
        "soleus",
      ],
      "secondaryMuscles": [
        "gastrocnemius",
      ], 
      }
      
      The List:
      ${muscleList.toString()}
      """;

  final generated = await client.generateCompletion(
    request: GenerateCompletionRequest(
      model: modelName,
      context: [4000],
      system: systemPrompt,
      prompt: exerciseName,
    ),
  );
  print(generated.response);
  try {
    return jsonDecode(generated.response!);
  } catch (e) {
    return Future.error({"todo: $exerciseName"});
  }
}

List muscleList = [
  "abdominals",
  "abductors",
  "adductors",
  "biceps",
  "calves",
  "chest",
  "forearms",
  "glutes",
  "hamstrings",
  "lats",
  "lower back",
  "middle back",
  "neck",
  "quadriceps",
  "shoulders",
  "traps",
  "triceps",
  "upper traps",
  "lower traps",
  "rhomboids",
  "neck extensors",
  "neck flexors",
  "rotator cuff muscles",
  "hip flexors",
  "iliopsoas",
  "tibialis",
  "gastrocnemius",
  "soleus",
  "serratus",
  "obliques"
];
