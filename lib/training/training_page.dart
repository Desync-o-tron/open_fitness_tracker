import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';
import 'package:open_fitness_tracker/styles.dart';
import 'package:open_fitness_tracker/training/training_data_table.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      // color: Theme.of(context).colorScheme.secondary,
      color: darkTan,
      child: SingleChildScrollView(
        clipBehavior: Clip.none,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TrainingTitle(),
            const DisplayDurationTimer(),
            const NotesWidget(),
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
                        // setState(() {});
                        Navigator.pop(context);
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

class TrainingTitle extends StatelessWidget {
  const TrainingTitle({super.key});
  @override
  Widget build(BuildContext context) {
    var state = context.read<TrainingSessionCubit>().state;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10.0),
      child: TextField(
        style: Theme.of(context).textTheme.headlineSmall,
        controller: TextEditingController(text: state.name.isEmpty ? 'New Training Session' : state.name),
        decoration: const InputDecoration(
            icon: Icon(Icons.edit), border: OutlineInputBorder(borderSide: BorderSide())),
        onChanged: (value) {
          state.name = value;
        },
      ),
    );
  }
}

class DisplayDurationTimer extends StatelessWidget {
  const DisplayDurationTimer({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<TrainingSessionCubit>().state;
    return Text(state.duration.toHoursMinutesSeconds(), style: Theme.of(context).textTheme.bodyMedium);
  }
}

class NotesWidget extends StatelessWidget {
  const NotesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<TrainingSessionCubit>().state;
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: TextEditingController(text: state.notes),
              decoration: const InputDecoration(hintText: "training notes...", icon: Icon(Icons.edit)),
              onChanged: (value) {
                state.notes = value;
              },
            ),
          ),
        ),
      ],
    );
  }
}
