import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:open_fitness_tracker/DOM/exercise_metadata.dart';

typedef Exercises = List<Exercise>;
typedef Strings = List<String>;

class GenericScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

//
///screen size jank
//
const double kLargeScreenBreakpoint = 800;
const double kSmallScreenBreakpoint = 500;

isLandscape(BuildContext context) {
  if (MediaQuery.of(context).orientation == Orientation.landscape) {
    return true;
  } else {
    return false;
  }
}

bool isLargeScreen(BuildContext context) {
  return getWidth(context) > kLargeScreenBreakpoint;
}

bool isSmallScreen(BuildContext context) {
  return getWidth(context) < kSmallScreenBreakpoint;
}

bool isMediumScreen(BuildContext context) {
  return getWidth(context) > kSmallScreenBreakpoint &&
      getWidth(context) < kLargeScreenBreakpoint;
}

double getWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double getHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

//
//etc...
//

Future<Size> calculateImageDimensions(Image image) {
  Completer<Size> completer = Completer();
  image.image.resolve(const ImageConfiguration()).addListener(
    ImageStreamListener(
      (ImageInfo image, bool synchronousCall) {
        var myImage = image.image;
        Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
        completer.complete(size);
      },
    ),
  );
  return completer.future;
}

String intDayToString(int day) {
  switch (day) {
    case 1:
      return 'Monday';
    case 2:
      return 'Tuesday';
    case 3:
      return 'Wednesday';
    case 4:
      return 'Thursday';
    case 5:
      return 'Friday';
    case 6:
      return 'Saturday';
    case 7:
      return 'Sunday';
    default:
      return 'Error';
  }
}

//
//extensions..
//

extension StringExtension on String {
  String toCaps() => length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';
  String toTitleCase() =>
      replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCaps()).join(' ');
  String capTheFirstLetter() => this[0].toUpperCase() + substring(1);
  bool get isWhitespace => trim().isEmpty;
}

extension ListExtension<E> on List<E> {
  void addIfDNE(E? item) {
    if (item != null && !contains(item)) {
      add(item);
    }
  }

  void addAllIfDNE(List<E?>? items) {
    if (items == null) return;
    for (var item in items) {
      addIfDNE(item);
    }
  }
}

extension DurationExtensions on Duration {
  /// Converts the duration into a readable string
  /// 05:15
  String toHoursMinutes() {
    String twoDigitMinutes = _toTwoDigits(inMinutes.remainder(60));
    return "${_toTwoDigits(inHours)}:$twoDigitMinutes";
  }

  /// Converts the duration into a readable string
  /// 05:15:35
  String toHoursMinutesSeconds() {
    String twoDigitMinutes = _toTwoDigits(inMinutes.remainder(60));
    String twoDigitSeconds = _toTwoDigits(inSeconds.remainder(60));
    return "${_toTwoDigits(inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  String _toTwoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }
}

extension DateTimeExtensions on DateTime {
  String toDaysAgo() {
    DateTime now = DateTime.now();
    Duration difference = now.difference(this);
    int daysAgo = difference.inDays;
    if (daysAgo == 0) {
      return 'Today';
    } else if (daysAgo == 1) {
      return 'Yesterday';
    } else {
      return '$daysAgo Days Ago';
    }
  }
}

//untested
String enumToReadableString(Object o) {
  final String enumString = o.toString().split('.').last;
  final RegExp exp = RegExp(r"(?<=[a-z])(?=[A-Z])");

  return enumString
      .splitMapJoin(
        exp,
        onMatch: (_) => " ",
        onNonMatch: (n) => n,
      )
      .toLowerCase();
}

/// will return the whole file as a string if on web.
Future<String?> getFileWithSnackbarErrors(
    BuildContext context, List<String> allowedExtensions) async {
  String? filePath;
  var scaffoldMessenger = ScaffoldMessenger.of(context);

  FilePickerResult? result = await FilePicker.platform
      .pickFiles(type: FileType.custom, allowedExtensions: allowedExtensions);

  if (result == null && result!.files.isNotEmpty) {
    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('No file selected')),
    );
    return null;
  }

  if (kIsWeb) {
    final fileBytes = result.files.first.bytes;
    return utf8.decode(fileBytes!);
  }

  filePath = result.files.single.path;
  if (filePath == null) {
    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('No file selected. Is the path accessable?')),
    );
    return null;
  }

  return filePath;
}
