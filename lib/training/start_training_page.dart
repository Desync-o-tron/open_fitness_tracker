import 'package:flutter/material.dart';

class StartTrainingPage extends StatelessWidget {
  const StartTrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(children: [
      const Text(
        'Start Training',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(18.0),
        // ),
        onPressed: () {
          // Handle button press
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 20.0),
          child: Text(
            'Start a Training Sesh',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ]));
  }
}
