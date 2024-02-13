import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const FilterButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: Colors.white, // Adjust the background color as needed
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        side: const BorderSide(color: Colors.grey, width: 1), // Border color and width
        padding: const EdgeInsets.symmetric(vertical: 14.0), // Adjust padding as needed
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7.0),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black, // Adjust the text color as needed
          ),
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
      ),
    );
  }
}
