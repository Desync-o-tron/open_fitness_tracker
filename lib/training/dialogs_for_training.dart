import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';

class ExManagementDialog extends StatelessWidget {
  final SetsOfAnExercise es;
  const ExManagementDialog(this.es, {super.key});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(es.ex.name),
      content: SizedBox(
        height: 499,
        child: Column(
          children: [
            MyGenericButton(
              label: "Delete",
              onPressed: () {
                context.read<TrainingSessionCubit>().removeExercise(es.ex);
                Navigator.of(context).pop();
              },
              color: Theme.of(context).colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }
}
