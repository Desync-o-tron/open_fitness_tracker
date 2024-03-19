import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';
import 'package:open_fitness_tracker/styles.dart';
import 'package:open_fitness_tracker/training/training_data_table.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

/*
for future refactoring:
I create a header and table content for each exercise.
Then I pass these into a MakeVisualTable widget which adds margins and spacing. not <i>evil</i> but not great either.
I could have the MakeVisualTable widget take in the exercise and the trainingData and generate the header and table content itself. idk if this is the best way to do it either.
*/
//todo allow the unit to be set in the header of each column? or in settings??

class TrainingPage extends StatelessWidget {
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // // ignore: unused_local_variable

    var state = context.watch<TrainingSessionCubit>().state;
    return Container(
      padding: const EdgeInsets.all(10.0),
      // color: Theme.of(context).colorScheme.secondary,
      color: darkTan,
      child: SingleChildScrollView(
        clipBehavior: Clip.none,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(state.name.isEmpty ? 'New Training Session' : state.name,
                style: Theme.of(context).textTheme.headlineSmall), //todo make these textfields
            Text(state.duration.toHoursMinutesSeconds(), style: Theme.of(context).textTheme.bodyMedium),
            // Timer(duration, () { })
            Text(state.notes ?? 'Notes', style: Theme.of(context).textTheme.bodySmall),
            const DisplayTrainingData(),
            const SizedBox(height: 70),
            Row(
              children: [
                Expanded(child: Container()),
                Expanded(child: MyGenericButton(label: "Cancel", onPressed: () {}, color: darkTan)),
                const SizedBox(width: 20),
                Expanded(
                  child: MyGenericButton(
                      label: "Finish",
                      onPressed: () {
                        //todo check if there are still empty sets
                        final sesh = context.read<TrainingSessionCubit>().state;
                        sesh.isOngoing = false;

                        sesh.duration = DateTime.now().difference(sesh.dateTime);

                        context.read<TrainingHistoryCubit>().addSession(sesh); //saved.
                        context.read<TrainingSessionCubit>().reset();
                        // Navigator.of(context).pop();
                      },
                      color: mediumGreen),
                ),
                Expanded(child: Container()),
              ],
            )
          ],
        ),
      ),
    );
  }
}
