import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    var history = context.read<TrainingHistoryCubit>().state;
    return Column(
      children: [
        Text(
          'History',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        Expanded(
            child: ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            return TrainingSessionCard(session: history[index]);
          },
        )),
      ],
    );
  }
}

class TrainingSessionCard extends StatelessWidget {
  final TrainingSession session;
  const TrainingSessionCard({required this.session, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Date: ${DateFormat.yMMMMEEEEd().format(session.date)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'Duration: ${session.duration.toHoursMinutes()}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: session.trainingData.length,
              itemBuilder: (context, index) {
                final SetsOfAnExercise sets = session.trainingData[index];
                return Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        sets.ex.name,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: sets.sets.length,
                        itemBuilder: (context, index) {
                          final Set set = sets.sets[index];
                          return Text(
                            'Set ${index + 1}: ${set.reps} reps at ${set.weight} lbs',
                            style: Theme.of(context).textTheme.titleSmall,
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
