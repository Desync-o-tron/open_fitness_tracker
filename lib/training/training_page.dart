import 'package:flutter/material.dart';

ShowTrainingSession(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    useSafeArea: true,
    constraints: BoxConstraints(
      maxHeight: double.infinity,
    ),
    scrollControlDisabledMaxHeightRatio: 1,
    isDismissible: false,
    enableDrag: false,
    // anchorPoint: Offset(559, 200),
    elevation: 200,
    backgroundColor: Theme.of(context).colorScheme.onBackground,
    builder: (BuildContext context) => const TrainingPage(),
  );
}

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  double pageHeight = double.infinity;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: pageHeight,
      width: double.infinity,
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                pageHeight = 200;
              });
            },
            child: Text("press"),
          )
        ],
      ),
    );
  }
}
