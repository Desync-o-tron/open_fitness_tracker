import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';
import 'package:open_fitness_tracker/state.dart';
import 'package:open_fitness_tracker/exercises/ex_search_cubit.dart' show ExSearchCubit, ExSearchState;
import 'package:open_fitness_tracker/exercises/ex_tile.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

class ExercisesPage extends StatelessWidget {
  const ExercisesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController(initialScrollOffset: 0);
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
                          return Container(
                            margin: const EdgeInsets.only(bottom: 5, right: 6, left: 6),
                            decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
                            child: ExerciseTile(exercise: state.filteredExercises[index]),
                          );
                        }),
                  ),
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
