import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/exercises/create_new_ex_modal.dart';

class SearchableDropdown extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  SearchableDropdown({super.key});

  _addNewItem(BuildContext context, Exercise exercise) {
    final String newValue = _controller.text.trim();
    if (newValue.isNotEmpty && !exercise.primaryMuscles.contains(newValue)) {
      context
          .read<CreateNewExCubit>()
          .updateExercise(Exercise.fromExercise(exercise..primaryMuscles.insert(0, newValue)));
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Exercise exercise = context.watch<CreateNewExCubit>().state;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListStringDisplayWithEditRow(
          list: exercise.primaryMuscles,
          onPressed: (String str) {
            context.read<CreateNewExCubit>().updateExercise(exercise..primaryMuscles.remove(str));
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextFormField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Primary Muscles',
              suffixIcon:
                  IconButton(icon: const Icon(Icons.add), onPressed: () => _addNewItem(context, exercise)),
            ),
            onFieldSubmitted: (value) => _addNewItem(context, exercise),
          ),
        ),
      ],
    );
  }
}

class ListStringDisplayWithEditRow extends StatelessWidget {
  final List<String> list;
  final Null Function(String str) onPressed;
  const ListStringDisplayWithEditRow({super.key, required this.list, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: list.map((str) => _buildItem(str)).toList(),
      ),
    );
  }

  Widget _buildItem(String str) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Chip(
        visualDensity: VisualDensity.compact,
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        label: Text(str),
        // backgroundColor: Colors.lightBlue,
        deleteIcon: const Icon(Icons.close),
        onDeleted: () => onPressed(str),
      ),
    );
  }
}
