import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';
import 'package:open_fitness_tracker/exercises/ex_search_page.dart';
import 'package:open_fitness_tracker/exercises/ex_tile.dart';
import 'package:open_fitness_tracker/importing/history_importing_cubits.dart';
import 'package:open_fitness_tracker/navigation/routes.dart';

class MatchExercisesScrollView extends StatefulWidget {
  final VoidCallback confirmSelections;

  const MatchExercisesScrollView({
    super.key,
    required this.confirmSelections,
  });

  @override
  _MatchExercisesScrollViewState createState() => _MatchExercisesScrollViewState();
}

class _MatchExercisesScrollViewState extends State<MatchExercisesScrollView> {
  List exerciseMatches = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    exerciseMatches = context.read<ImportedExerciseMatchesCubit>().state;
    if (exerciseMatches.isEmpty) return Container();

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Match exercises with our database.\n(Top is yours, bottom is ours)",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(border: Border.all()),
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: exerciseMatches.length,
                  itemBuilder: (context, index) {
                    return _buildExerciseMatchTile(index);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          MyGenericButton(
            onPressed: () {
              widget.confirmSelections();
              context.push(routeNames.History.text);
            },
            label: "Confirm Selections",
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseMatchTile(int index) {
    ExerciseMatchCard exerciseMatch = exerciseMatches[index];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            '${index + 1} of ${exerciseMatches.length}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  offset: const Offset(0, 2),
                  blurRadius: 4.0,
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Opacity(
                    opacity: exerciseMatch.bDiscard ? .33 : 1,
                    child: Column(
                      children: [
                        ExerciseTile(exercise: exerciseMatch.foreignExercise),
                        const SizedBox(height: 8.0),
                        _selectableExTile(index, exerciseMatch,
                            _getExerciseBackgroundColor(exerciseMatch)),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _acceptSwitch(exerciseMatch),
                      _useMyNameSwitch(exerciseMatch),
                      _discardThisExSwitch(exerciseMatch),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getExerciseBackgroundColor(ExerciseMatchCard exerciseMatch) {
    if (exerciseMatch.matchedExercise == null && !exerciseMatch.isConfirmed) {
      return Colors.red.shade300;
    } else if (exerciseMatch.isConfirmed) {
      return Colors.greenAccent.shade400;
    } else {
      return Colors.yellow.shade300;
    }
  }

  Column _discardThisExSwitch(ExerciseMatchCard exerciseMatch) {
    return Column(
      children: [
        const Center(
          child: Text('Discard?', textAlign: TextAlign.center),
        ),
        Switch(
          value: exerciseMatch.bDiscard,
          onChanged: (bool value) {
            setState(() {
              exerciseMatch.bDiscard = value;
            });
          },
        ),
      ],
    );
  }

  Column _useMyNameSwitch(ExerciseMatchCard exerciseMatch) {
    return Column(
      children: [
        const Center(
          child: Text('Use my name?', textAlign: TextAlign.center),
        ),
        Switch(
          value: (exerciseMatch.bDiscard)
              ? false
              : exerciseMatch.preferForeignExerciseName ||
                  (exerciseMatch.isConfirmed && exerciseMatch.matchedExercise == null),
          onChanged: (bool value) {
            if (exerciseMatch.bDiscard) return;
            setState(() {
              exerciseMatch.preferForeignExerciseName = value;
            });
          },
        ),
      ],
    );
  }

  Column _acceptSwitch(ExerciseMatchCard exerciseMatch) {
    return Column(
      children: [
        const Text('Accept?'),
        Switch(
          value: (exerciseMatch.bDiscard) ? false : exerciseMatch.isConfirmed,
          onChanged: (bool value) {
            if (exerciseMatch.bDiscard) return;
            setState(() {
              exerciseMatch.isConfirmed = value;
            });
          },
        ),
      ],
    );
  }

  Widget _selectableExTile(
      int index, ExerciseMatchCard exerciseMatch, Color matchedExerciseBackgroundColor) {
    if (exerciseMatch.matchedExercise != null) {
      List<Widget> stackContents = [];
      stackContents.add(ExerciseTile(
        exercise: exerciseMatch.matchedExercise!,
        borderColor: matchedExerciseBackgroundColor,
        isSelectable: true,
      ));

      stackContents.add(Positioned.fill(
        child: InkWell(
          onTap: () {
            _addNewExercise(index, exerciseMatch.foreignExercise,
                (Exercise? userMatchedEx) {
              setState(() {
                exerciseMatch.matchedExercise = userMatchedEx;
                exerciseMatch.isConfirmed = true;
              });
            });
          },
        ),
      ));
      stackContents.add(
        Positioned(
          right: 7,
          child: IconButton(
            onPressed: () {
              setState(() {
                exerciseMatch.matchedExercise = null;
              });
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.black,
            ),
          ),
        ),
      );
      return Stack(
        children: stackContents,
      );
    } else {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: matchedExerciseBackgroundColor, width: 3),
        ),
        child: Stack(
          children: [
            Container(
              height: 60,
              width: double.infinity,
              margin: const EdgeInsets.only(top: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    (exerciseMatch.isConfirmed)
                        ? Icons.check_box_outlined
                        : Icons.add_box_outlined,
                    size: 32,
                  ),
                  (exerciseMatch.isConfirmed)
                      ? const Text("  Add this exercise to your list")
                      : Container(),
                ],
              ),
            ),
            Positioned.fill(
              child: InkWell(
                onTap: () {
                  _addNewExercise(index, exerciseMatch.foreignExercise,
                      (Exercise? userMatchedEx) {
                    setState(() {
                      exerciseMatch.matchedExercise = userMatchedEx;
                      exerciseMatch.isConfirmed = true;
                    });
                  });
                },
              ),
            ),
          ],
        ),
      );
    }
  }

  void _addNewExercise(
      int index, Exercise foreignExercise, Function onExMatchFound) async {
    // todo how pass params? I want to use gorouter
    Exercise? newExercise = await Navigator.push<Exercise>(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseSearchPage(
          useForMappingForeignExercise: true,
          setForeignExerciseCallback: onExMatchFound,
          foreignEx: foreignExercise,
        ),
      ),
    );

    if (newExercise != null) {
      setState(() {
        exerciseMatches[index].matchedExercise = newExercise;
        exerciseMatches[index].isConfirmed = true;
      });
    }
  }
}
