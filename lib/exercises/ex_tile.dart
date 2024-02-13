import 'package:flutter/material.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

class ExerciseTile extends StatelessWidget {
  final Exercise exercise;

  const ExerciseTile({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    String musclesUsed = exercise.primaryMuscles.map((muscle) => muscle.capTheFirstLetter()).join(', ');
    if (exercise.secondaryMuscles != null && exercise.secondaryMuscles!.isNotEmpty) {
      musclesUsed +=
          " + ${exercise.secondaryMuscles!.map((muscle) => muscle.capTheFirstLetter()).join(', ')}";
    }
    return ListTile(
      title: Text(exercise.name, style: Theme.of(context).textTheme.titleLarge),
      minVerticalPadding: 2,
      visualDensity: VisualDensity.compact,
      enabled: true,
      subtitle: Text(
        musclesUsed,
        style: Theme.of(context).textTheme.bodyLarge,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("2 uses ", style: Theme.of(context).textTheme.bodyLarge),
          Text("60lb (x12) ", style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
      onTap: () {
        // Handle tile tap if necessary
      },
    );
  }
}
