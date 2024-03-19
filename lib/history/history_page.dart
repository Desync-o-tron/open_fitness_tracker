import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
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
        Expanded(
          child: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              return TrainingSessionCard(session: history[index]);
            },
          ),
        ),
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
            if (session.name.isNotEmpty)
              Text(
                session.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            Text(
              DateFormat.yMMMMEEEEd().format(session.dateTime),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              'Duration: ${session.duration.toHoursMinutes()}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            ListView.builder(
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
            ),
          ],
        ),
      ),
    );
  }
}
