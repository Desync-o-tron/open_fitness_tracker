import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';
import 'package:open_fitness_tracker/exercises/ex_search_cubit.dart';
import 'package:open_fitness_tracker/state.dart';
import 'package:open_fitness_tracker/exercises/muscle_selector.dart';

//I have some state like:

class SimpleState {
  SimpleState() {
    firstList = ["a", "b", "c"];
    secondList = ["d", "e", "f"];
  }
  SimpleState factory(SimpleState state) {
    firstList = List.of(state.firstList);
    secondList = List.of(state.secondList);
    return this;
  }

  List<String> firstList = ["a", "b", "c"];
  List<String> secondList = ["d", "e", "f"];
}

//and the cubit:

class SimpleStateCubit extends Cubit<SimpleState> {
  SimpleStateCubit() : super(SimpleState());
  updateState(SimpleState newState) {
    emit(newState);
  }
}

// I have a widget that shows and edits one of the Lists:

class ShowAndEditList extends StatelessWidget {
  final List<String> list;
  final Null Function(String str) onPressed;
  const ShowAndEditList({super.key, required this.list, required this.onPressed});
  @override
  Widget build(context) {
    // var firstListCopy = List.of(list);
    // var state = context.watch<SimpleStateCubit>().state;
    // var list = state.firstList;
    List<Widget> buttons = [];
    for (var str in list) {
      buttons.add(ElevatedButton(
        onPressed: () => onPressed(str),
        child: Text(str),
      ));
    }

    return Column(
      children: [...buttons, Container(height: 10, width: 10, color: Colors.red)],
    );
  }
}

// -> the problem is I cannot reuse this widget for the second list. Because the logic to display and remove is hardcoded to the widget.
// how can I read and write generic lists in my cubit? it would be nice if I could just update a watched state in the cubit and the widget would update automatically.

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
    // var newExercise = Exercise(
    //   name: name ?? '',
    //   equipment: '',
    //   primaryMuscles: [],
    // );
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
          Expanded(child: SearchableDropdown()),
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
