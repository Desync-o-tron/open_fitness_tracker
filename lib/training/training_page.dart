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
            // Text(state.notes ?? 'Notes', style: Theme.of(context).textTheme.bodySmall),
            const TrainingDataDisplay(),
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

class TrainingTitle extends StatelessWidget {
  const TrainingTitle({super.key});
  @override
  Widget build(BuildContext context) {
    var state = context.watch<TrainingSessionCubit>().state;
    return Text(state.name.isEmpty ? 'New Training Session' : state.name,
        style: Theme.of(context).textTheme.headlineSmall);
  } //todo make these textfields
}

class DisplayDurationTimer extends StatelessWidget {
  const DisplayDurationTimer({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<TrainingSessionCubit>().state;
    return Text(state.duration.toHoursMinutesSeconds(), style: Theme.of(context).textTheme.bodyMedium);
  }
}

//todo this is shit
class NotesWidget extends StatefulWidget {
  const NotesWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotesWidgetState createState() => _NotesWidgetState();
}

class _NotesWidgetState extends State<NotesWidget> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            enabled: _isEditing,
          ),
        ),
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            setState(() {
              _isEditing = !_isEditing;
            });
          },
        ),
      ],
    );
  }
}
