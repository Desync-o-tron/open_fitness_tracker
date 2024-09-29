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

class _CoolChartState extends State<CoolChart> {
  List<DateAndWeight> bestWeightsOnDates = [];
  List<double> xValues = [];
  DateTime? firstDate;

  double? _slope;
  double? _intercept;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    // Await the future to get the list of training sessions
    List<TrainingSession>? trainHist = await TrainHistoryDB.trainingHistory;

    if (trainHist == null || trainHist.isEmpty) {
      setState(() {}); // Trigger build to show empty state
      return;
    }

    for (var trainSesh in trainHist) {
      for (var setsOfAnExercise in trainSesh.trainingData) {
        if (setsOfAnExercise.ex.name.toLowerCase().contains("deadlift") &&
            !setsOfAnExercise.ex.name.toLowerCase().contains("roma") &&
            !setsOfAnExercise.ex.name.toLowerCase().contains("straight")) {
          double bestWeight = 0;
          for (var mySet in setsOfAnExercise.sets) {
            if (mySet.weight != null) {
              bestWeight = max(mySet.weight!, bestWeight).toDouble();
            }
          }
          if (bestWeight > 0) {
            bestWeightsOnDates.add(DateAndWeight(trainSesh.date, bestWeight));
          }
        }
      }
    }

    if (bestWeightsOnDates.isEmpty) {
      setState(() {}); // Trigger build to show empty state
      return;
    }

    bestWeightsOnDates.sort((a, b) => a.date.compareTo(b.date));

    firstDate = bestWeightsOnDates.first.date;
    // Convert dates to numerical x-values (days since first date)
    xValues = bestWeightsOnDates
        .map((e) => e.date.difference(firstDate!).inDays.toDouble())
        .toList();

    // Calculate the best fit line
    _calculateBestFitLine();

    setState(() {}); // Trigger build to display the chart
  }

  @override
  Widget build(BuildContext context) {
    if (bestWeightsOnDates.isEmpty) {
      return const Center(child: Text('No data available'));
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
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: LineChart(
                  _buildLineChart(),
                ),
              ),
              // Display the equation of the best fit line
              if (_slope != null && _intercept != null)
                Positioned(
                  bottom: 55,
                  right: 16,
                  child: Container(
                    color: Colors.white.withOpacity(0.3),
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      'Best fit line: weight(days) = ${_slope!.toStringAsFixed(2)} * days + ${_intercept!.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  LineChartData _buildLineChart() {
    double maxY = bestWeightsOnDates.map((e) => e.weight).reduce(max) + 30;

    // Calculate dynamic intervals for X-axis labels
    double minX = 0;
    double maxX = bestWeightsOnDates.length.toDouble() - 1;

    // Generate spots for the main data line
    List<FlSpot> dataSpots = bestWeightsOnDates.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weight);
    }).toList();

    // Spots for the best fit line
    List<FlSpot> bestFitLineSpots = _getBestFitLineSpots();

    return LineChartData(
      gridData: FlGridData(
        horizontalInterval: 10,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) =>
            FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
        getDrawingVerticalLine: (value) =>
            FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          axisNameWidget: const Text('Weight (lb)', style: TextStyle(fontSize: 14)),
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
            reservedSize: 40,
          ),
        ),
        bottomTitles: AxisTitles(
          axisNameWidget: const Text('Sessions', style: TextStyle(fontSize: 14)),
          axisNameSize: 18,
          sideTitles: SideTitles(
            showTitles: true,
            interval: 5,
            getTitlesWidget: _sessionLabels,
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
      ),
      minX: minX,
      maxX: maxX,
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: dataSpots,
          isCurved: true,
          color: Colors.blueAccent,
          barWidth: 4,
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.blueAccent.withOpacity(0.5),
                Colors.blueAccent.withOpacity(0.02),
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
        // Best Fit Line
        if (bestFitLineSpots.isNotEmpty)
          LineChartBarData(
            spots: bestFitLineSpots,
            isCurved: false,
            color: Colors.redAccent,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
          ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots
                .map((LineBarSpot touchedSpot) {
                  // Retrieve the date corresponding to the touched spot
                  int index = touchedSpot.x.toInt();
                  if (index < 0 || index >= bestWeightsOnDates.length) {
                    return null;
                  }
                  DateTime date = bestWeightsOnDates[index].date;
                  String formattedDate = "${date.year}/${date.month}/${date.day}";
                  return LineTooltipItem(
                    '${touchedSpot.y.toStringAsFixed(1)} lb\n$formattedDate',
                    const TextStyle(color: Colors.white, fontSize: 14),
                  );
                })
                .whereType<LineTooltipItem>()
                .toList();
          },
        ),
      ),
    );
  }

  void _calculateBestFitLine() {
    int n = xValues.length;
    if (n == 0) return;

    List<double> yValues = bestWeightsOnDates.map((e) => e.weight).toList();

    // Calculate sums
    double sumX = xValues.reduce((a, b) => a + b);
    double sumY = yValues.reduce((a, b) => a + b);
    double sumXY = 0;
    double sumX2 = 0;

    for (int i = 0; i < n; i++) {
      sumXY += xValues[i] * yValues[i];
      sumX2 += xValues[i] * xValues[i];
    }

    // Calculate slope (m) and intercept (b) for y = mx + b
    double denominator = (n * sumX2 - sumX * sumX);
    if (denominator == 0) return; // Prevent division by zero

    _slope = (n * sumXY - sumX * sumY) / denominator;
    _intercept = (sumY - _slope! * sumX) / n;
  }

  List<FlSpot> _getBestFitLineSpots() {
    if (_slope == null || _intercept == null) return [];

    double xStart = xValues.first;
    double xEnd = xValues.last;

    double yStart = _slope! * xStart + _intercept!;
    double yEnd = _slope! * xEnd + _intercept!;

    return [
      FlSpot(0, yStart),
      FlSpot(xValues.length.toDouble() - 1, yEnd),
    ];
  }

  Widget _sessionLabels(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 12);
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

class DateAndWeight {
  DateAndWeight(this.date, this.weight);
  DateTime date;
  double weight;
}
