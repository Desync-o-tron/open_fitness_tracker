import 'package:flutter/material.dart';

Color mediumGreen = const Color(0xFFCCD5AE);
Color lightGreen = const Color(0xFFE9EDC9);
Color darkTan = const Color(0xFFD4A373);
Color mediumTan = const Color(0xFFFAEDCD);
Color lightTan = const Color(0xFFFEFAE0);

const TextStyle largeButtonTextStyle = TextStyle(
  fontSize: 18,
  color: Colors.black,
  // color: Theme.of(context).colorScheme.onPrimary,
);

ButtonStyle largeButtonStyle(BuildContext context, [borderRadius = 32.0]) => ElevatedButton.styleFrom(
    foregroundColor: Theme.of(context).colorScheme.onPrimary,
    backgroundColor: Theme.of(context).colorScheme.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    ));
