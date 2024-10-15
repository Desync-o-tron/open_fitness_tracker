import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:keyboard_detection/keyboard_detection.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/cloud_io/firestore_sync.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';
import 'package:open_fitness_tracker/exercises/create_new_exercise/create_new_ex_modal.dart';
import 'package:open_fitness_tracker/exercises/ex_tile.dart';
import 'package:open_fitness_tracker/navigation/routes.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

//todo search is pretty bad
//todo on search can we make the buttons dissapear so there'm more screen space?

class ExerciseSearchPage extends StatefulWidget {
  final bool useForAddingToTraining;
  final bool useForMappingForeignExercise;
  final Function? setForeignExerciseCallback;
  final Exercise? foreignEx;

  ExerciseSearchPage({
    super.key,
    this.useForAddingToTraining = false,
    this.useForMappingForeignExercise = false,
    this.setForeignExerciseCallback,
    this.foreignEx,
  }) {
    if (useForMappingForeignExercise) {
      assert(setForeignExerciseCallback != null);
      assert(foreignEx != null);
    }
  }

  @override
  State<ExerciseSearchPage> createState() => _ExerciseSearchPageState();
}

class _ExerciseSearchPageState extends State<ExerciseSearchPage> {
  List<Exercise> selectedExercises = [];
  List<Exercise> newlySelectedExercises = [];

  String keyword = '';
  List<String> musclesFilter = [];
  List<String> categoriesFilter = [];
  late KeyboardDetectionController keyboardDetectionController;
  bool isKeyboardOpen = false;

  @override
  void initState() {
    super.initState();
    if (widget.useForAddingToTraining) {
      var trainingCubit = context.read<TrainingSessionCubit>();
      selectedExercises = trainingCubit.state.trainingData.map((e) => e.ex).toList();
    }
    keyboardDetectionController = KeyboardDetectionController(
      onChanged: (value) {
        print('Keyboard visibility onChanged: $value');
        //TODO can you get this to work?
        setState(() {
          isKeyboardOpen = keyboardDetectionController.stateAsBool(true) ?? false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDetection(
      controller: keyboardDetectionController,
      child: Scaffold(
        body: BlocBuilder<ExercisesCubit, ExercisesState>(
          builder: (context, exercisesState) {
            if (exercisesState is ExercisesLoading ||
                exercisesState is ExercisesInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (exercisesState is ExercisesError) {
              return Center(
                  child: Text('Error loading exercises: ${exercisesState.message}'));
            }
            exercisesState = exercisesState as ExercisesLoaded;
            List<Exercise> filteredExercises = exercisesState.exercises.where((exercise) {
              bool matchesKeyword = keyword.isEmpty ||
                  exercise.name.toLowerCase().contains(keyword.toLowerCase());

              bool matchesMuscles = musclesFilter.isEmpty ||
                  exercise.primaryMuscles
                      .any((muscle) => musclesFilter.contains(muscle)) ||
                  (exercise.secondaryMuscles != null &&
                      exercise.secondaryMuscles!
                          .any((muscle) => musclesFilter.contains(muscle)));

              bool matchesCategories = categoriesFilter.isEmpty ||
                  categoriesFilter.contains(exercise.category);

              return matchesKeyword && matchesMuscles && matchesCategories;
            }).toList();

            final scrollController = ScrollController(initialScrollOffset: 0);

            List<Widget> pageChildren = [];
            if (!widget.useForMappingForeignExercise) {
              pageChildren.add(
                  Text('Exercises', style: Theme.of(context).textTheme.headlineMedium));
            } else {
              pageChildren.add(Text('Exercise Match',
                  style: Theme.of(context).textTheme.headlineSmall));
              pageChildren.add(ExerciseTile(
                exercise: widget.foreignEx!,
                isSelectable: false,
                colorDecoration: true,
              ));
              pageChildren.add(Text('To', style: Theme.of(context).textTheme.bodyMedium));
            }

            if (!isKeyboardOpen) {
              pageChildren.addAll([
                _exListView(scrollController, filteredExercises),
                SearchBar(
                  onKeywordChanged: (value) {
                    setState(() {
                      keyword = value;
                    });
                  },
                ),
                _muscleAndCategoryFilterButtons(context, exercisesState),
              ]);

              if (widget.useForAddingToTraining) {
                pageChildren.add(_addSelectedButton(context));
              }
              if (widget.useForMappingForeignExercise) {
                pageChildren.addAll([
                  _thisIsMyExButton(widget.setForeignExerciseCallback!),
                  _noExerciseMatchButton(widget.setForeignExerciseCallback!),
                ]);
              } else {
                pageChildren.add(_createNewExButton(context));
              }
            }
            return SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: pageChildren,
              ),
            );
          },
        ),
      ),
    );
  }

  Padding _muscleAndCategoryFilterButtons(
      BuildContext context, ExercisesLoaded exercisesState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 2, 5, 11),
      child: Row(
        children: [
          Expanded(
            child: MyGenericButton(
              label: musclesFilter.isEmpty
                  ? 'Any Muscle'
                  : musclesFilter.map((e) => e.capTheFirstLetter()).join(", "),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SearchMultiSelectModal(
                      isForMuscleSelection: true,
                      allItems: exercisesState.muscles,
                      selectedItems: musclesFilter,
                      onSelectionChanged: (selectedMuscles) {
                        setState(() {
                          musclesFilter = selectedMuscles;
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: MyGenericButton(
              label: categoriesFilter.isEmpty
                  ? 'Any Category'
                  : categoriesFilter.map((e) => e.capTheFirstLetter()).join(", "),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SearchMultiSelectModal(
                      isForMuscleSelection: false,
                      allItems: exercisesState.categories,
                      selectedItems: categoriesFilter,
                      onSelectionChanged: (selectedCategories) {
                        setState(() {
                          categoriesFilter = selectedCategories;
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _exListView(
      ScrollController scrollController, List<Exercise> filteredExercises) {
    return Expanded(
      child: ScrollConfiguration(
        behavior: GenericScrollBehavior(),
        child: Scrollbar(
          controller: scrollController,
          thumbVisibility: true,
          child: ListView.builder(
            controller: scrollController,
            key: ValueKey(filteredExercises.length),
            itemCount: filteredExercises.length,
            itemBuilder: (context, index) {
              return Material(
                child: ExerciseTile(
                  exercise: filteredExercises[index],
                  isSelectable: widget.useForAddingToTraining ||
                      widget.useForMappingForeignExercise,
                  isSelected: selectedExercises.contains(filteredExercises[index]) ||
                      newlySelectedExercises.contains(filteredExercises[index]),
                  onSelectionChanged: (bool isSelected) {
                    setState(() {
                      if (isSelected) {
                        if (widget.useForMappingForeignExercise) {
                          newlySelectedExercises.clear();
                        }
                        newlySelectedExercises.add(filteredExercises[index]);
                      } else {
                        newlySelectedExercises.remove(filteredExercises[index]);
                      }
                    });
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Padding _createNewExButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 6),
      child: MyGenericButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const CreateNewExerciseModal();
            },
          );
        },
        label: 'Create New Exercise',
      ),
    );
  }

  Padding _addSelectedButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: MyGenericButton(
        label: "Add Selected - ${newlySelectedExercises.length}",
        color: Theme.of(context).colorScheme.primary,
        onPressed: () {
          var trainingCubit = context.read<TrainingSessionCubit>();
          for (var ex in newlySelectedExercises) {
            trainingCubit.addExercise(ex);
          }
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _thisIsMyExButton(Function setForeignExerciseCallback) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: MyGenericButton(
        label: "This Is My Exercise",
        color: Theme.of(context).colorScheme.primary,
        onPressed: () {
          if (newlySelectedExercises.isEmpty) return;
          setForeignExerciseCallback(newlySelectedExercises.first);
          context.pop();
        },
      ),
    );
  }

  Widget _noExerciseMatchButton(Function setForeignExerciseCallback) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: MyGenericButton(
        label: "None of these exercises match mine",
        color: Theme.of(context).colorScheme.primary,
        onPressed: () {
          setForeignExerciseCallback(null); // Passing null to indicate no match
          appRouter.pop();
        },
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  final ValueChanged<String> onKeywordChanged;

  const SearchBar({super.key, required this.onKeywordChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        onChanged: onKeywordChanged,
        decoration: const InputDecoration(
          icon: Icon(Icons.search),
          hintText: 'Search',
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class SearchMultiSelectModal extends StatefulWidget {
  final bool isForMuscleSelection;
  final List<String> allItems;
  final List<String> selectedItems;
  final ValueChanged<List<String>> onSelectionChanged;

  const SearchMultiSelectModal({
    super.key,
    required this.isForMuscleSelection,
    required this.allItems,
    required this.selectedItems,
    required this.onSelectionChanged,
  });

  @override
  _SearchMultiSelectModalState createState() => _SearchMultiSelectModalState();
}

class _SearchMultiSelectModalState extends State<SearchMultiSelectModal> {
  late List<String> tempSelectedItems;

  @override
  void initState() {
    super.initState();
    tempSelectedItems = List.from(widget.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select ${widget.isForMuscleSelection ? 'Muscles' : 'Categories'}'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.allItems.length,
          itemBuilder: (context, index) {
            final item = widget.allItems[index];
            return CheckboxListTile(
              value: tempSelectedItems.contains(item),
              title: Text(item),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    if (!tempSelectedItems.contains(item)) {
                      tempSelectedItems.add(item);
                    }
                  } else {
                    tempSelectedItems.remove(item);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onSelectionChanged(tempSelectedItems);
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
