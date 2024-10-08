import 'package:json_annotation/json_annotation.dart';
part 'exercise_metadata.g.dart';

/*
to generate new g.dart files run:
dart run build_runner build --delete-conflicting-outputs
to do it continuously run:
dart run build_runner watch --delete-conflicting-outputs
*/
@JsonSerializable()
class Exercise {
  String? id;
  //todo ^does id matter? is it another thing to track? there *should not* be name dupes.
  String name;
  List<String>? alternateNames = [];
  Force? force;
  Level? level;
  Mechanic? mechanic;
  String? equipment;
  String? notes; //maybe make a note history
  // List<String> noteHistory; //todo
  List<String>? setMetrics;
  //todo^ not in the json schema. (time, weight, distance, speed, reps)
  late List<String> primaryMuscles;
  List<String>? secondaryMuscles;
  List<String>? instructions;
  // powerlifting, strength, cardio, olympicWeightlifting, strongman, plyometrics,
  String? category;
  List<String>? images;

  Exercise({
    this.id,
    required this.name,
    this.force,
    this.level,
    this.mechanic,
    this.equipment,
    this.notes,
    this.setMetrics,
    List<String>? primaryMuscles,
    this.secondaryMuscles,
    this.instructions,
    this.category,
    this.images,
  }) {
    this.primaryMuscles = primaryMuscles ?? [];
    if (setMetrics == null) {
      if (category == "cardio") {
        setMetrics = ["time", "distance", "speed"];
      } else if (category == "stretching") {
        setMetrics = ["time"];
      } else if (category == "plyometrics") {
        setMetrics = ["reps", "weight", "speed"];
      } else {
        setMetrics = ["reps", "weight"];
      }
    }
  }

  factory Exercise.fromExercise(Exercise exercise) {
    return Exercise(
      id: exercise.id,
      name: exercise.name,
      force: exercise.force,
      level: exercise.level,
      mechanic: exercise.mechanic,
      equipment: exercise.equipment,
      notes: exercise.notes,
      setMetrics: exercise.setMetrics,
      primaryMuscles: exercise.primaryMuscles,
      secondaryMuscles: exercise.secondaryMuscles,
      instructions: exercise.instructions,
      category: exercise.category,
      images: exercise.images,
    );
  }

  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseToJson(this);
}

enum Force { static, pull, push }

enum Level { beginner, intermediate, expert }

enum Mechanic { isolation, compound }

// enum setMetrics { time, weight, distance, speed, reps }

// enum Equipment {
//   medicineBall,
//   dumbbell,
//   bodyOnly, //todo change the header in an ex for weight to additonalWeight
//   bands,
//   kettlebells,
//   foamRoll,
//   cable,
//   machine,
//   barbell,
//   exerciseBall,
//   ezCurlBar,
//   other
// }

// enum Muscle {
//   abdominals,
//   abductors,
//   adductors,
//   biceps,
//   calves,
//   chest,
//   forearms,
//   glutes,
//   hamstrings,
//   lats,
//   lowerBack,
//   middleBack,
//   neck,
//   quadriceps,
//   shoulders,
//   traps,
//   triceps
//TODO
// upperTraps
// lowerTraps
// rhomboids
// romboids
// neckExtensors
// neckFlexors
// rotatorCuffMuscles,
// hipFlexors,
// iliopsoas,
// tibialis,
// gastrocnemius,
// soleus
// serratus,
// obliques
// }

// enum Category {
//   powerlifting,
//   strength,
//   cardio,
//   olympicWeightlifting,
//   strongman,
//   plyometrics,
// }
