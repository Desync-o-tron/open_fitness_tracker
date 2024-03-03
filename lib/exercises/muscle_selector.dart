import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:open_fitness_tracker/state.dart';

class SearchableMusclesSelectorComplex extends StatefulWidget {
  final String labelText;
  final List<String> muscles;
  final Null Function(String muscle) onMuscleAdded;
  final Null Function(String muscle) onMuscleRemoved;

  const SearchableMusclesSelectorComplex({
    super.key,
    required this.muscles,
    required this.onMuscleAdded,
    required this.onMuscleRemoved,
    required this.labelText,
  });

  @override
  State<SearchableMusclesSelectorComplex> createState() => _SearchableMusclesSelectorComplexState();
}

class _SearchableMusclesSelectorComplexState extends State<SearchableMusclesSelectorComplex> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();

  List<String> filteredMuscles = List.of(gExs.muscles);

  _addNewItem(BuildContext context) {
    final String newValue = _textController.text.trim();
    if (newValue.isNotEmpty && !widget.muscles.contains(newValue)) {
      widget.onMuscleAdded(newValue);
      _textController.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    _textFieldFocusNode.addListener(() {
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
            visible: _textFieldFocusNode.hasFocus,
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

  Expanded musclesDropDown(BuildContext context) {
    return Expanded(
      child: SizedBox(
        child: ListView.builder(
          itemBuilder: (context, index) => ListTile(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), side: const BorderSide(color: Colors.black)),
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
          suffixIcon: IconButton(icon: const Icon(Icons.add), onPressed: () => _addNewItem(context)),
          contentPadding: const EdgeInsets.all(0),
        ),
        onFieldSubmitted: (value) => _addNewItem(context),
        onChanged: (String text) {
          filteredMuscles = gExs.muscles.where((String muscle) => muscle.contains(text)).toList();
          if (filteredMuscles.isEmpty) filteredMuscles = gExs.muscles;
          // if (filteredMuscles.isEmpty) {
          //   _portalController.hide();
          // } else {
          //   _portalController.show();
          // }
          setState(() {
            filteredMuscles = filteredMuscles;
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose(); //this is important?
    _textFieldFocusNode.dispose();
    super.dispose();
  }
}

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

class SelectedMuscles extends StatelessWidget {
  final List<String> list;
  final Null Function(String str) onDeleted;
  const SelectedMuscles({super.key, required this.list, required this.onDeleted});

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
