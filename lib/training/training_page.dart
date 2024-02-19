import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';

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
          const DisplayTrainingData(),
        ],
      ),
    );
  }
}

class DisplayTrainingData extends StatelessWidget {
  const DisplayTrainingData({super.key});
  @override
  Widget build(BuildContext context) {
    var state = context.watch<TrainingSessionCubit>().state;

    List<Widget> pageContent = [];
    for (SetsOfAnExercise setsOfAnEx in state.trainingData) {
      List<TableRow> tableContent = [];
      addTableHeaderForEx(pageContent, setsOfAnEx, context, tableContent);
      addSetsForEx(setsOfAnEx, tableContent, context);
      final columnWidths = configColumnWidths(setsOfAnEx);
      Table table = Table(
        columnWidths: columnWidths,
        children: tableContent,
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      );
      pageContent.add(table);
      pageContent.add(
        Center(
          child: MyGenericButton(
              label: "Add Set",
              onPressed: () {
                context.read<TrainingSessionCubit>().addSet(setsOfAnEx.ex);
              }),
        ),
      );
    }

    pageContent.add(Center(
      child: MyGenericButton(
        label: "Add Exercise",
        onPressed: () {
          // context.read<TrainingSessionCubit>().addExercise();
        },
        color: Theme.of(context).colorScheme.primary,
        textColor: Theme.of(context).colorScheme.onPrimary,
        // textColor: Colors.white ,
      ),
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: pageContent,
    );
  }

  Map<int, TableColumnWidth> configColumnWidths(SetsOfAnExercise es) {
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
    columnWidths[numCols++] = const FlexColumnWidth(1); // Completed
    return columnWidths;
  }

  void addSetsForEx(SetsOfAnExercise es, List<TableRow> tableContent, BuildContext context) {
    for (int i = 0; i < es.sets.length; i++) {
      var set = es.sets[i];
      tableContent.add(TableRow(
        decoration: set.completed ? BoxDecoration(color: Theme.of(context).colorScheme.secondary) : null,
        children: [
          Text((i + 1).toString(), style: Theme.of(context).textTheme.bodySmall),
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
          TextButton(
            onPressed: () {
              set.completed = !set.completed;
              context.read<TrainingSessionCubit>().updateSet(es.ex, set, i);
            },
            child: Icon(
              set.completed ? Icons.check_circle : Icons.check_circle_outline,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ));
    }
  }

  void addTableHeaderForEx(List<Widget> allTablesAndHeaders, SetsOfAnExercise es, BuildContext context,
      List<TableRow> tableContent) {
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
        Text("Done", style: Theme.of(context).textTheme.labelMedium),
      ],
    ));
  }
}

class SetDataTextField extends StatelessWidget {
  final Set set;
  final int setIndex;
  final SetsOfAnExercise es;
  final Function getSetValue;
  final Function setSetValue;
  const SetDataTextField(this.set, this.setIndex, this.es, this.getSetValue, this.setSetValue, {super.key});
  //todo these text fields suck
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container()),
        Expanded(
          flex: 4,
          child: TextField(
            controller: TextEditingController(text: getSetValue(set).toString()),
            style: Theme.of(context).textTheme.bodySmall,
            // ?.copyWith(
            //       // fontSize: 12, // Adjust the size as needed
            //       background: Paint()..color = Theme.of(context).colorScheme.secondary,
            //       // decoration: TextDecoration.combine([TextDecoration.underline])
            //     ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.0),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
              constraints: const BoxConstraints(
                maxWidth: 50.0,
                maxHeight: 30.0,
              ),
            ),
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
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }
}
