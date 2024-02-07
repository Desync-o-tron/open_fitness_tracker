import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';
import 'package:open_fitness_tracker/exercises/ex_tile.dart';
import 'package:open_fitness_tracker/state.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

class ExSearchPageState {
  List<Exercise> filteredExercises = gExs.exercises;
  List<String> categoriesFilter = [];
  List<String> musclesFilter = [];
  String enteredKeyword = '';
}

final exSearchPageStateP = StateProvider<ExSearchPageState>((ref) {
  return ExSearchPageState();
});

// class ExercisesPage extends StatefulWidget {
//   const ExercisesPage({super.key});

//   @override
//   State<ExercisesPage> createState() => _ExercisesPageState();
// }

// class _ExercisesPageState extends State<ExercisesPage> {
class ExercisesPage extends ConsumerWidget {
  const ExercisesPage({super.key});

  void applyFilters(WidgetRef ref) {
    var state = ref.read(exSearchPageStateP);
    state.filteredExercises = gExs.exercises;

    // filter by muscles
    for (String muscle in state.musclesFilter) {
      // state.filteredExercises
      //     .addAllIfDNE(state.filteredExercises.where((e) => e.primaryMuscles.contains(muscle)).toList());
      List<Exercise> newFilteredExercises = [];
      for (var e in state.filteredExercises) {
        if (e.primaryMuscles.contains(muscle)) {
          newFilteredExercises.addIfDNE(e);
        }
      }
      for (var e in state.filteredExercises) {
        if (e.secondaryMuscles != null && e.secondaryMuscles!.contains(muscle)) {
          newFilteredExercises.addIfDNE(e);
        }
      }
      state.filteredExercises = newFilteredExercises;
      // state.filteredExercises
      //     .addAllIfDNE(state.filteredExercises.where((e) => e.secondaryMuscles?.contains(muscle)).toList());
      //TODO^
    }
    // filter by categories
    //TODO

    // filter by keyword
    // if (state.enteredKeyword.isNotEmpty) {
    //   var fuse = Fuzzy(gExs.names, options: FuzzyOptions(findAllMatches: true, threshold: 0.6));
    //   var results = fuse.search(state.enteredKeyword);
    //   var matchedNames = results.map((r) => r.item as String).toSet();
    //   state.filteredExercises = state.filteredExercises.where((e) => matchedNames.contains(e.name)).toList();
    // }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Exercise> filteredExercises = ref.watch(exSearchPageStateP).filteredExercises;
    List<String> categoriesFilter = ref.watch(exSearchPageStateP).categoriesFilter;
    List<String> musclesFilter = ref.watch(exSearchPageStateP).musclesFilter;
    return Container(
      // color: Theme.of(context).colorScheme.secondary,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Exercises',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredExercises.length,
                // itemCount: filteredExercises.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 5, right: 6, left: 6),
                    decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
                    child: ExerciseTile(exercise: filteredExercises[index]),
                  );
                },
              ),
            ),
            _searchBox(ref),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 2, 5, 11),
              child: Row(
                children: [
                  Expanded(
                    child: FilterButton(
                      label: musclesFilter.isEmpty
                          ? 'Any Muscle'
                          : musclesFilter.map((e) => e.capTheFirstLetter()).join(", "),
                      onPressed: () async {
                        var newMusclesFilter =
                            await showMultiSelectModal(context, gExs.muscles, musclesFilter);
                        ref.read(exSearchPageStateP).musclesFilter = newMusclesFilter;
                        applyFilters(ref); //would be nice if I didn't have to call this manually...TODO!
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: FilterButton(
                      label: categoriesFilter.isEmpty
                          ? 'Any Category'
                          : categoriesFilter.map((e) => e.capTheFirstLetter()).join(", "),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container _searchBox(WidgetRef ref) {
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
        onChanged: (String value) {
          ref.read(exSearchPageStateP).enteredKeyword = value;
          applyFilters(ref);
        },
        decoration: const InputDecoration(
          icon: Icon(Icons.search),
          // icon: Center(child: Icon(Icons.search)),
          hintText: 'Search',
          border: InputBorder.none,
        ),
      ),
    );
  }

  void addSearchFilters() {}

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
}
