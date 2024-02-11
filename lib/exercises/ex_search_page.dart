import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  ExSearchState fromFilters(
      {List<String>? categoriesFilter, List<String>? musclesFilter, String? enteredKeyword}) {
    filteredExercises = gExs.exercises;
    this.categoriesFilter = categoriesFilter ?? this.categoriesFilter;
    this.musclesFilter = musclesFilter ?? this.musclesFilter;
    this.enteredKeyword = enteredKeyword ?? this.enteredKeyword;
    List<Exercise> newFilteredExercises = [];

    // filter by muscles
    for (String muscle in this.musclesFilter) {
      for (var e in filteredExercises) {
        if (e.primaryMuscles.contains(muscle)) {
          newFilteredExercises.addIfDNE(e);
        }
      }
      for (var e in filteredExercises) {
        if (e.secondaryMuscles != null && e.secondaryMuscles!.contains(muscle)) {
          newFilteredExercises.addIfDNE(e);
        }
      }
      // filteredExercises
      //     .addAllIfDNE(filteredExercises.where((e) => e.secondaryMuscles?.contains(muscle)).toList());
      //TODO^
    }
    // filter by categories
    //TODO

    // filter by keyword
    // if (enteredKeyword.isNotEmpty) {
    //   var fuse = Fuzzy(gExs.names, options: FuzzyOptions(findAllMatches: true, threshold: 0.6));
    //   var results = fuse.search(enteredKeyword);
    //   var matchedNames = results.map((r) => r.item as String).toSet();
    //   filteredExercises = filteredExercises.where((e) => matchedNames.contains(e.name)).toList();
    // }
    filteredExercises = newFilteredExercises;
    if (filteredExercises.isEmpty) {
      filteredExercises = gExs.exercises;
    }
    return this;
  }
}

class ExSearchCubit extends Cubit<ExSearchState> {
  ExSearchCubit() : super(ExSearchState());

  void updateCategoriesFilter(List<String> categories) {
    // state.categoriesFilter = categories;
    // _applyFilters();
    emit(ExSearchState().fromFilters(categoriesFilter: categories));
  }

  void updateMusclesFilter(List<String> muscles) {
    emit(ExSearchState().fromFilters(musclesFilter: muscles));
  }

  void updateEnteredKeyword(String keyword) {
    emit(ExSearchState().fromFilters(enteredKeyword: keyword));
  }
}

class ExercisesPage extends StatelessWidget {
  const ExercisesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExSearchCubit(),
      child: Container(
        color: Theme.of(context).colorScheme.secondary,
        child: BlocBuilder<ExSearchCubit, ExSearchState>(builder: (context, state) {
          if (state.filteredExercises.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Exercises',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                Expanded(
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
                // _searchBox(ref),
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
                              builder: (BuildContext _) {
                                // return myModal(context);
                                return MultiSelectModal(uppercontext: context);
                                // return MultiSelectModal(cubit: BlocProvider.of<ExSearchCubit>(context));
                                // return MultiSelectModal(cubit: BlocProvider.of<ExSearchCubit>(context));
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      // Expanded(
                      //   child: FilterButton(
                      //     label: categoriesFilter.isEmpty
                      //         ? 'Any Category'
                      //         : categoriesFilter.map((e) => e.capTheFirstLetter()).join(", "),
                      //     onPressed: () {},
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

myModal(context) => BlocBuilder<ExSearchCubit, ExSearchState>(builder: (uppercontext, state) {
      return AlertDialog(
        title: const Text('Select Items'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: gExs.muscles.length,
            // itemCount: allItems.length,
            itemBuilder: (context, index) {
              final item = gExs.muscles[index];
              return CheckboxListTile(
                value: state.musclesFilter.contains(item),
                // value: false,
                title: Text(item),
                onChanged: (bool? value) {
                  if (value == true) {
                    state.musclesFilter.add(item);
                  } else {
                    state.musclesFilter.remove(item);
                  }
                  // cubit.updateMusclesFilter(state.musclesFilter);
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
              // selectedItems.clear();
              // selectedItems.addAll(tempSelectedItems);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      );
    });

class MultiSelectModal extends StatelessWidget {
  // const MultiSelectModal({super.key});
  final BuildContext uppercontext;
  const MultiSelectModal({super.key, required this.uppercontext});
  // final ExSearchCubit cubit;
  // const MultiSelectModal({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<ExSearchCubit>(this.uppercontext);
    var state = cubit.state;
    return AlertDialog(
      title: const Text('Select Items'),
      content: Container(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: gExs.muscles.length,
          itemBuilder: (context, index) {
            final item = gExs.muscles[index];
            return CheckboxListTile(
              // value: state.musclesFilter.contains(item),
              value: uppercontext.watch<ExSearchCubit>().state.musclesFilter.contains(item),
              // value:
              // value: false,
              title: Text(item),
              onChanged: (bool? value) {
                if (value == true) {
                  state.musclesFilter.add(item);
                } else {
                  state.musclesFilter.remove(item);
                }
                cubit.updateMusclesFilter(state.musclesFilter);
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
            // selectedItems.clear();
            // selectedItems.addAll(tempSelectedItems);
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    );
    //   },
    // );
  }
}


  // Container _searchBox(WidgetRef ref) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 10),
  //     margin: const EdgeInsets.all(10),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(30),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withOpacity(0.5),
  //           spreadRadius: 2,
  //           blurRadius: 5,
  //           offset: const Offset(0, 3),
  //         ),
  //       ],
  //     ),
  //     child: TextField(
  //       onChanged: (String value) {
  //         ref.read(exSearchPageStateP).enteredKeyword = value;
  //         applyFilters(ref);
  //       },
  //       decoration: const InputDecoration(
  //         icon: Icon(Icons.search),
  //         // icon: Center(child: Icon(Icons.search)),
  //         hintText: 'Search',
  //         border: InputBorder.none,
  //       ),
  //     ),
  //   );
  // }

  // void _runFuzzySearch(String enteredKeyword, WidgetRef ref) {
  //   if (enteredKeyword.isEmpty) {
  //     ref.read(exSearchPageStateP).filteredExercises = gExs.exercises;
  //     // setState(() {
  //     //   filteredExercises = gExs.exercises;
  //     // });
  //   } else {
  //     var fuse = Fuzzy(gExs.names, options: FuzzyOptions(findAllMatches: true, threshold: 0.6));
  //     var results = fuse.search(enteredKeyword);
  //     var matchedNames = results.map((r) => r.item as String).toSet();
  //     ref.read(exSearchPageStateP).filteredExercises =
  //         gExs.exercises.where((e) => matchedNames.contains(e.name)).toList();
  //     // setState(() {
  //     //   filteredExercises = filteredExercises.where((e) => matchedNames.contains(e.name)).toList();
  //     // });
  //   }
  // }

/*
void showMultiSelectModal(
// Future<List<String>> showMultiSelectModal(
    BuildContext context,
    List<String> allItems,
    List<String> selectedItems) {
  final List<String> tempSelectedItems = List<String>.from(selectedItems);

  var state = context.read<ExSearchCubit>().state;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Select Items'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: allItems.length,
            itemBuilder: (context, index) {
              final item = allItems[index];
              return CheckboxListTile(
                value: tempSelectedItems.contains(item),
                title: Text(item),
                onChanged: (bool? value) {
                  // setState(() {
                  if (value == true) {
                    tempSelectedItems.add(item);
                  } else {
                    tempSelectedItems.remove(item);
                  }
                  // });
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
              selectedItems.clear();
              selectedItems.addAll(tempSelectedItems);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
  state.musclesFilter = selectedItems;
  // return selectedItems;
}
*/