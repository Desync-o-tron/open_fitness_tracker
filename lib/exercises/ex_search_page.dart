import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';
import 'package:open_fitness_tracker/exercises/create_new_exercise/create_new_ex_modal.dart';
import 'package:open_fitness_tracker/state.dart';
import 'package:open_fitness_tracker/exercises/ex_search_cubit.dart' show ExSearchCubit, ExSearchState;
import 'package:open_fitness_tracker/exercises/ex_tile.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

class ExerciseSearchPage extends StatefulWidget {
  final bool useForAddingToTraining;
  const ExerciseSearchPage({super.key, this.useForAddingToTraining = false});

  @override
  State<ExerciseSearchPage> createState() => _ExerciseSearchPageState();
}

class _ExerciseSearchPageState extends State<ExerciseSearchPage> {
  List<Exercise> selectedExercises = [];
  List<Exercise> newlySelectedExercises = [];

  @override
  void initState() {
    super.initState();
    if (widget.useForAddingToTraining) {
      var trainingsesh = context.read<TrainingSessionCubit>();
      selectedExercises = trainingsesh.state.trainingData.map((e) => e.ex).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController(initialScrollOffset: 0);
    final state = context.watch<ExSearchCubit>().state;
    // ignore: avoid_unnecessary_containers
    return Container(
      // color: Theme.of(context).colorScheme.secondary,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Exercises',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          //todo scrolling on web is not perfect.using slider is a bit janky.
          Expanded(
            child: ScrollConfiguration(
              behavior: GenericScrollBehavior(),
              child: Scrollbar(
                controller: scrollController,
                thumbVisibility: true,
                child: ListView.builder(
                    controller: scrollController,
                    key: ValueKey(state.filteredExercises.length),
                    itemCount: state.filteredExercises.length,
                    itemBuilder: (context, index) {
                      return ExerciseTile(
                          exercise: state.filteredExercises[index],
                          isSelectable: widget.useForAddingToTraining,
                          isSelected: selectedExercises.contains(state.filteredExercises[index]) ||
                              newlySelectedExercises.contains(state.filteredExercises[index]),
                          onSelectionChanged: (bool isSelected) {
                            if (isSelected) {
                              newlySelectedExercises.add(state.filteredExercises[index]);
                            } else {
                              newlySelectedExercises.remove(state.filteredExercises[index]);
                            }
                            setState(() {});
                          });
                    }),
              ),
            ),
          ),
          if (widget.useForAddingToTraining)
            Padding(
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
            ),
          const SearchBar(),
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 2, 5, 11),
            child: Row(
              children: [
                Expanded(
                  child: MyGenericButton(
                    label: state.musclesFilter.isEmpty
                        ? 'Any Muscle'
                        : state.musclesFilter.map((e) => e.capTheFirstLetter()).join(", "),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const SearchMultiSelectModal(isForMuscleSelection: true);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: MyGenericButton(
                    label: state.categoriesFilter.isEmpty
                        ? 'Any Category'
                        : state.categoriesFilter.map((e) => e.capTheFirstLetter()).join(", "),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const SearchMultiSelectModal(isForMuscleSelection: false);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
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
          ),
        ],
      ),
    );
  }
}

class SearchMultiSelectModal extends StatelessWidget {
  final bool isForMuscleSelection;
  const SearchMultiSelectModal({super.key, this.isForMuscleSelection = true});

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (isForMuscleSelection) {
      content = BlocBuilder<ExSearchCubit, ExSearchState>(
        builder: (context, state) {
          return SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: gExs.muscles.length,
              itemBuilder: (context, index) {
                final item = gExs.muscles[index];
                return CheckboxListTile(
                  value: state.musclesFilter.contains(item),
                  title: Text(item),
                  onChanged: (bool? value) {
                    var cubit = context.read<ExSearchCubit>();
                    var musclesFilter = cubit.state.musclesFilter.toList();
                    if (value == true) {
                      musclesFilter.addIfDNE(item);
                    } else {
                      musclesFilter.remove(item);
                    }
                    cubit.updateFilters(muscles: musclesFilter);
                  },
                );
              },
            ),
          );
        },
      );
    } else {
      //for categories
      content = BlocBuilder<ExSearchCubit, ExSearchState>(
        builder: (context, state) {
          return SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: gExs.categories.length,
              itemBuilder: (context, index) {
                final item = gExs.categories[index];
                return CheckboxListTile(
                  value: state.categoriesFilter.contains(item),
                  title: Text(item),
                  onChanged: (bool? value) {
                    var cubit = context.read<ExSearchCubit>();
                    var categoriesFilter = cubit.state.categoriesFilter.toList();
                    if (value == true) {
                      categoriesFilter.addIfDNE(item);
                    } else {
                      categoriesFilter.remove(item);
                    }
                    cubit.updateFilters(categories: categoriesFilter);
                  },
                );
              },
            ),
          );
        },
      );
    }
    return AlertDialog(
      title: const Text('Select Items'),
      content: content,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SearchBarState createState() => _SearchBarState();
}

//info I've been enountering bugs in the windows version of the app.
// I sometimes cannot backspace (check the debug output)
// also it sometimes only handles a keypress every .5 seconds or so.
class _SearchBarState extends State<SearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final cubit = BlocProvider.of<ExSearchCubit>(context, listen: false);
    _controller.text = cubit.state.enteredKeyword;
  }

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
        controller: _controller,
        onChanged: (String value) {
          final cubit = BlocProvider.of<ExSearchCubit>(context);
          cubit.updateFilters(keyword: value);
        },
        decoration: const InputDecoration(
          icon: Icon(Icons.search),
          hintText: 'Search',
          border: InputBorder.none,
        ),
      ),
    );
  }
}
