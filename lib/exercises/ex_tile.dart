import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/DOM/set_history_cubit.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/exercises/ex_dialog_page.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

class ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  final bool isSelectable;
  final bool isSelected;
  final Function? onSelectionChanged;
  final bool colorDecoration;
  final Color? borderColor;

  const ExerciseTile({
    super.key,
    required this.exercise,
    this.isSelectable = false,
    this.isSelected = false,
    this.onSelectionChanged,
    this.colorDecoration = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    String musclesUsed =
        exercise.primaryMuscles.map((muscle) => muscle.capTheFirstLetter()).join(', ');
    if (exercise.secondaryMuscles != null && exercise.secondaryMuscles!.isNotEmpty) {
      musclesUsed +=
          " + ${exercise.secondaryMuscles!.map((muscle) => muscle.capTheFirstLetter()).join(', ')}";
    }

    BoxDecoration tileDecoration = BoxDecoration(
      border: Border.all(
        color: (borderColor != null)
            ? borderColor!
            : (isSelectable ? (isSelected ? Colors.blue : Colors.black) : Colors.black),
        width: (borderColor == null) ? 1 : 2,
      ),
      color: colorDecoration ? Colors.grey[200] : null,
    );

    var exsHist = context.watch<SetsHistoryCubit>().state;
    SetsOfAnExercise anExHist = exsHist.firstWhere(
        (SetsOfAnExercise anExHist) => anExHist.ex.name == exercise.name,
        orElse: () => SetsOfAnExercise(exercise));
    int numUses = anExHist.sets.length;
    num? weight = anExHist.bestSet?.weight;
    num? reps = anExHist.bestSet?.reps;

    return Container(
      margin: const EdgeInsets.only(bottom: 5, right: 6, left: 6),
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
        trailing: (numUses > 0)
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$numUses uses", style: Theme.of(context).textTheme.bodyLarge),
                  (weight != null && reps != null)
                      ? Text("${weight}lb (x$reps)",
                          style: Theme.of(context).textTheme.bodyLarge)
                      : Text("60lb (x12) ", style: Theme.of(context).textTheme.bodyLarge),
                ],
              )
            : const SizedBox(
                width: 1,
              ),
        onTap: () {
          if (!isSelectable) {
            showDialog(
              context: context,
              builder: (context) => ExerciseDialog(exercise: exercise),
              useSafeArea: true,
            );
          } else {
            onSelectionChanged?.call(!isSelected);
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
