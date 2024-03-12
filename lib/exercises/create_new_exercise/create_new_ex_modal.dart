import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';
import 'package:open_fitness_tracker/exercises/ex_search_cubit.dart';
import 'package:open_fitness_tracker/state.dart';
import 'package:open_fitness_tracker/exercises/create_new_exercise/muscle_selector.dart';

//todo add logic to make sure the ex name does not exist already

class CreateNewExCubit extends Cubit<Exercise> {
  CreateNewExCubit() : super(Exercise(name: '', primaryMuscles: [], equipment: ''));

  void updateExercise(Exercise exercise) {
    emit(Exercise.fromExercise(exercise));
  }
}

class CreateNewExerciseModal extends StatefulWidget {
  final String? name;
  const CreateNewExerciseModal({super.key, this.name});

  @override
  State<CreateNewExerciseModal> createState() => _CreateNewExerciseModalState();
}

class _CreateNewExerciseModalState extends State<CreateNewExerciseModal> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  late AnimationController _controller;
  late Animation _colorAnimation;

  // validation stuff
  bool _validate = false;
  final minNameChars = 3;
  //

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _colorAnimation = ColorTween(begin: Colors.white, end: Colors.red).animate(_controller);
  }

  //todo make sure that when I type in a name in teh search page, it updates the name here
  @override
  Widget build(BuildContext context) {
    Exercise newExerciseState = context.read<CreateNewExCubit>().state;
    return AlertDialog(
      insetPadding: const EdgeInsets.all(15), // Outside Padding
      contentPadding: const EdgeInsets.all(10), // Content Padding
      // backgroundColor: Theme.of(context).colorScheme.secondary,
      title: const Text('Add New Exercise', textAlign: TextAlign.center),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      onChanged: (String value) {
                        context
                            .read<CreateNewExCubit>()
                            .updateExercise(Exercise.fromExercise(newExerciseState)..name = value);
                      },
                      maxLength: 500,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        errorText: _validate && (_nameController.text.length < minNameChars)
                            ? 'Name must be at least $minNameChars characters long'
                            : null,
                      ),
                    ),
                    MusclesPicker(
                      validate: _validate,
                      musclesAdded: context.watch<CreateNewExCubit>().state.primaryMuscles,
                      onMuscleAdded: (String muscle) {
                        context.read<CreateNewExCubit>().updateExercise(
                            Exercise.fromExercise(newExerciseState)..primaryMuscles.insert(0, muscle));
                      },
                      onMuscleRemoved: (String muscle) {
                        context.read<CreateNewExCubit>().updateExercise(
                            Exercise.fromExercise(newExerciseState)..primaryMuscles.remove(muscle));
                      },
                      labelText: 'Primary Muscles',
                    ),
                    const SizedBox(height: 40),
                    equipmentDropdown(context, newExerciseState),
                  ],
                ),
              ),
            ),
            cancelAddButtons(context, newExerciseState),
          ],
        ),
      ),
    );
  }

  Widget equipmentDropdown(BuildContext context, Exercise newExerciseState) {
    List<DropdownMenuEntry<String>> dropdownMenuEntries = [];
    for (String equipment in gExs.equipment) {
      dropdownMenuEntries.add(DropdownMenuEntry(label: equipment, value: equipment));
    }

    return DropdownMenu(
        expandedInsets: EdgeInsets.zero,
        dropdownMenuEntries: dropdownMenuEntries,
        errorText:
            _validate && (newExerciseState.equipment?.isEmpty ?? false) ? 'Equipment must be selected' : null,
        label: const Text('Equipment'),
        onSelected: (String? equipment) {
          if (equipment == null) {
            return;
          }
          context
              .read<CreateNewExCubit>()
              .updateExercise(Exercise.fromExercise(newExerciseState)..equipment = equipment);
        });
  }

  Row cancelAddButtons(BuildContext context, Exercise newExerciseState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: Container()),
        Expanded(
          child: MyGenericButton(
            // shouldFillWidth: false,
            label: 'Cancel',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AnimatedBuilder(
              animation: _colorAnimation,
              builder: (context, child) {
                // ignore: avoid_unnecessary_containers
                return Container(
                  //todo make this cool when you have the time.
                  // color: _validate ? _colorAnimation.value : null,
                  // padding: const EdgeInsets.all(5),
                  child: MyGenericButton(
                    label: 'Add',
                    onPressed: () {
                      setState(() {
                        _validate = true;
                      });
                      if (!verifyExercise(newExerciseState)) {
                        _controller.forward();
                        return;
                      }
                      gExs.addExercises([newExerciseState]);
                      var cubit = context.read<ExSearchCubit>();
                      cubit.updateFilters(); //
                      Navigator.pop(context);
                    },
                  ),
                );
              }),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  bool verifyExercise(Exercise ex) {
    //todo
    if (ex.name.isEmpty || ex.name.length < minNameChars) {
      return false;
    }
    if (ex.primaryMuscles.isEmpty) {
      return false;
    }
    // if (ex.equipment == null || ex.equipment!.isEmpty) {
    //   return false;
    // }

    return true;
  }
}
