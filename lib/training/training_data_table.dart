// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';
import 'package:open_fitness_tracker/exercises/ex_search_page.dart';
import 'package:open_fitness_tracker/training/dialogs_for_training.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

/*
for future refactoring:
I create a header and table content for each exercise.
Then I pass these into a MakeVisualTable widget which adds margins and spacing. not <i>evil</i> but not great either.
  I could have the MakeVisualTable widget take in the exercise and the trainingData and generate the header and table content itself. idk if this is the best way to do it either.
*/
//todo allow the unit to be set in the header of each column? or in settings??

class MakeVisualTableWithSpacing extends StatelessWidget {
  final Map<int, double> columnWidthsRatio;
  final List<Widget> header;
  final ExerciseTableData exerciseTableData;

  const MakeVisualTableWithSpacing({
    required this.columnWidthsRatio,
    required this.header,
    required this.exerciseTableData,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Map<int, double> columnWidths = {};
    double width = getWidth(context) - 40;
    double totalFlex = 0;
    for (var flex in columnWidthsRatio.values) {
      totalFlex += flex;
    }
    for (int i = 0; i < columnWidthsRatio.length; i++) {
      columnWidths[i] = columnWidthsRatio[i]! * width / totalFlex;
    }

    List<Widget> pageContent = [];
    pageContent.add(createHeaderRowWithSpacing(header, columnWidths, context));
    pageContent
        .addAll(createTableRowsWithSpacing(exerciseTableData, columnWidths, context));
    return Column(children: pageContent);
  }

  Row createHeaderRowWithSpacing(
      List<Widget> header, Map<int, double> columnWidths, BuildContext context) {
    List<Widget> headerRow = [];
    for (int i = 0; i < header.length; i++) {
      headerRow.add(Container(
        width: columnWidths[i],
        margin: const EdgeInsets.all(2),
        child: header[i],
      ));
    }
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: headerRow);
  }

  List<Widget> createTableRowsWithSpacing(ExerciseTableData exerciseTableData,
      Map<int, double> columnWidths, BuildContext context) {
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

class DisplayTrainingData extends StatefulWidget {
  const DisplayTrainingData({super.key});

  @override
  State<DisplayTrainingData> createState() => _DisplayTrainingDataState();
}

class _DisplayTrainingDataState extends State<DisplayTrainingData> {
  @override
  Widget build(BuildContext context) {
    List<Widget> pageContent = []; //
    for (SetsOfAnExercise setsOfAnEx
        in context.read<TrainingSessionCubit>().state.trainingData) {
      List<Widget> header = [];
      List<SetTableRowData> tableContent = [];
      addTableHeaderForEx(pageContent, header, setsOfAnEx, context);
      addSetsDataForEx(tableContent, setsOfAnEx, context);
      final columnWidths = configColumnWidthRatio(setsOfAnEx);
      var table = MakeVisualTableWithSpacing(
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
              var cubit = context.read<TrainingSessionCubit>();
              cubit.addSet(setsOfAnEx.ex);
              setState(() {});
            },
          ),
        ),
      );
      pageContent.add(const SizedBox(height: 20));
    }

    pageContent.add(Center(
      child: MyGenericButton(
        label: "Add Exercise",
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) =>
                  ExerciseSearchPage(useForAddingToTraining: true),
            ),
          );
          setState(() {}); //todo this is weird
        },
        color: Theme.of(context).colorScheme.primary,
        textColor: Theme.of(context).colorScheme.onPrimary,
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
    columnWidthFlex[numCols++] = 2; // Completed
    return columnWidthFlex;
  }

  void addSetsDataForEx(
    List<SetTableRowData> tableContent,
    final SetsOfAnExercise es,
    final BuildContext context,
  ) {
    for (int setNum = 0; setNum < es.sets.length; setNum++) {
      var set = es.sets[setNum];

      tableContent.add(
        SetTableRowData(set, [
          Text((setNum + 1).toString(),
              style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          Text("-",
              style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          //add textfields for each setMetric
          if (es.prevSet.weight != null)
            SetDataTextField(set, setNum, es, set.weight, (set, value) {
              set.weight = value;
              context.read<TrainingSessionCubit>().updateSet(es.ex, set, setNum);
            }), //TODO kg/lbs overhaul
          if (es.prevSet.reps != null)
            SetDataTextField(set, setNum, es, set.reps, (set, value) {
              set.reps = value;
              context.read<TrainingSessionCubit>().updateSet(es.ex, set, setNum);
            }),
          if (es.prevSet.time != null)
            SetDataTextField(set, setNum, es, set.time, (set, value) {
              set.time = value;
              context.read<TrainingSessionCubit>().updateSet(es.ex, set, setNum);
            }),
          if (es.prevSet.distance != null)
            SetDataTextField(set, setNum, es, set.distance, (set, value) {
              set.distance = value;
              context.read<TrainingSessionCubit>().updateSet(es.ex, set, setNum);
            }),
          if (es.prevSet.speed != null)
            SetDataTextField(set, setNum, es, set.speed, (set, value) {
              set.speed = value;
              context.read<TrainingSessionCubit>().updateSet(es.ex, set, setNum);
            }),
          TextButton(
            onPressed: () {
              set.completed = !set.completed;
              context.read<TrainingSessionCubit>().updateSet(es.ex, set, setNum);
              setState(() {});
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
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(es.ex.name, style: Theme.of(context).textTheme.titleMedium),
          SizedBox(
            height: 40,
            child: Center(
              child: MyGenericButton(
                icon: Icon(FontAwesomeIcons.ellipsis,
                    size: 15.0, color: Theme.of(context).colorScheme.onSecondary),
                onPressed: () async {
                  await showDialog(
                      context: context, builder: (context) => ExManagementDialog(es));
                  setState(() {});
                },
                color: Theme.of(context).colorScheme.secondary,
                shouldFillWidth: false,
              ),
            ),
          ),
        ],
      ),
    );

    //utility function
    Widget headerText(String text, BuildContext context) {
      return Text(text,
          style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center);
    }

    header.addAll(
      [
        headerText("Set", context),
        headerText("Previous", context),
        if (es.prevSet.weight != null) headerText("Weight", context),
        if (es.prevSet.reps != null) headerText("Reps", context),
        if (es.prevSet.time != null) headerText("Time", context),
        //^todo split seconds into hrs/min/secs as needed
        if (es.prevSet.distance != null) headerText("Distance", context),
        if (es.prevSet.speed != null) headerText("Speed", context),
        headerText("Done", context),
      ],
    );
  }
}

class SetDataTextField extends StatefulWidget {
  final Set set;
  final int setIndex;
  final SetsOfAnExercise es;
  // ignore: prefer_typing_uninitialized_variables
  final ogValue;
  final Function setSetValue; //this makes sense.
  const SetDataTextField(this.set, this.setIndex, this.es, this.ogValue, this.setSetValue,
      {super.key});
  @override
  // ignore: library_private_types_in_public_api
  _SetDataTextFieldState createState() => _SetDataTextFieldState();
}

class _SetDataTextFieldState extends State<SetDataTextField> {
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.ogValue.toString());
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      onTap: () => textController.selection =
          TextSelection(baseOffset: 0, extentOffset: textController.text.length),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        constraints: const BoxConstraints(
          maxWidth: 50.0,
          maxHeight: 35.0,
        ),
      ),
      onChanged: (value) {
        var parsedVal = num.tryParse(value);
        if (parsedVal == null) {
          value = '0';
        } else {
          Set modifiedSet = widget.set;
          widget.setSetValue(modifiedSet, parsedVal);
          context
              .read<TrainingSessionCubit>()
              .updateSet(widget.es.ex, modifiedSet, widget.setIndex);
        }
      },
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.deny(RegExp(
            r'[^0-9.]')), // This allows digits, a decimal point, and backspace/delete
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
