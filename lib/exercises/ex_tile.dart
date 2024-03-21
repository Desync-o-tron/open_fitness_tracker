import 'package:flutter/material.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/exercises/ex_dialog_page.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

class ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  final bool isSelectable;
  final bool isSelected;
  final Function? onSelectionChanged;

  const ExerciseTile({
    super.key,
    required this.exercise,
    this.isSelectable = false,
    this.isSelected = false,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    String musclesUsed = exercise.primaryMuscles.map((muscle) => muscle.capTheFirstLetter()).join(', ');
    if (exercise.secondaryMuscles != null && exercise.secondaryMuscles!.isNotEmpty) {
      musclesUsed +=
          " + ${exercise.secondaryMuscles!.map((muscle) => muscle.capTheFirstLetter()).join(', ')}";
    }

    BoxDecoration tileDecoration = const BoxDecoration();
    if (isSelectable) {
      tileDecoration = BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.black,
          width: 1,
        ),
      );
    } else {
      tileDecoration = BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 5, right: 6, left: 6),
      // decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
      decoration: tileDecoration,
      child: ListTile(
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
          if (!isSelectable) {
            showDialog(
              context: context,
              builder: (context) => ExerciseDialog(exercise: exercise),
              useSafeArea: true,
            );
          } else if (isSelectable) {
            onSelectionChanged!(!isSelected);
          }
        },
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) => ExerciseDialog(exercise: exercise),
            useSafeArea: true,
          );
        },
      ),
    );
  }
}
