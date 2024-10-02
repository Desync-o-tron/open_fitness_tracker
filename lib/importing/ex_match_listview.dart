import 'package:flutter/material.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';
import 'package:open_fitness_tracker/exercises/ex_search_page.dart';
import 'package:open_fitness_tracker/exercises/ex_tile.dart';
import 'package:open_fitness_tracker/navigation/routes.dart';

class ExerciseMatch {
  final Exercise foreignExercise;
  Exercise? matchedExercise;
  bool isConfirmed;
  bool preferForeignExerciseName;
  bool bDiscard;

  ExerciseMatch({
    required this.foreignExercise,
    this.matchedExercise,
    this.isConfirmed = false,
    this.preferForeignExerciseName = false,
    this.bDiscard = false,
  });
}

class MatchExercisesScrollView extends StatefulWidget {
  final List<ExerciseMatch> exerciseMatches;
  final List<Exercise> allImportedExercises;
  final VoidCallback confirmSelections;

  const MatchExercisesScrollView({
    super.key,
    required this.exerciseMatches,
    required this.allImportedExercises,
    required this.confirmSelections,
  });

  @override
  _MatchExercisesScrollViewState createState() => _MatchExercisesScrollViewState();
}

class _MatchExercisesScrollViewState extends State<MatchExercisesScrollView> {
  @override
  Widget build(BuildContext context) {
    if (widget.exerciseMatches.isEmpty) return Container();

    return Column(
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
            child: ListView.builder(
              itemCount: widget.exerciseMatches.length,
              itemBuilder: (context, index) {
                return _buildExerciseMatchTile(index);
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        MyGenericButton(
          onPressed: widget.confirmSelections,
          label: "Confirm Selections",
        ),
      ],
    );
  }

  Widget _buildExerciseMatchTile(int index) {
    ExerciseMatch exerciseMatch = widget.exerciseMatches[index];

    Color matchedExerciseBackgroundColor;
    if (exerciseMatch.matchedExercise == null) {
      matchedExerciseBackgroundColor = Colors.red.shade300;
    } else if (exerciseMatch.isConfirmed) {
      matchedExerciseBackgroundColor = Colors.greenAccent.shade400;
    } else {
      matchedExerciseBackgroundColor = Colors.yellow.shade300;
    }

    return Padding(
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
            ),
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
                    _selectableExTile(
                        index, exerciseMatch, matchedExerciseBackgroundColor),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  const Center(
                    child: Text(
                      'Use my name?',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Switch(
                    value: (exerciseMatch.bDiscard)
                        ? false
                        : exerciseMatch.preferForeignExerciseName,
                    onChanged: (bool value) {
                      if (exerciseMatch.bDiscard) return;
                      setState(() {
                        exerciseMatch.preferForeignExerciseName = value;
                      });
                    },
                  ),
                  const Center(
                    child: Text(
                      'Discard?',
                      textAlign: TextAlign.center,
                    ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectableExTile(
      int index, ExerciseMatch exerciseMatch, Color matchedExerciseBackgroundColor) {
    return Stack(
      children: [
        (exerciseMatch.matchedExercise != null)
            ? ExerciseTile(
                exercise: exerciseMatch.matchedExercise!,
                borderColor: matchedExerciseBackgroundColor,
                isSelectable: true,
              )
            : Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                height: 60,
                width: 9999,
                decoration: BoxDecoration(
                    border: Border.all(color: matchedExerciseBackgroundColor, width: 3)),
                child: const Icon(
                  Icons.add_box_outlined,
                  size: 32,
                ),
              ),
        (exerciseMatch.matchedExercise != null)
            ? const Positioned(top: 10, right: 10, child: Icon(Icons.edit))
            : Container(),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _addNewExercise(index, exerciseMatch.foreignExercise,
                    (Exercise? userMatchedEx) {
                  if (userMatchedEx != null) {
                    setState(() {
                      exerciseMatch.matchedExercise = userMatchedEx;
                      exerciseMatch.isConfirmed = true;
                    });
                  }
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  void _addNewExercise(
      int index, Exercise foreignExercise, Function onExMatchFound) async {
    // Exercise? newExercise = await routerConfig.push(routeNames.Exercises.text);
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
        widget.exerciseMatches[index].matchedExercise = newExercise;
        widget.exerciseMatches[index].isConfirmed = true;
      });
    }
  }
}
