import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/cloud_io/firestore_sync.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';
import 'package:open_fitness_tracker/history/import_training.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

//todo when new history syncs in, the page needs to be updated to reflect the new data!
/*
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ScrollController _scrollController = ScrollController();
  List<TrainingSession> _displayedHistory = [];
  int _currentPage = 0;
  final int _itemsPerPage = 20;

  @override
  void initState() {
    super.initState();
    _loadMoreItems();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreItems();
    }
  }

  void _loadMoreItems() {
    final history = context.read<TrainingHistoryCubit>().state;
    final start = _currentPage * _itemsPerPage;
    final end = ((_currentPage + 1) * _itemsPerPage).clamp(0, history.length);
    if (start < history.length) {
      setState(() {
        _displayedHistory.addAll(history.sublist(start, end));
        _currentPage++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          _hamburgerMenuActions(context),
        ],
      ),
      body: Container(
        color: Colors.blueGrey,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _displayedHistory.length + 1,
          itemBuilder: (context, index) {
            if (index < _displayedHistory.length) {
              return TrainingSessionHistoryCard(session: _displayedHistory[index]);
            } else if (index == _displayedHistory.length) {
              return const Center(child: CircularProgressIndicator());
            }
            return null;
          },
        ),
      ),
    );
  }
*/

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    var history = context.watch<TrainingHistoryCubit>().state;
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          _hamburgerMenuActions(context),
        ],
      ),
      body: Container(
        color: Colors.blueGrey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                // itemCount: 10,
                itemBuilder: (context, index) {
                  return TrainingSessionHistoryCard(session: history[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hamburgerMenuActions(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz_outlined, size: 30),
      onSelected: (String result) {
        if (result == 'import') {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return const ExternalAppTrainingImportDialog();
              });
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'import',
          child: Text('Import exercise & training data'),
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
            Column(
              children: [
                if (session.name.isNotEmpty)
                  Text(
                    session.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        await showDialog(
                            context: context,
                            builder: (context) => TrainingHistoryCardManagementDialog(session));
                      },
                      child: const Icon(Icons.edit),
                    )),
              ],
            ),
            Text("id: ${session.id}"),
            Text("Completed ${session.dateTime.toDaysAgo()}", style: Theme.of(context).textTheme.titleSmall),
            Text(
              DateFormat('h:mm a EEEE, MMMM d, y').format(session.dateTime),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              'Duration: ${session.duration.toHoursMinutes()}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (session.notes != null && session.notes!.isNotEmpty)
              Text(
                "Notes: ${session.notes!}",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            const SizedBox(height: 10),
            DisplayPastTrainingData(session),
          ],
        ),
      ),
    );
  }
}

class TrainingHistoryCardManagementDialog extends StatelessWidget {
  final TrainingSession sesh;
  const TrainingHistoryCardManagementDialog(this.sesh, {super.key});
  @override
  Widget build(BuildContext context) {
    final trainingHistoryCubit = context.read<TrainingHistoryCubit>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    delSesh() async {
      if (await cloudStorage.removeHistoryData(sesh)) {
        trainingHistoryCubit.removeSession(sesh);
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Failed to delete training session'),
            duration: Duration(seconds: 2),
          ), //todo test me
        );
      }
    }

    return AlertDialog(
      title: Text(sesh.name == "" ? "Training Session" : sesh.name),
      content: SizedBox(
        height: 499,
        child: Column(
          children: [
            MyGenericButton(
              label: "Delete",
              onPressed: () => delSesh().then((value) => context.pop()),
              color: Theme.of(context).colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }
}

class DisplayPastTrainingData extends StatefulWidget {
  const DisplayPastTrainingData(this.session, {super.key});

  final TrainingSession session;

  @override
  State<DisplayPastTrainingData> createState() => _DisplayPastTrainingDataState();
}

class _DisplayPastTrainingDataState extends State<DisplayPastTrainingData> {
  @override
  Widget build(BuildContext context) {
    List<Widget> pageContent = [];
    for (SetsOfAnExercise setsOfAnEx in widget.session.trainingData) {
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
    if (es.prevSet.weight != null) columnWidthFlex[numCols++] = 2; // Weight
    if (es.prevSet.reps != null) columnWidthFlex[numCols++] = 2; // Reps
    if (es.prevSet.time != null) columnWidthFlex[numCols++] = 2; // Time
    if (es.prevSet.distance != null) columnWidthFlex[numCols++] = 2; // Distance
    if (es.prevSet.speed != null) columnWidthFlex[numCols++] = 2; // Speed
    return columnWidthFlex;
  }

  void addSetsDataForEx(
    List<SetTableRowData> tableContent,
    final SetsOfAnExercise es,
    final BuildContext context,
  ) {
    //utility function
    Widget tableText(String text) {
      return Text(text, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center);
    }

    for (int setNum = 0; setNum < es.sets.length; setNum++) {
      var set = es.sets[setNum];

      tableContent.add(
        SetTableRowData(set, [
          tableText(setNum.toString()),
          if (es.prevSet.weight != null) tableText("${set.weight} lb"),
          if (es.prevSet.reps != null) tableText("${set.reps}"),
          if (es.prevSet.time != null) tableText("${set.time} s"),
          if (es.prevSet.distance != null) tableText("${set.distance} m"),
          if (es.prevSet.speed != null) tableText("${set.speed} m/s"),
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
        if (es.prevSet.weight != null) headerText("Weight", context),
        if (es.prevSet.reps != null) headerText("Reps", context),
        if (es.prevSet.time != null) headerText("Time", context),
        if (es.prevSet.distance != null) headerText("Distance", context),
        if (es.prevSet.speed != null) headerText("Speed", context),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: headerRow,
    );
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
      tableRows.add(Container(
        color: i.isEven ? Colors.white : Colors.grey[200],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: row,
        ),
      ));
    }
    return tableRows;
  }
}
