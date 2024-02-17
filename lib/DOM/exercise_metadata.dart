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
  final String? id;
  final String name;
  final Force? force;
  final Level? level;
  final Mechanic? mechanic;
  final String? equipment;
  final List<String>? setMetrics;
  final List<String> primaryMuscles;
  final List<String>? secondaryMuscles;
  final List<String>? instructions;
  final String? category;
  final List<String>? images;

  // Exercise(String s, {
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
