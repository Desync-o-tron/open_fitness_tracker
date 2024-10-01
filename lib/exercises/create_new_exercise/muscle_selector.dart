import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_fitness_tracker/cloud_io/firestore_sync.dart';

class MusclesPicker extends StatefulWidget {
  final String labelText;
  final bool validate;
  final List<String> musclesAdded;
  final Null Function(String muscle) onMuscleAdded;
  final Null Function(String muscle) onMuscleRemoved;

  const MusclesPicker({
    super.key,
    required this.musclesAdded,
    required this.onMuscleAdded,
    required this.onMuscleRemoved,
    required this.labelText,
    required this.validate,
  });

  @override
  State<MusclesPicker> createState() => _MusclesPickerState();
}

class _MusclesPickerState extends State<MusclesPicker> {
  final TextEditingController _textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    List<DropdownMenuEntry<String>> dropdownMenuEntries = [];
    final exsState = context.read<ExercisesCubit>().state
        as ExercisesLoaded; //we're all loaded if we got here..
    for (String muscle in exsState.muscles) {
      dropdownMenuEntries.add(DropdownMenuEntry(
        label: muscle,
        value: muscle,
        trailingIcon: widget.musclesAdded.contains(muscle)
            ? const Icon(Icons.check, color: Colors.green)
            : null,
      ));
    }

    return Column(
      children: [
        SelectedMuscles(
          list: widget.musclesAdded,
          onDeleted: widget.onMuscleRemoved,
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 6.0)),
        DropdownMenu<String>(
          errorText: widget.validate && widget.musclesAdded.isEmpty
              ? "At least one muscle must be selected"
              : null,
          controller: _textController,
          onSelected: (String? muscle) {
            if (muscle == null) {
              String newValue = _textController.text.trim();
              if (newValue.isNotEmpty && !widget.musclesAdded.contains(newValue)) {
                widget.onMuscleAdded(newValue);
              }
            } else {
              if (widget.musclesAdded.contains(muscle)) {
                widget.onMuscleRemoved(muscle);
              } else {
                widget.onMuscleAdded(muscle);
              }
            }
            _textController.clear();
          },
          menuHeight: 333,
          expandedInsets: EdgeInsets.zero,
          dropdownMenuEntries: dropdownMenuEntries,
          enableSearch: true,
          enableFilter: true,
          requestFocusOnTap: true,
          leadingIcon: const Icon(Icons.search),
          label: Text(widget.labelText),
        ),
      ],
    );
  }
}

class SelectedMuscles extends StatelessWidget {
  final List<String> list;
  final Null Function(String str) onDeleted;
  const SelectedMuscles({super.key, required this.list, required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return const SizedBox(height: 20);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: list.map((str) => muscleChip(str)).toList(),
      ),
    );
  }

  Widget muscleChip(String str) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Chip(
        visualDensity: VisualDensity.compact,
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        label: Text(str),
        // backgroundColor: Colors.lightBlue,
        deleteIcon: const Icon(Icons.close),
        onDeleted: () => onDeleted(str),
      ),
    );
  }
}

/*
//
//below is so complex it's not worth it for now.......
//
class SearchableMusclesSelectorComplexx extends StatefulWidget {
  final String labelText;
  final List<String> muscles;
  final Null Function(String muscle) onMuscleAdded;
  final Null Function(String muscle) onMuscleRemoved;

  const SearchableMusclesSelectorComplexx({
    super.key,
    required this.muscles,
    required this.onMuscleAdded,
    required this.onMuscleRemoved,
    required this.labelText,
  });

  @override
  State<SearchableMusclesSelectorComplexx> createState() =>
      _SearchableMusclesSelectorState();
}

class _SearchableMusclesSelectorState extends State<SearchableMusclesSelectorComplexx> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();
  final FocusNode _dropDownFocusNode = FocusNode();

  List<String> filteredMuscles = List.of(ExDB.muscles);
  bool foundExactMuscle = true;

  _addNewMuscleName(BuildContext context) {
    final String newValue = _textController.text.trim();
    if (newValue.isNotEmpty && !widget.muscles.contains(newValue)) {
      widget.onMuscleAdded(newValue);
      _textController.clear();
      filteredMuscles = [];
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _textFieldFocusNode.addListener(() {
      setState(() {});
    });
    _dropDownFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Portal(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SelectedMuscles(
            list: widget.muscles,
            onDeleted: widget.onMuscleRemoved,
          ),
          PortalTarget(
            visible: _textFieldFocusNode.hasFocus || _dropDownFocusNode.hasFocus,
            // visible: true,
            anchor: const Aligned(
              follower: Alignment.topCenter,
              target: Alignment.bottomCenter,
            ),
            portalFollower: musclesDropDown(context),
            child: muscleSearchTextField(context),
          ),
        ],
      ),
    );
  }

  Widget musclesDropDown(BuildContext context) {
    return Expanded(
      child: Focus(
        focusNode: _dropDownFocusNode,
        child: ListView.builder(
          shrinkWrap: true,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemBuilder: (context, index) => Card(
            child: Focus(
              focusNode: _dropDownFocusNode,
              child: ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: const BorderSide(color: Colors.black)),
                title: Text(filteredMuscles[index]),
                selected: widget.muscles.contains(filteredMuscles[index]),
                trailing: widget.muscles.contains(filteredMuscles[index])
                    ? const Icon(Icons.check, color: Colors.green)
                    : const Icon(Icons.add),
                onTap: () {
                  if (widget.muscles.contains(filteredMuscles[index])) {
                    widget.onMuscleRemoved(filteredMuscles[index]);
                  } else {
                    widget.onMuscleAdded(filteredMuscles[index]);
                  }
                  setState(() {});
                },
              ),
            ),
          ),
          itemCount: filteredMuscles.length,
        ),
      ),
    );
  }

  Widget muscleSearchTextField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextFormField(
        focusNode: _textFieldFocusNode,
        controller: _textController,
        decoration: InputDecoration(
          labelText: widget.labelText,
          suffixIcon: !foundExactMuscle
              ? IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addNewMuscleName(context))
              : null,
          contentPadding: const EdgeInsets.all(0),
        ),
        onFieldSubmitted: (value) => _addNewMuscleName(context),
        onChanged: (String search) {
          List<String> allMuscles = ExDB.muscles.toList();
          allMuscles
              .addAllIfDNE(widget.muscles); // so we don't 5get to add new custom muscles

          var fuseForMuscles = Fuzzy(allMuscles,
              options: FuzzyOptions(findAllMatches: true, threshold: 0.25));
          filteredMuscles =
              fuseForMuscles.search(search).map((r) => r.item as String).toList();
          foundExactMuscle = filteredMuscles.contains(search);

          if (filteredMuscles.isEmpty && search.isEmpty) filteredMuscles = ExDB.muscles;
          setState(() {});
        },
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose(); //this is important?
    _textFieldFocusNode.dispose();
    _dropDownFocusNode.dispose();
    super.dispose();
  }
}
*/
class MusclesDropdown extends StatelessWidget {
  const MusclesDropdown({
    super.key,
    required this.filteredMuscles,
    required this.onMuscleAdded,
    required this.onMuscleRemoved,
  });

  final List<String> filteredMuscles;
  final Null Function(String muscle) onMuscleAdded;
  final Null Function(String muscle) onMuscleRemoved;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemBuilder: (context, index) => ListTile(
          title: Text(filteredMuscles[index]),
          onTap: () {
            // onMuscleAdded(filteredMuscles[index]);
            if (filteredMuscles.contains(filteredMuscles[index])) {
              onMuscleRemoved(filteredMuscles[index]);
            } else {
              onMuscleAdded(filteredMuscles[index]);
            }
          },
        ),
        itemCount: filteredMuscles.length,
      ),
    );
  }
}
