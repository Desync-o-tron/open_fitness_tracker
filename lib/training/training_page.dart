import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';
import 'package:open_fitness_tracker/styles.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

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

        // mainAxisSize: MainAxisSize.min,
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

class MakeVisualTable extends StatelessWidget {
  final Map<int, double> columnWidthsRatio;
  final List<Widget> header;
  final ExerciseTableData exerciseTableData;
  const MakeVisualTable(
      {required this.columnWidthsRatio, required this.header, required this.exerciseTableData, super.key});
  @override
  Widget build(BuildContext context) {
    Map<int, double> columnWidths = {};
    double width = getWidth(context) - 52;
    double totalFlex = 0;
    for (var flex in columnWidthsRatio.values) {
      totalFlex += flex;
    }
    for (int i = 0; i < columnWidthsRatio.length; i++) {
      columnWidths[i] = columnWidthsRatio[i]! * width / totalFlex;
    }

    List<Widget> pageContent = [];
    List<Widget> headerRow = [];
    for (int i = 0; i < header.length; i++) {
      headerRow.add(SizedBox(width: columnWidths[i], child: header[i]));
    }
    pageContent.add(Row(mainAxisAlignment: MainAxisAlignment.start, children: headerRow));
    pageContent.addAll(createTableRows(exerciseTableData, columnWidths, context));
    return Column(children: pageContent);
  }

  Row createHeaderRow(List<Widget> header, Map<int, double> columnWidths, BuildContext context) {
    List<Widget> headerRow = [];
    for (int i = 0; i < header.length; i++) {
      headerRow.add(SizedBox(width: columnWidths[i], child: header[i]));
    }
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: headerRow);
  }

  List<Widget> createTableRows(
      ExerciseTableData exerciseTableData, Map<int, double> columnWidths, BuildContext context) {
    List<Widget> tableRows = [];
    for (int i = 0; i < exerciseTableData.tableData.length; i++) {
      List<Widget> row = [];
      for (int j = 0; j < exerciseTableData.tableData[i].rowData.length; j++) {
        row.add(Container(
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.all(8.0),
          width: columnWidths[j],
          child: exerciseTableData.tableData[i].rowData[j],
        ));
      }
      tableRows.add(Dismissible(
        key: UniqueKey(),
        onDismissed: (direction) {
          context
              .read<TrainingSessionCubit>()
              .removeSet(exerciseTableData.ex, exerciseTableData.tableData[i].set.id);
        },
        background: Container(color: Colors.red),
        confirmDismiss: (direction) async {
          return true; //todo if the set is completed make sure to ask if they want to delete it
        },
        child: Row(children: row),
      ));
    }
    return tableRows;
  }
}

class SetTableRowData {
  final Set set;
  List<Widget> rowData = [];
  SetTableRowData(this.set, this.rowData);
}

class ExerciseTableData {
  final Exercise ex;
  final List<SetTableRowData> tableData;

  const ExerciseTableData(this.ex, this.tableData);
}

class DisplayTrainingData extends StatelessWidget {
  const DisplayTrainingData({super.key});
  @override
  Widget build(BuildContext context) {
    var state = context.watch<TrainingSessionCubit>().state;

    List<Widget> pageContent = []; //
    for (SetsOfAnExercise setsOfAnEx in state.trainingData) {
      List<Widget> header = [];
      List<SetTableRowData> tableContent = [];
      addTableHeaderForEx(pageContent, header, setsOfAnEx, context);
      addSetsDataForEx(tableContent, setsOfAnEx, context);
      final columnWidths = configColumnWidthRatio(setsOfAnEx);
      var table = MakeVisualTable(
        columnWidthsRatio: columnWidths,
        header: header,
        exerciseTableData: ExerciseTableData(setsOfAnEx.ex, tableContent),
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

  Map<int, double> configColumnWidthRatio(final SetsOfAnExercise es) {
    // make table for the exercise with columnWidths based on the non null setMetrics
    var columnWidthFlex = <int, double>{};
    int numCols = 0;
    columnWidthFlex[numCols++] = 1; // Set
    columnWidthFlex[numCols++] = 4; // Previous
    if (es.prevSet.weight != null) columnWidthFlex[numCols++] = 2; // Weight
    if (es.prevSet.reps != null) columnWidthFlex[numCols++] = 2; // Reps
    if (es.prevSet.time != null) columnWidthFlex[numCols++] = 2; // Time
    if (es.prevSet.distance != null) columnWidthFlex[numCols++] = 2; // Distance
    if (es.prevSet.speed != null) columnWidthFlex[numCols++] = 2; // Speed
    columnWidthFlex[numCols++] = 1; // Completed
    return columnWidthFlex;
  }

  void addSetsDataForEx(
    // List<List<Widget>> tableContent, final SetsOfAnExercise es, final BuildContext context) {
    List<SetTableRowData> tableContent,
    final SetsOfAnExercise es,
    final BuildContext context,
  ) {
    for (int i = 0; i < es.sets.length; i++) {
      var set = es.sets[i];

      tableContent.add(
        SetTableRowData(set, [
          Text((i + 1).toString(), style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
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
        ]),
      );
    }
  }

  void addTableHeaderForEx(
    List<Widget> allTablesAndHeaders,
    List<Widget> header,
    final SetsOfAnExercise es,
    final BuildContext context,
  ) {
    allTablesAndHeaders.add(
      TextButton(onPressed: () {}, child: Text(es.ex.name, style: Theme.of(context).textTheme.titleMedium)),
    );

    //utility function
    Widget headerText(String text, BuildContext context) {
      return Text(text, style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center);
    }

    header.addAll(
      [
        headerText("Set", context),
        headerText("Previous", context),
        if (es.prevSet.weight != null) headerText("Weight", context),
        if (es.prevSet.reps != null) headerText("Reps", context),
        if (es.prevSet.time != null) headerText("Time", context),
        if (es.prevSet.distance != null) headerText("Distance", context),
        if (es.prevSet.speed != null) headerText("Speed", context),
        headerText("Done", context),
      ],
    );
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
  //todo these text fields suck?
  //on win, it loses focus after every character input (noticed once)
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.getSetValue(widget.set).toString());
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
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
    );
  }
}
