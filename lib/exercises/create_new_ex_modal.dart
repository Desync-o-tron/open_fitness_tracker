import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';
import 'package:open_fitness_tracker/exercises/ex_search_cubit.dart';
import 'package:open_fitness_tracker/state.dart';
import 'package:open_fitness_tracker/exercises/muscle_selector.dart';

class CreateNewExCubit extends Cubit<Exercise> {
  CreateNewExCubit() : super(Exercise(name: '', equipment: '', primaryMuscles: []));

  void updateExercise(Exercise exercise) {
    emit(Exercise.fromExercise(exercise));
  }
}

class AddNewExerciseModal extends StatelessWidget {
  final String? name;
  const AddNewExerciseModal({super.key, this.name});

  @override
  Widget build(BuildContext context) {
    Exercise newExercise = context.read<CreateNewExCubit>().state;
    return AlertDialog(
      insetPadding: const EdgeInsets.all(15), // Outside Padding
      contentPadding: const EdgeInsets.all(10), // Content Padding
      // backgroundColor: Theme.of(context).colorScheme.secondary,
      title: const Text('Add New Exercise', textAlign: TextAlign.center),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(children: [
          TextField(
            onChanged: (String value) {
              newExercise.name = value;
            },
            maxLength: 500,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          Expanded(
              child: SearchableMusclesSelectorComplex(
            muscles: context.watch<CreateNewExCubit>().state.primaryMuscles,
            onMuscleAdded: (String muscle) {
              context
                  .read<CreateNewExCubit>()
                  .updateExercise(Exercise.fromExercise(newExercise)..primaryMuscles.insert(0, muscle));
            },
            onMuscleRemoved: (String muscle) {
              context
                  .read<CreateNewExCubit>()
                  .updateExercise(Exercise.fromExercise(newExercise)..primaryMuscles.remove(muscle));
            },
            labelText: 'Primary Muscles',
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Container()),
              Expanded(
                child: MyGenericButton(
                  label: 'Cancel',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MyGenericButton(
                  label: 'Add',
                  onPressed: () {
                    newExercise.name = "aoeuuu";
                    newExercise.equipment = "aoeu";
                    newExercise.primaryMuscles = ["aoeu", "aaaa"];
                    gExs.addExercises([newExercise]);
                    var cubit = context.read<ExSearchCubit>();
                    cubit.updateFilters(); //
                    Navigator.pop(context);
                  },
                ),
              ),
              Expanded(child: Container()),
            ],
          ),
        ]),
      ),
    );
  }
}
