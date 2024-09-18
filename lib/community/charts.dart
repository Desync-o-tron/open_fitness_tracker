import 'dart:math';
import 'package:flutter/material.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/cloud_io/firestore_sync.dart';
import 'package:fl_chart/fl_chart.dart';

class CoolChart extends StatefulWidget {
  const CoolChart({super.key});

  @override
  State<CoolChart> createState() => _CoolChartState();
}

class DateAndWeight {
  DateAndWeight(this.date, this.weight);
  DateTime date;
  double weight;
}

class _CoolChartState extends State<CoolChart> {
  List<DateAndWeight> bestWeightsOnDates = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    List<TrainingSession> trainHist = await myStorage.getEntireUserTrainingHistory();
    for (var trainSesh in trainHist) {
      for (var setsOfAnExercise in trainSesh.trainingData) {
        if (setsOfAnExercise.ex.name.toLowerCase().contains("deadlift")) {
          double bestWeight = 0;
          for (var mySet in setsOfAnExercise.sets) {
            bestWeight = max(mySet.weight!, bestWeight).toDouble();
          }
          bestWeightsOnDates.add(DateAndWeight(trainSesh.date, bestWeight));
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (bestWeightsOnDates.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        const Text(
          'Best Deadlift Weights Over Time',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1.7,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LineChart(
              _buildLineChartData(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData _buildLineChartData() {
    double maxY = bestWeightsOnDates.map((e) => e.weight).reduce(max) + 10;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        horizontalInterval: 10,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey.withOpacity(0.2),
          strokeWidth: 1,
        ),
        getDrawingVerticalLine: (value) => FlLine(
          color: Colors.grey.withOpacity(0.2),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          axisNameWidget: const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Text('Weight (lb)', style: TextStyle(fontSize: 14)),
          ),
          axisNameSize: 16,
          sideTitles: SideTitles(
            showTitles: true,
            interval: 10,
            getTitlesWidget: (value, meta) {
              return Text('${value.toInt()} lb', style: const TextStyle(fontSize: 12));
            },
          ),
        ),
        bottomTitles: AxisTitles(
          axisNameWidget: const Text('Date', style: TextStyle(fontSize: 14)),
          axisNameSize: 16,
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: _bottomTitleWidgets,
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
      ),
      minX: 0,
      maxX: bestWeightsOnDates.length.toDouble() - 1,
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: bestWeightsOnDates.asMap().entries.map((e) {
            return FlSpot(e.key.toDouble(), e.value.weight);
          }).toList(),
          isCurved: true,
          color: Colors.blueAccent,
          barWidth: 4,
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.blueAccent.withOpacity(0.5),
                Colors.blueAccent.withOpacity(0.0),
              ],
              stops: const [0.5, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          dotData: FlDotData(
            show: true,
            getDotPainter: (
              spot,
              percent,
              barData,
              index, {
              double? barWidth,
              int? spotIndex,
            }) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.blueAccent,
                strokeWidth: 0,
                strokeColor: Colors.transparent,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 10,
    );
    int index = value.toInt();
    if (index < 0 || index >= bestWeightsOnDates.length) {
      return Container();
    }
    DateTime date = bestWeightsOnDates[index].date;
    String formattedDate = "${date.month}/${date.day}";
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      child: Text(formattedDate, style: style),
    );
  }
}


/*
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/cloud_io/firestore_sync.dart';

class CoolChart extends StatefulWidget {
  const CoolChart({super.key});

  @override
  State<CoolChart> createState() => _CoolChartState();
}

class DateAndWeight {
  DateAndWeight(this.date, this.weight);
  DateTime date;
  double weight;
}

class _CoolChartState extends State<CoolChart> {
  List<DateAndWeight> bestWeightsOnDates = [];

  @override
  void initState() async {
    super.initState();
    List<TrainingSession> trainHist = await myStorage.getEntireUserTrainingHistory();
    for (var trainSesh in trainHist) {
      for (var setsOfAnExercise in trainSesh.trainingData) {
        if (setsOfAnExercise.ex.name.contains("deadlift") || setsOfAnExercise.ex.name.contains("Deadlift")) {
          double bestWeight = 0;
          for (var mySet in setsOfAnExercise.sets) {
            bestWeight = max(mySet.weight!, bestWeight).toDouble();
          }
          bestWeightsOnDates.add(DateAndWeight(trainSesh.date, bestWeight));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
*/