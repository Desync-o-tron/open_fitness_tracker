import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';
import 'package:open_fitness_tracker/exercises/ex_tile.dart';
import 'package:open_fitness_tracker/state.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

class ExSearchState {
  List<Exercise> filteredExercises = gExs.exercises;
  List<String> categoriesFilter = [];
  List<String> musclesFilter = [];
  String enteredKeyword = '';

  ExSearchState([ExSearchState? state]) {
    if (state != null) {
      filteredExercises = state.filteredExercises;
      categoriesFilter = state.categoriesFilter;
      musclesFilter = state.musclesFilter;
      enteredKeyword = state.enteredKeyword;
    }
  }

  /// Every time we're going to update we re-apply every filter. not the most efficient but it's fine for now
  ExSearchState copyWithNewFilters(
      {List<String>? categoriesFilter, List<String>? musclesFilter, String? enteredKeyword}) {
    ExSearchState newState = ExSearchState(this);
    newState.filteredExercises = gExs.exercises;
    newState.categoriesFilter = categoriesFilter ?? newState.categoriesFilter;
    newState.musclesFilter = musclesFilter ?? newState.musclesFilter;
    newState.enteredKeyword = enteredKeyword ?? newState.enteredKeyword;

    // filter by muscles
    List<Exercise> tempExs = [];
    for (String muscle in newState.musclesFilter) {
      for (var e in newState.filteredExercises) {
        if (e.primaryMuscles.contains(muscle) ||
            (e.secondaryMuscles != null && e.secondaryMuscles!.contains(muscle))) {
          tempExs.add(e);
        }
      }
    }
    if (tempExs.isNotEmpty) {
      newState.filteredExercises = tempExs;
    }

    for (String category in newState.categoriesFilter) {
      newState.filteredExercises = newState.filteredExercises.where((e) => e.category == category).toList();
    }

    // filter by keyword
    if (newState.enteredKeyword.isNotEmpty) {
      var fuseForNames = Fuzzy(gExs.names, options: FuzzyOptions(findAllMatches: true, threshold: 0.25));
      var resultsByName = fuseForNames.search(newState.enteredKeyword);
      var matchedNames = resultsByName.map((r) => r.item as String).toSet();
      var fuseForMuscles = Fuzzy(gExs.muscles, options: FuzzyOptions(findAllMatches: true, threshold: 0.25));
      var resultsByMuscles = fuseForMuscles.search(newState.enteredKeyword);
      var matchedMuscles = resultsByMuscles.map((r) => r.item as String).toSet();
      tempExs = [];
      for (var e in newState.filteredExercises) {
        if (matchedNames.contains(e.name)) {
          tempExs.addIfDNE(e);
        }
        if (e.primaryMuscles.any((m) => matchedMuscles.contains(m))) {
          tempExs.addIfDNE(e);
        }
      }
      newState.filteredExercises = tempExs;
    }

    return newState;
  }
}

class ExSearchCubit extends Cubit<ExSearchState> {
  ExSearchCubit() : super(ExSearchState());

  void updateFilters({List<String>? categories, List<String>? muscles, String? keyword}) {
    emit(state.copyWithNewFilters(
      categoriesFilter: categories ?? state.categoriesFilter,
      musclesFilter: muscles ?? state.musclesFilter,
      enteredKeyword: keyword ?? state.enteredKeyword,
    ));
  }
}

class ExercisesPage extends StatelessWidget {
  const ExercisesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    return Container(
      // color: Theme.of(context).colorScheme.secondary,
      child: BlocBuilder<ExSearchCubit, ExSearchState>(builder: (context, state) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Exercises',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              Expanded(
                //todo scrolling on web is not great. I want to use click & drag. + using slider is janky.
                child: ListView.builder(
                  key: ValueKey(state.filteredExercises.length),
                  itemCount: state.filteredExercises.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 5, right: 6, left: 6),
                      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
                      child: ExerciseTile(exercise: state.filteredExercises[index]),
                    );
                  },
                ),
              ),
              const SearchBar(),
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 2, 5, 11),
                child: Row(
                  children: [
                    Expanded(
                      child: FilterButton(
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
                      child: FilterButton(
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
            ],
          ),
        );
      }),
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
          // cubit.updateEnteredKeyword(value);
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
