import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';
import 'package:open_fitness_tracker/exercises/ex_dialog_page.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

class ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  final bool isSelectable;
  final bool isSelected;
  final Function? onSelectionChanged;

  const ExerciseTile({
    super.key,
    required this.exercise,
    this.isSelectable = false,
    this.isSelected = false,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    String musclesUsed = exercise.primaryMuscles.map((muscle) => muscle.capTheFirstLetter()).join(', ');
    if (exercise.secondaryMuscles != null && exercise.secondaryMuscles!.isNotEmpty) {
      musclesUsed +=
          " + ${exercise.secondaryMuscles!.map((muscle) => muscle.capTheFirstLetter()).join(', ')}";
    }

    BoxDecoration tileDecoration = const BoxDecoration();
    if (isSelectable) {
      tileDecoration = BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.black,
          width: 1,
        ),
      );
    } else {
      tileDecoration = BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
      );
    }

    return maybeSwipeable(
      child: Container(
        margin: const EdgeInsets.only(bottom: 5, right: 6, left: 6),
        // decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
        decoration: tileDecoration,
        child: ListTile(
          title: Text(exercise.name, style: Theme.of(context).textTheme.titleLarge),
          minVerticalPadding: 2,
          visualDensity: VisualDensity.compact,
          enabled: true,
          subtitle: Text(
            musclesUsed,
            style: Theme.of(context).textTheme.bodyLarge,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("2 uses ", style: Theme.of(context).textTheme.bodyLarge),
              Text("60lb (x12) ", style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => ExerciseDialog(exercise: exercise),
              useSafeArea: true,
            );
          },
        ),
      ),
    );
  }

  Widget maybeSwipeable({child, context}) {
    /*
    var swipeAction = SlidableAction(
      onPressed: (context) {},
      backgroundColor: Color(0xFF0392CF),
      foregroundColor: Colors.white,
      icon: Icons.add,
      label: 'Add',
    );

    return Slidable(
      // Specify a key if the Slidable is dismissible.
      key: const ValueKey(0),

      // The start action pane is the one at the left or the top side.
      startActionPane: ActionPane(
        // A motion is a widget used to control how the pane animates.
        motion: const ScrollMotion(),

        // A pane can dismiss the Slidable.
        dismissible: DismissiblePane(onDismissed: () {}),
        // dismissible: Container(
        //     // color: Colors.green,
        //     ),
        closeThreshold: 0.2,
        extentRatio: 0.001,

        children: [swipeAction],

        // // All actions are defined in the children parameter.
        // children: [
        //   // A SlidableAction can have an icon and/or a label.
        //   SlidableAction(
        //     onPressed: (context) {},
        //     backgroundColor: Color(0xFFFE4A49),
        //     foregroundColor: Colors.white,
        //     icon: Icons.delete,
        //     label: 'Delete',
        //   ),
        //   SlidableAction(
        //     onPressed: (context) {},
        //     backgroundColor: Color(0xFF21B7CA),
        //     foregroundColor: Colors.white,
        //     icon: Icons.share,
        //     label: 'Share',
        //   ),
        // ],
      ),

      // The end action pane is the one at the right or the bottom side.
      // endActionPane: ActionPane(
      //   motion: ScrollMotion(),
      //   children: [
      //     SlidableAction(
      //       // An action can be bigger than the others.
      //       flex: 2,
      //       onPressed: (context) {},
      //       backgroundColor: Color(0xFF7BC043),
      //       foregroundColor: Colors.white,
      //       icon: Icons.archive,
      //       label: 'Archive',
      //     ),
      //     SlidableAction(
      //       onPressed: (context) {},
      //       backgroundColor: Color(0xFF0392CF),
      //       foregroundColor: Colors.white,
      //       icon: Icons.save,
      //       label: 'Save',
      //     ),
      //   ],
      // ),

      // The child of the Slidable is what the user sees when the
      // component is not dragged.

      child: child,
      // child: const ListTile(title: Text('Slide me')),
    );
*/
    // if (!isSelectable) return child;
    return Dismissible(
      onDismissed: (direction) {
        if (onSelectionChanged != null) onSelectionChanged!(!isSelected);
      },
      // onUpdate: (direction) {
      //   if (onSelectionChanged != null) onSelectionChanged!(!isSelected);
      // },
      // onResize: (thingy) {},
      // background: Container(color: Colors.blue),
      background: child,
      // confirmDismiss: (direction) => Future.value(false),
      key: UniqueKey(),
      child: child,
    );
  }
}
