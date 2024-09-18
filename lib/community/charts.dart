// ignore_for_file: unnecessary_const

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
    List<TrainingSession> trainHist =
        await myStorage.getEntireUserTrainingHistory(useCache: true);
    trainHist.sort((a, b) => a.date.compareTo(b.date)); //old -> new

    for (var trainSesh in trainHist) {
      for (var setsOfAnExercise in trainSesh.trainingData) {
        if (setsOfAnExercise.ex.name.toLowerCase().contains("deadlift") &&
            !setsOfAnExercise.ex.name.toLowerCase().contains("roma") &&
            !setsOfAnExercise.ex.name.toLowerCase().contains("straight")) {
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
              _buildLineChart(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData _buildLineChart() {
    double maxY = bestWeightsOnDates.map((e) => e.weight).reduce(max) + 20;

    return LineChartData(
      gridData: FlGridData(
        horizontalInterval: 10,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) =>
            FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
        getDrawingVerticalLine: (value) => FlLine(
          color: Colors.grey.withOpacity(0.2),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          axisNameWidget: const Text('Weight (lb)', style: const TextStyle(fontSize: 14)),
          axisNameSize: 18,
          sideTitles: SideTitles(
              showTitles: true,
              interval: 50,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text('${value.toInt()}', style: const TextStyle(fontSize: 12)),
                );
              },
              reservedSize: 40),
        ),
        bottomTitles: AxisTitles(
          axisNameWidget: const Text('Date', style: TextStyle(fontSize: 14)),
          axisNameSize: 18,
          sideTitles: SideTitles(
            showTitles: true,
            interval: 8,
            getTitlesWidget: _bottomDateLabels,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
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
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          // tooltipBgColor: Colors.black87,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((LineBarSpot touchedSpot) {
              // Retrieve the date corresponding to the touched spot
              DateTime date = bestWeightsOnDates[touchedSpot.x.toInt()].date;
              String formattedDate = "${date.year}/${date.month}/${date.day}";
              return LineTooltipItem(
                '${touchedSpot.y} lb\n $formattedDate',
                const TextStyle(color: Colors.white, fontSize: 14),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  static int lastSeshYear = 0;
  Widget _bottomDateLabels(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 12);
    int index = value.toInt();
    if (index < 0 || index >= bestWeightsOnDates.length) {
      return Container();
    }
    DateTime date = bestWeightsOnDates[index].date;
    String formattedDate;

    if (date.year != lastSeshYear) {
      formattedDate = "${date.year.toString().substring(2)}/${date.month}/${date.day}";
    } else {
      formattedDate = "${date.month}/${date.day}";
    }
    lastSeshYear = date.year;
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      child: Text(formattedDate, style: style),
    );
  }
}
