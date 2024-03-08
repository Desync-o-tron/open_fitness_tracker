import 'package:flutter/material.dart';

class MyGenericButton extends StatelessWidget {
  final String label;
  final Widget? icon;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;
  final bool shouldFillWidth;
  final bool isEnabled;

  const MyGenericButton({
    super.key,
    this.label = '',
    this.icon,
    required this.onPressed,
    this.color = Colors.white,
    this.textColor = Colors.black,
    this.shouldFillWidth = true,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      width: shouldFillWidth ? double.infinity : null,
      child: TextButton(
        onPressed: isEnabled ? onPressed : null,
        style: TextButton.styleFrom(
          backgroundColor: isEnabled ? color : Colors.grey, // Adjust the background color as needed
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          side: const BorderSide(color: Colors.grey, width: 1), // Border color and width
          padding: const EdgeInsets.symmetric(vertical: 14.0), // Adjust padding as needed
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isEnabled ? textColor : Colors.black45, // Adjust the text color as needed
                ),
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
              if (icon != null)
                Padding(
                  padding: label != '' ? const EdgeInsets.only(left: 10.0) : const EdgeInsets.all(0),
                  child: icon,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
