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
  List<double> xValues = []; //
  late DateTime firstDate;

  late double _slope;
  late double _intercept;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    List<TrainingSession> trainHist =
        await cloudStorage.trainHistoryDB.getEntireUserTrainingHistory(useCache: true);
    if (trainHist.isEmpty) return;

    for (var trainSesh in trainHist) {
      for (var setsOfAnExercise in trainSesh.trainingData) {
        if (setsOfAnExercise.ex.name.toLowerCase().contains("deadlift") &&
            !setsOfAnExercise.ex.name.toLowerCase().contains("roma") &&
            !setsOfAnExercise.ex.name.toLowerCase().contains("straight")) {
          double bestWeight = 0;
          for (var mySet in setsOfAnExercise.sets) {
            bestWeight = max(mySet.weight!, bestWeight).toDouble();
          }
          if (bestWeight > 0) {
            bestWeightsOnDates.add(DateAndWeight(trainSesh.date, bestWeight));
          }
        }
      }
    }
    bestWeightsOnDates.sort((a, b) => a.date.compareTo(b.date));

    firstDate = bestWeightsOnDates.first.date;
    // Convert dates to numerical x-values (days since first date)
    xValues = bestWeightsOnDates
        .map((e) => e.date.difference(firstDate).inDays.toDouble())
        .toList();

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
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: LineChart(
                  _buildLineChart(),
                ),
              ),
              // Display the equation of the best fit line
              Positioned(
                bottom: 55,
                right: 16,
                child: Container(
                  color: Colors.white.withOpacity(0.3),
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    'line of best fit: lbs(days) = ${_slope.toStringAsFixed(2)}*days + ${_intercept.toStringAsFixed(0)}lbs',
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
    double minX = xValues.first;
    double maxX = xValues.last;

    int desiredLabelCount = 5; // Adjust this number based on your preference
    double intervalX = (maxX - minX) / (desiredLabelCount - 1);
    if (intervalX <= 0) intervalX = 1;

    // Calculate the best fit line
    List<FlSpot> bestFitLineSpots = _calculateBestFitLine();

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
              reservedSize: 40),
        ),
        topTitles: AxisTitles(
          axisNameWidget: const Text('Date', style: TextStyle(fontSize: 14)),
          axisNameSize: 18,
          sideTitles: SideTitles(
            showTitles: true,
            interval: 8,
            getTitlesWidget: _dateLabels,
          ),
        ),
        bottomTitles: AxisTitles(
          axisNameWidget: const Text('Days', style: TextStyle(fontSize: 14)),
          axisNameSize: 18,
          sideTitles:
              SideTitles(showTitles: true, interval: 5, getTitlesWidget: _daysLabels),
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

  List<FlSpot> _calculateBestFitLine() {
    int n = xValues.length;
    if (n == 0) return [];

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
    if (denominator == 0) return []; // Prevent division by zero

    _slope = (n * sumXY - sumX * sumY) / denominator;
    _intercept = (sumY - _slope * sumX) / n;

    // Generate two points for the best fit line (start and end)
    // double x0 = xValues.first;
    double x0 = 0;
    double y0 = _slope * xValues.first + _intercept;
    double x1 = xValues.length.toDouble() - 1;
    double y1 = _slope * xValues.last + _intercept;

    return [
      FlSpot(x0, y0),
      FlSpot(x1, y1),
    ];
  }

  static int lastSeshYear = 0;
  Widget _dateLabels(double value, TitleMeta meta) {
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

  Widget _daysLabels(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 12);
    int index = value.toInt();
    if (index < 0 || index >= bestWeightsOnDates.length) {
      return Container();
    }
    DateTime currDate = bestWeightsOnDates[index].date;
    int day = currDate.difference(firstDate).inDays;
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      child: Text(day.toString(), style: style),
    );
  }
}

class DateAndWeight {
  DateAndWeight(this.date, this.weight);
  DateTime date;
  double weight;
}
