import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';

// ShowTrainingSession(BuildContext context) {
//   return showModalBottomSheet(
//     context: context,
//     useSafeArea: true,
//     constraints: BoxConstraints(
//       maxHeight: double.infinity,
//     ),
//     scrollControlDisabledMaxHeightRatio: 1,
//     isDismissible: false,
//     enableDrag: false,
//     elevation: 200,
//     backgroundColor: Theme.of(context).colorScheme.onBackground,
//     builder: (BuildContext context) => const TrainingPage(),
//   ).then((value) => null);
// }

class TrainingPage extends StatelessWidget {
  const TrainingPage({super.key});
  @override
  Widget build(BuildContext context) {
    var state = context.read<TrainingSessionCubit>().state;
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        // mainAxisAlignment: MainAxisAlignment,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(state.name ?? 'New Training Session', style: Theme.of(context).textTheme.headlineSmall),
          Text(state.duration?.inMinutes.toString() ?? '00:00', style: Theme.of(context).textTheme.bodySmall),
          Text(state.notes ?? 'Notes', style: Theme.of(context).textTheme.bodySmall),
          const SetTables(),
        ],
      ),
    );
  }
}

class SetTables extends StatelessWidget {
  const SetTables({super.key});
  @override
  Widget build(BuildContext context) {
    var state = context.read<TrainingSessionCubit>().state;
    // List<Text> exNames = [];
    List<Widget> allTablesAndHeaders = [];
    for (ExerciseSets es in state.trainingData) {
      List<TableRow> tableContent = [];
      //write headers
      allTablesAndHeaders.add(
        TextButton(onPressed: () {}, child: Text(es.ex.name, style: Theme.of(context).textTheme.labelMedium)),
      );
      tableContent.add(TableRow(
        children: [
          Text("Set", style: Theme.of(context).textTheme.labelMedium),
          Text("Previous", style: Theme.of(context).textTheme.labelMedium),
          if (es.prevSet.weight != null) Text("Weight", style: Theme.of(context).textTheme.labelMedium),
          if (es.prevSet.reps != null) Text("Reps", style: Theme.of(context).textTheme.labelMedium),
          if (es.prevSet.time != null) Text("Time", style: Theme.of(context).textTheme.labelMedium),
          if (es.prevSet.distance != null) Text("Distance", style: Theme.of(context).textTheme.labelMedium),
          if (es.prevSet.speed != null) Text("Speed", style: Theme.of(context).textTheme.labelMedium),
        ],
      ));

      //write sets
      for (int i = 0; i < es.sets.length; i++) {
        var set = es.sets[i];
        tableContent.add(TableRow(
          decoration: set.completed ? BoxDecoration(color: Theme.of(context).colorScheme.secondary) : null,
          children: [
            Text(i.toString(), style: Theme.of(context).textTheme.bodySmall),
            Text("-", style: Theme.of(context).textTheme.bodySmall),
            //make textfields for each setMetric
            if (es.prevSet.weight != null)
              SetDataTextField(set, i, es, (set) => set.weight, (set, value) => set.weight = value),
            if (es.prevSet.reps != null)
              SetDataTextField(set, i, es, (set) => set.reps, (set, value) => set.reps = value),
            if (es.prevSet.time != null)
              SetDataTextField(set, i, es, (set) => set.time, (set, value) => set.time = value),
            if (es.prevSet.distance != null)
              SetDataTextField(set, i, es, (set) => set.distance, (set, value) => set.distance = value),
            if (es.prevSet.speed != null)
              SetDataTextField(set, i, es, (set) => set.speed, (set, value) => set.speed = value),
            // if (set.weight != null)
            //   TextField(
            //     controller: TextEditingController(text: set.weight.toString()),
            //     style: Theme.of(context).textTheme.bodySmall,
            //     onChanged: (value) {
            //       set.weight = num.tryParse(value);
            //       if (set.weight == null) {
            //         set.weight = 0;
            //         value = '0';
            //       }
            //       context.read<TrainingSessionCubit>().updateSet(es.ex, set);
            //     },
            //     inputFormatters: <TextInputFormatter>[
            //       FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            //     ],
            //   ),
            // if (set.reps != null)
            //   TextField(
            //     controller: TextEditingController(text: set.reps.toString()),
            //     style: Theme.of(context).textTheme.bodySmall,
            //     onChanged: (value) {
            //       set.reps = num.tryParse(value);
            //       if (set.reps == null) {
            //         set.reps = 0;
            //         value = '0';
            //       }
            //       context.read<TrainingSessionCubit>().updateSet(es.ex, set);
            //     },
            //     inputFormatters: <TextInputFormatter>[
            //       FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            //     ],
            //   ),
            // if (set.time != null)
            //   TextField(
            //     controller: TextEditingController(text: set.time.toString()),
            //     style: Theme.of(context).textTheme.bodySmall,
            //     onChanged: (value) {
            //       set.time = num.tryParse(value);
            //       if (set.time == null) {
            //         set.time = 0;
            //         value = '0';
            //       }
            //       context.read<TrainingSessionCubit>().updateSet(es.ex, set);
            //     },
            //     inputFormatters: <TextInputFormatter>[
            //       FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            //     ],
            //   ),
            // if (set.distance != null)
            //   TextField(
            //     controller: TextEditingController(text: set.distance.toString()),
            //     style: Theme.of(context).textTheme.bodySmall,
            //     onChanged: (value) {
            //       set.distance = num.tryParse(value);
            //       if (set.distance == null) {
            //         set.distance = 0;
            //         value = '0';
            //       }
            //       context.read<TrainingSessionCubit>().updateSet(es.ex, set);
            //     },
            //     inputFormatters: <TextInputFormatter>[
            //       FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            //     ],
            //   ),
            // if (set.speed != null)
            //   TextField(
            //     controller: TextEditingController(text: set.speed.toString()),
            //     style: Theme.of(context).textTheme.bodySmall,
            //     onChanged: (value) {
            //       set.speed = num.tryParse(value);
            //       if (set.speed == null) {
            //         set.speed = 0;
            //         value = '0';
            //       }
            //       context.read<TrainingSessionCubit>().updateSet(es.ex, set);
            //     },
            //     inputFormatters: <TextInputFormatter>[
            //       FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            //     ],
            //   ),
          ],
        ));
      }
      // make table for the exercise with columnWidths based on the non null setMetrics
      var columnWidths = <int, TableColumnWidth>{};
      int numCols = 0;
      columnWidths[numCols++] = const FlexColumnWidth(1); // Set
      columnWidths[numCols++] = const FlexColumnWidth(4); // Previous
      if (es.prevSet.weight != null) columnWidths[numCols++] = const FlexColumnWidth(2); // Weight
      if (es.prevSet.reps != null) columnWidths[numCols++] = const FlexColumnWidth(2); // Reps
      if (es.prevSet.time != null) columnWidths[numCols++] = const FlexColumnWidth(2); // Time
      if (es.prevSet.distance != null) columnWidths[numCols++] = const FlexColumnWidth(2); // Distance
      if (es.prevSet.speed != null) columnWidths[numCols++] = const FlexColumnWidth(2); // Speed

      Table table = Table(
        columnWidths: columnWidths,
        children: tableContent,
      );
      allTablesAndHeaders.add(table);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: allTablesAndHeaders,
    );
  }
}

class SetDataTextField extends StatelessWidget {
  final Set set;
  final int setIndex;
  final ExerciseSets es;
  final Function getSetValue;
  final Function setSetValue;
  const SetDataTextField(this.set, this.setIndex, this.es, this.getSetValue, this.setSetValue, {super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: getSetValue(set).toString()),
      style: Theme.of(context).textTheme.bodySmall,
      onChanged: (value) {
        var parsedVal = num.tryParse(value);
        if (parsedVal == null) {
          value = '0';
        } else {
          Set modifiedSet = set;
          setSetValue(modifiedSet, parsedVal);
          context.read<TrainingSessionCubit>().updateSet(es.ex, modifiedSet, setIndex);
        }
      },
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
    );
  }
}

class TrainingSessionCubit extends Cubit<TrainingSession> {
  TrainingSessionCubit() : super(TrainingSession()) {
    var exampleExercise = Exercise(
      name: "Bench Press",
      equipment: "Barbell",
      primaryMuscles: ["Chest", "Triceps"],
      setMetrics: ["reps", "weight"],
    );
    var exampleExercise2 = Exercise(
      name: "Squat",
      equipment: "Barbell",
      primaryMuscles: ["Quadriceps", "Glutes"],
      setMetrics: ["reps", "weight"],
    );
    var exampleExerciseSet = ExerciseSets(exampleExercise);
    var exampleExerciseSet2 = ExerciseSets(exampleExercise2);
    exampleExerciseSet.sets.add(Set(exampleExerciseSet.ex));
    exampleExerciseSet2.sets.add(Set(exampleExerciseSet2.ex));
    state.trainingData.add(exampleExerciseSet);
    state.trainingData.add(exampleExerciseSet2);
  }

  void addExercise(Exercise ex) {
    state.trainingData.add(ExerciseSets(ex));
    emit(state);
  }

  // void removeExercise(Exercise ex) {
  //   state.trainingData.removeWhere((element) => element.ex == ex);
  //   emit(state);
  // }

  void addSet(Exercise ex) {
    state.trainingData.firstWhere((element) => element.ex == ex).sets.add(Set(ex));
    emit(state);
  }

  // void removeSet(Exercise ex, Set set) {
  //   state.trainingData
  //       .firstWhere((element) => element.ex == ex)
  //       .sets
  //       .remove(set);
  //   emit(state);
  // }

  void updateSet(Exercise ex, Set set, int setIndex) {
    //todo
    // state.trainingData
    //     .firstWhere((element) => element.ex == ex)
    //     .sets
    //     .firstWhere((element) => element == set)
    //     .completed = true;
    emit(state);
  }
}
