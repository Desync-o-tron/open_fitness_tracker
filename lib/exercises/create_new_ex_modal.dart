import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';
import 'package:open_fitness_tracker/exercises/ex_search_cubit.dart';
import 'package:open_fitness_tracker/state.dart';

class AddNewExerciseModal extends StatelessWidget {
  final String? name;
  const AddNewExerciseModal({super.key, this.name});

  @override
  Widget build(BuildContext context) {
    var newExercise = Exercise(
      name: name ?? '',
      equipment: '',
      primaryMuscles: [],
    );
    return AlertDialog(
      insetPadding: const EdgeInsets.all(15), // Outside Padding
      contentPadding: const EdgeInsets.all(10), // Content Padding
      backgroundColor: Theme.of(context).colorScheme.secondary,
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
          // DropdownSearch<String>(
          //   dropdownDecoratorProps: const DropDownDecoratorProps(
          //     dropdownSearchDecoration: InputDecoration(
          //       labelText: "Primary Muscles",
          //       //   labelText: "Menu mode",
          //       hintText: "country in menu mode",
          //     ),
          //   ),
          //TODO I am disapointed in this extension
          // dropdownSearchDecoration: InputDecoration(
          //   labelText: "Menu mode",
          //   hintText: "country in menu mode",
          // ),
          //   items: gExs.muscles,
          //   popupProps: const PopupPropsMultiSelection.menu(
          //     searchFieldProps: TextFieldProps(
          //       // textInputAction: TextInputAction.send,
          //       autofocus: true,
          //       showCursor: true,
          //       keyboardType: TextInputType.text,
          //       decoration: InputDecoration(
          //         border: OutlineInputBorder(),
          //         labelText: 'Search',
          //       ),
          //     ),
          //     menuProps: MenuProps(),
          //   ),
          //   filterFn: (String? item, String? filter) {
          //     // Implement your fuzzy search here using the Fuzzy package
          //     // For example, you can return true if the item contains the filter string
          //     return item?.contains(filter ?? '') ?? false;
          //   },
          // ),
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

class SearchableDropdown extends StatefulWidget {
  @override
  _SearchableDropdownState createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  final List<String> _primaryMuscles = ['Chest', 'Back', 'Legs']; // Initial list
  String? _selectedMuscle;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Add a muscle',
              suffixIcon: IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  final String newValue = _controller.text.trim();
                  if (newValue.isNotEmpty && !_primaryMuscles.contains(newValue)) {
                    setState(() {
                      _primaryMuscles.add(newValue);
                      _selectedMuscle = newValue; // Automatically select the new item
                    });
                    _controller.clear();
                  }
                },
              ),
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          value: _selectedMuscle,
          hint: Text('Select a muscle'),
          onChanged: (String? newValue) {
            setState(() {
              _selectedMuscle = newValue;
            });
          },
          items: _primaryMuscles.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ],
    );
  }
}
/*
class _SearchableDropdownState extends State<SearchableDropdown> {
  final TextEditingController _controller = TextEditingController();
  List<String> primaryMuscles = gExs.muscles;
  // [
  //   'Chest',
  //   'Back',
  //   'Legs'
  // ]; // Example list, replace with g_Exs.primaryMuscles if it's a global variable.
  List<String> filteredList = [];
  List<String> selectedItems = [];

  @override
  void initState() {
    super.initState();
    filteredList = primaryMuscles;
  }

  void _filterList(String enteredKeyword) {
    List<String> tempFilteredList = [];
    if (enteredKeyword.isEmpty) {
      tempFilteredList = primaryMuscles;
    } else {
      tempFilteredList = primaryMuscles
          .where((element) => element.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      filteredList = tempFilteredList;
    });
  }

  void _toggleSelection(String value) {
    setState(() {
      if (selectedItems.contains(value)) {
        selectedItems.remove(value);
      } else {
        selectedItems.add(value);
      }
    });
  }

  void _addItem(String item) {
    setState(() {
      primaryMuscles.add(item);
      filteredList.add(item);
      selectedItems.add(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: TextFormField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Search or add a muscle',
              suffixIcon: IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  final String newItem = _controller.text;
                  if (newItem.isNotEmpty && !primaryMuscles.contains(newItem)) {
                    _addItem(newItem);
                  }
                  _controller.clear();
                },
              ),
            ),
            onChanged: _filterList,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final item = filteredList[index];
              return ListTile(
                title: Text(item),
                leading: selectedItems.contains(item)
                    ? Icon(Icons.check_circle_outline)
                    : Icon(Icons.radio_button_unchecked),
                onTap: () => _toggleSelection(item),
                tileColor: selectedItems.contains(item) ? Colors.lightBlueAccent : null,
              );
            },
          ),
        ),
      ],
    );
  }
}
*/