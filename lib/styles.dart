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

final myColorScheme = ColorScheme.fromSwatch(
  primarySwatch: MaterialColor(
    darkTan.value,
    <int, Color>{
      50: darkTan,
      100: darkTan,
      200: darkTan,
      300: darkTan,
      400: darkTan,
      500: darkTan,
      600: darkTan,
      700: darkTan,
      800: darkTan,
      900: darkTan,
    },
  ),
  accentColor: mediumGreen,
  cardColor: darkTan,
  backgroundColor: mediumTan,
  errorColor: darkTan,
  brightness: Brightness.light,
);

final myTheme = ThemeData(
  useMaterial3: true,
  // colorScheme: myColorScheme,
  colorScheme: ColorScheme.fromSeed(seedColor: darkTan),
);
