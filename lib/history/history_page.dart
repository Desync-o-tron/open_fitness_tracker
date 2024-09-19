import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/cloud_io/firestore_sync.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';
import 'package:open_fitness_tracker/history/import_training_dialog.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final int _pageSize = 10; // Number of items per page
  final List<TrainingSession> _sessions = [];
  var numSessions = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  DateTime? _lastTimestamp;
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<List<TrainingSession>>? _subscription;

  @override
  void initState() {
    super.initState();
    _loadMoreData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 400 &&
          !_isLoading &&
          _hasMore) {
        _loadMoreData();
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMoreData() async {
    setState(() {
      _isLoading = true;
    });

    final stream = myStorage.getUserTrainingHistoryStream(
      limit: _pageSize,
      startAfterTimestamp: _lastTimestamp,
    );

    _subscription = stream.listen((sessions) {
      setState(() {
        if (sessions.isNotEmpty) {
          _lastTimestamp = sessions.last.date;
          _sessions.addAll(sessions);
          if (sessions.length < _pageSize) {
            _hasMore = false;
          }
        } else {
          _hasMore = false;
        }
        _isLoading = false;
      });
    }, onError: (error) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $error')),
        );
      } else {
        //todo error handling?
      }
    });
    numSessions = (await myStorage.getEntireUserTrainingHistory(useCache: true)).length;
    setState(() {
      //numSessions
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('History ($numSessions)'),
          actions: [
            _hamburgerMenuActions(context),
          ],
        ),
        body: _buildBody(),
      );
    });
  }

  Widget _buildBody() {
    if (_sessions.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_sessions.isEmpty && !_hasMore) {
      return const Center(child: Text('No History'));
    } else {
      return ListView.builder(
        controller: _scrollController,
        itemCount: _sessions.length + 1,
        itemBuilder: (context, index) {
          if (index < _sessions.length) {
            return TrainingSessionHistoryCard(session: _sessions[index]);
          } else if (_hasMore) {
            return const CircularProgressIndicator();
          } else {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.all(16.0),
              child: const Text("that's everything!"),
            );
          }
        },
      );
    }
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
        if (result == 'refresh training history') {
          myStorage.getEntireUserTrainingHistory(useCache: false);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'import',
          child: Text('Import exercise & training data'),
        ),
        const PopupMenuItem<String>(
          value: 'refresh training history',
          child: Text('refresh training history cache'),
        ),
        PopupMenuItem<String>(
            value: 'delete history',
            child: ElevatedButton(
              onPressed: () {
                context.read<TrainingHistoryCubit>().deleteHistory();
              },
              child: const Text("dont click me"),
            )),
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
                            builder: (context) =>
                                TrainingHistoryCardManagementDialog(session));
                      },
                      child: const Icon(Icons.edit),
                    )),
              ],
            ),
            Text("Completed ${session.date.toDaysAgo()}",
                style: Theme.of(context).textTheme.titleSmall),
            Text(
              DateFormat('h:mm a EEEE, MMMM d, y').format(session.date),
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
            Text("id: ${session.id}"),
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
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    delSesh() async {
      myStorage
          .removeHistoryData(sesh)
          .onError((error, stackTrace) => scaffoldMessenger.showSnackBar(const SnackBar(
                content: Text('Failed to delete training session'),
                duration: Duration(seconds: 2),
              )));
    }

    return AlertDialog(
      title: Text(sesh.name == "" ? "Training Session" : sesh.name),
      content: SizedBox(
        height: 499,
        child: Column(
          children: [
            MyGenericButton(
              label: "Delete",
              onPressed: () {
                delSesh();
                if (context.mounted) context.pop();
              },
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
      return Text(text,
          style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center);
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
      return Text(text,
          style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center);
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: headerRow,
    );
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
