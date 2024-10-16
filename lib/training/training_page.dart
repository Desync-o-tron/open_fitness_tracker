import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/cloud_io/firestore_sync.dart';
import 'package:open_fitness_tracker/navigation/routes.dart';
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
            BottomCancelOrCompleteButtons(
              completeLabel: 'Finish',
              cancelLabel: 'Cancel',
              onCancel: () {
                //todo sesh.hasCompletedSets()
              },
              onComplete: () {
                final sesh = context.read<TrainingSessionCubit>().state;
                if (sesh.hasEmptySets()) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          "You still have empty sets. Casual! Swipe 'em to remove them.")));
                  return;
                }

                sesh.isOngoing = false;
                sesh.duration = DateTime.now().difference(sesh.date);
                sesh.dateOfLastEdit = DateTime.now();
                final histCubit = context.read<TrainingHistoryCubit>();
                if (sesh.trainingData.isNotEmpty) {
                  histCubit.addTrainingSessionToHistory(sesh);
                }
                context.read<TrainingSessionCubit>().reset();
                context.go(routeNames.History.text);
              },
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
    var textController = TextEditingController(
        text: state.name.isEmpty ? 'New Training Session' : state.name);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10.0),
      child: TextField(
        style: Theme.of(context).textTheme.headlineSmall,
        controller: textController,
        decoration: const InputDecoration(
            icon: Icon(Icons.edit), border: OutlineInputBorder(borderSide: BorderSide())),
        onChanged: (value) {
          state.name = value;
        },
        onTap: () => textController.selection =
            TextSelection(baseOffset: 0, extentOffset: textController.text.length),
      ),
    );
  }
}

class DisplayDurationTimer extends StatelessWidget {
  const DisplayDurationTimer({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<TrainingSessionCubit>().state;
    return Text(state.duration.toHoursMinutesSeconds(),
        style: Theme.of(context).textTheme.bodyMedium);
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
              decoration: const InputDecoration(
                  hintText: "training notes...", icon: Icon(Icons.edit)),
              onChanged: (value) {
                // state.notes = value;
                context.read<TrainingSessionCubit>().updateNotes(value);
              },
            ),
          ),
        ),
      ],
    );
  }
}
