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
      // padding: const EdgeInsets.all(20),
      height: 50,
      child: TextButton(
        onPressed: isEnabled ? onPressed : null,
        style: TextButton.styleFrom(
          backgroundColor: isEnabled ? color : Colors.grey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          side: const BorderSide(color: Colors.grey, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
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
                  padding: label.isNotEmpty ? const EdgeInsets.only(left: 10.0) : const EdgeInsets.all(0),
                  child: icon,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
