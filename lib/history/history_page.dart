import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    var history = context.watch<TrainingHistoryCubit>().state;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'History',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        if (history.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              'No History',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              return TrainingSessionHistoryCard(session: history[index]);
            },
          ),
        ),
      ],
    );
  }
}

class TrainingSessionHistoryCard extends StatelessWidget {
  final TrainingSession session;
  const TrainingSessionHistoryCard({required this.session, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (session.name.isNotEmpty)
              Text(
                session.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            Text(
              DateFormat('h:mm a EEEE, MMMM d, y').format(session.dateTime),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              'Duration: ${session.duration.toHoursMinutes()}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 10),
            DisplayTrainingData(),
            /*ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: session.trainingData.length,
              itemBuilder: (context, index) {
                final SetsOfAnExercise sets = session.trainingData[index];
                return Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sets.ex.name,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: sets.sets.length,
                        itemBuilder: (context, index) {
                          final Set set = sets.sets[index];
                          return Text(
                            '${index + 1}: ${set.weight} lb x ${set.reps}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),*/
          ],
        ),
      ),
    );
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
    List<Widget> pageContent = [];
    for (SetsOfAnExercise setsOfAnEx in context.watch<TrainingSessionCubit>().state.trainingData) {
      List<Widget> header = [];
      List<SetTableRowData> tableContent = [];
      addTableHeaderForEx(pageContent, header, setsOfAnEx, context);
      addSetsDataForEx(tableContent, setsOfAnEx, context);
      final columnWidths = configColumnWidthRatio(setsOfAnEx);
      var table = MakeHistoryVisualTableWithSpacing(
        columnWidthsRatio: columnWidths,
        header: header,
        exerciseTableData: ExerciseTableData(setsOfAnEx.ex, tableContent),
      );
      pageContent.add(table);
      pageContent.add(const SizedBox(height: 20));
    }

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
          Text("-", style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          //add textfields for each setMetric
          if (es.prevSet.weight != null)
            // SetDataTextField(set, setNum, es, set.weight, (set, value) => set.weight = value),
            Text("${set.weight} lb x "),
          if (es.prevSet.reps != null)
            // SetDataTextField(set, setNum, es, set.reps, (set, value) => set.reps = value),
            Text("${set.reps}"),
          if (es.prevSet.time != null)
            // SetDataTextField(set, setNum, es, set.time, (set, value) => set.time = value),
            Text("${set.time} s"),
          if (es.prevSet.distance != null)
            // SetDataTextField(set, setNum, es, set.distance, (set, value) => set.distance = value),
            Text("${set.distance} m"),
          if (es.prevSet.speed != null)
            // SetDataTextField(set, setNum, es, set.speed, (set, value) => set.speed = value),
            Text("${set.speed} m/s"),
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
          Text(es.ex.name, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
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

class MakeHistoryVisualTableWithSpacing extends StatelessWidget {
  final Map<int, double> columnWidthsRatio;
  final List<Widget> header;
  final ExerciseTableData exerciseTableData;

  const MakeHistoryVisualTableWithSpacing({
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
    pageContent.addAll(createTableRowsWithSpacing(exerciseTableData, columnWidths, context));
    return Column(children: pageContent);
  }

  Row createHeaderRowWithSpacing(List<Widget> header, Map<int, double> columnWidths, BuildContext context) {
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

  List<Widget> createTableRowsWithSpacing(
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
      tableRows.add(Row(children: row));
    }
    return tableRows;
  }
}
