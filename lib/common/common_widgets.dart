import 'package:flutter/material.dart';

class MyGenericButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;

  const MyGenericButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = Colors.white,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: color, // Adjust the background color as needed
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          side: const BorderSide(color: Colors.grey, width: 1), // Border color and width
          padding: const EdgeInsets.symmetric(vertical: 14.0), // Adjust padding as needed
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7.0),
          child: Text(
            label,
            style: TextStyle(
              color: textColor, // Adjust the text color as needed
            ),
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ),
      ),
    );
  }
}
