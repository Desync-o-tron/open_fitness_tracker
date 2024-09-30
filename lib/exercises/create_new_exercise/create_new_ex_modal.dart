import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/cloud_io/firestore_sync.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';
import 'package:open_fitness_tracker/exercises/create_new_exercise/muscle_selector.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

class CreateNewExCubit extends HydratedCubit<Exercise> {
  CreateNewExCubit() : super(Exercise(name: '', primaryMuscles: [], equipment: ''));

  void updateExercise(Exercise exercise) {
    emit(Exercise.fromExercise(exercise));
  }

  @override
  Exercise? fromJson(Map<String, dynamic> json) {
    return Exercise.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(Exercise state) {
    return state.toJson();
  }
}

class CreateNewExerciseModal extends StatefulWidget {
  final String? name;
  const CreateNewExerciseModal({super.key, this.name});

  @override
  State<CreateNewExerciseModal> createState() => _CreateNewExerciseModalState();
}

class _CreateNewExerciseModalState extends State<CreateNewExerciseModal>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  // Validation variables
  bool _validate = false;
  final int minNameChars = 3;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _colorAnimation =
        ColorTween(begin: Colors.white, end: Colors.red).animate(_controller);

    // Initialize name if provided
    if (widget.name != null) {
      _nameController.text = widget.name!;
      context
          .read<CreateNewExCubit>()
          .updateExercise(context.read<CreateNewExCubit>().state..name = widget.name!);
    }
  }

  @override
  Widget build(BuildContext context) {
    Exercise newExerciseState = context.watch<CreateNewExCubit>().state;

    return AlertDialog(
      insetPadding: const EdgeInsets.all(15), // Outside Padding
      contentPadding: const EdgeInsets.all(10), // Content Padding
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
                        context.read<CreateNewExCubit>().updateExercise(
                            Exercise.fromExercise(newExerciseState)..name = value);
                      },
                      maxLength: 500,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        errorText: _validate && !_isNameValid(newExerciseState.name)
                            ? _nameErrorText(newExerciseState.name)
                            : null,
                      ),
                    ),
                    MusclesPicker(
                      validate: _validate,
                      musclesAdded: newExerciseState.primaryMuscles,
                      onMuscleAdded: (String muscle) {
                        context.read<CreateNewExCubit>().updateExercise(
                            Exercise.fromExercise(newExerciseState)
                              ..primaryMuscles.addIfDNE(muscle));
                      },
                      onMuscleRemoved: (String muscle) {
                        context.read<CreateNewExCubit>().updateExercise(
                            Exercise.fromExercise(newExerciseState)
                              ..primaryMuscles.remove(muscle));
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
    final exercisesState = context.watch<ExercisesCubit>().state;
    List<String> equipmentList = [];

    if (exercisesState is ExercisesLoaded) {
      equipmentList = exercisesState.equipment;
    }

    List<DropdownMenuEntry<String>> dropdownMenuEntries = [];
    for (String equipment in equipmentList) {
      dropdownMenuEntries.add(DropdownMenuEntry(label: equipment, value: equipment));
    }

    return DropdownMenu<String>(
      expandedInsets: EdgeInsets.zero,
      dropdownMenuEntries: dropdownMenuEntries,
      errorText: _validate &&
              (newExerciseState.equipment == null || newExerciseState.equipment!.isEmpty)
          ? 'Equipment must be selected'
          : null,
      label: const Text('Equipment'),
      onSelected: (String? equipment) {
        if (equipment == null) {
          return;
        }
        context.read<CreateNewExCubit>().updateExercise(
            Exercise.fromExercise(newExerciseState)..equipment = equipment);
      },
    );
  }

  Row cancelAddButtons(BuildContext context, Exercise newExerciseState) {
    return Row(
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
          child: AnimatedBuilder(
            animation: _colorAnimation,
            builder: (context, child) {
              return MyGenericButton(
                label: 'Add',
                onPressed: () async {
                  setState(() {
                    _validate = true;
                  });
                  if (!verifyExercise(newExerciseState)) {
                    _controller.forward();
                    return;
                  }
                  var exercisesCubit = context.read<ExercisesCubit>();
                  await exercisesCubit.addExercisesToGlobalList([newExerciseState]);
                  // // Optionally, reload exercises
                  // await exercisesCubit.loadExercises(useCache: true);
                  if (context.mounted) {
                    Navigator.pop(context); //what me doing
                  }
                },
              );
            },
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  bool verifyExercise(Exercise ex) {
    if (ex.name.isEmpty || ex.name.length < minNameChars) {
      return false;
    }
    if (ex.primaryMuscles.isEmpty) {
      return false;
    }
    final exercisesState = context.read<ExercisesCubit>().state;
    if (exercisesState is ExercisesLoaded) {
      bool nameExists = exercisesState.exercises.any(
        (existingEx) => existingEx.name.toLowerCase() == ex.name.toLowerCase(),
      );
      if (nameExists) {
        return false;
      }
    }
    return true;
  }

  bool _isNameValid(String name) {
    if (name.length < minNameChars) {
      return false;
    }
    final exercisesState = context.read<ExercisesCubit>().state;
    if (exercisesState is ExercisesLoaded) {
      bool nameExists = exercisesState.exercises.any(
        (existingEx) => existingEx.name.toLowerCase() == name.toLowerCase(),
      );
      if (nameExists) {
        return false;
      }
    }
    return true;
  }

  String? _nameErrorText(String name) {
    if (name.length < minNameChars) {
      return 'Name must be at least $minNameChars characters long';
    }
    final exercisesState = context.read<ExercisesCubit>().state;
    if (exercisesState is ExercisesLoaded) {
      bool nameExists = exercisesState.exercises.any(
        (existingEx) => existingEx.name.toLowerCase() == name.toLowerCase(),
      );
      if (nameExists) {
        return 'An exercise with this name already exists';
      }
    }
    return null;
  }
}
