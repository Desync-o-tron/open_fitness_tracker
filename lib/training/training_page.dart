import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';
import 'package:open_fitness_tracker/styles.dart';

class TrainingPage extends StatelessWidget {
  const TrainingPage({super.key});
  @override
  Widget build(BuildContext context) {
    var state = context.read<TrainingSessionCubit>().state;
    return Container(
      padding: const EdgeInsets.all(16.0),
      // color: Theme.of(context).colorScheme.secondary,
      color: darkTan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(state.name ?? 'New Training Session', style: Theme.of(context).textTheme.headlineSmall),
          Text(state.duration?.inMinutes.toString() ?? '00:00', style: Theme.of(context).textTheme.bodySmall),
          Text(state.notes ?? 'Notes', style: Theme.of(context).textTheme.bodySmall),
          const DisplayTrainingData(),
          const SizedBox(height: 70),
          Row(
            children: [
              Expanded(
                child: Container(),
              ),
              Expanded(child: MyGenericButton(label: "Cancel", onPressed: () {}, color: darkTan)),
              const SizedBox(width: 20),
              Expanded(child: MyGenericButton(label: "Finish", onPressed: () {}, color: mediumGreen)),
              Expanded(
                child: Container(),
              ),
            ],
          )
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
      pageContent.add(const SizedBox(height: 20));
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
      tableContent.add(
        TableRow(
          decoration: set.completed ? BoxDecoration(color: Theme.of(context).colorScheme.secondary) : null,
          children: [
            Text((i + 1).toString(),
                style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
            Text("-", style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
            //add textfields for each setMetric
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
        ),
      );
    }
  }

  void addTableHeaderForEx(List<Widget> allTablesAndHeaders, SetsOfAnExercise es, BuildContext context,
      List<TableRow> tableContent) {
    allTablesAndHeaders.add(
      TextButton(onPressed: () {}, child: Text(es.ex.name, style: Theme.of(context).textTheme.titleMedium)),
    );
    //utility function
    Widget headerText(String text, BuildContext context) {
      return Text(text, style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center);
    }

    tableContent.add(TableRow(
      children: [
        headerText("Set", context),
        headerText("Previous", context),
        if (es.prevSet.weight != null) headerText("Weight", context),
        if (es.prevSet.reps != null) headerText("Reps", context),
        if (es.prevSet.time != null) headerText("Time", context),
        if (es.prevSet.distance != null) headerText("Distance", context),
        if (es.prevSet.speed != null) headerText("Speed", context),
        headerText("Done", context),
      ],
    ));
  }
}

class SetDataTextField extends StatefulWidget {
  // const SetDataTextField({super.key});
  final Set set;
  final int setIndex;
  final SetsOfAnExercise es;
  final Function getSetValue;
  final Function setSetValue;
  const SetDataTextField(this.set, this.setIndex, this.es, this.getSetValue, this.setSetValue, {super.key});
  @override
  // ignore: library_private_types_in_public_api
  _SetDataTextFieldState createState() => _SetDataTextFieldState();
}

class _SetDataTextFieldState extends State<SetDataTextField> {
  //todo these text fields suck
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.getSetValue(widget.set).toString());
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container()),
        Expanded(
          flex: 2,
          child: TextField(
            controller: textController,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0), // weird, but does the trick
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
                // setSetValue(set, 0);
              } else {
                Set modifiedSet = widget.set;
                widget.setSetValue(modifiedSet, parsedVal);
                context.read<TrainingSessionCubit>().updateSet(widget.es.ex, modifiedSet, widget.setIndex);
              }
            },
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.deny(
                  RegExp(r'[^0-9.]')), // This allows digits, a decimal point, and backspace/delete
              TextInputFormatter.withFunction((oldValue, newValue) {
                // This allows only one decimal point
                int count = 0;
                for (int i = 0; i < newValue.text.length; i++) {
                  if (newValue.text[i] == '.') {
                    count++;
                  }
                }
                if (count > 1) {
                  return oldValue;
                }
                return newValue;
              }),
            ],
          ),
        ),
        Expanded(
          child: Container(),
        ),
      ],
    );
  }
}
