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
  String name;
  Force? force;
  Level? level;
  Mechanic? mechanic;
  String? equipment;
  List<String>? setMetrics;
  List<String> primaryMuscles;
  List<String>? secondaryMuscles;
  List<String>? instructions;
  String? category;
  List<String>? images;

  Exercise({
    this.id,
    required this.name,
    this.force,
    this.level,
    this.mechanic,
    required this.equipment,
    this.setMetrics,
    required this.primaryMuscles,
    this.secondaryMuscles,
    this.instructions,
    this.category,
    this.images,
  });

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
//   bodyOnly,
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
// }

// enum Category {
//   powerlifting,
//   strength,
//   stretching,
//   cardio,
//   olympicWeightlifting,
//   strongman,
//   plyometrics,
// }
