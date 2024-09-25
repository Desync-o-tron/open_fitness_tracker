// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() {
  doLocal();
  doForeign();
}

void doLocal() async {
  // Path to your JSON file
  const jsonFilePath =
      '/Users/lukeknoble/depot/open_fitness_tracker/assets/data/exercises.json';

  // Read the contents of the JSON file
  String jsonString;
  try {
    jsonString = await File(jsonFilePath).readAsString();
  } catch (e) {
    print('Error reading JSON file: $e');
    return;
  }

  // Parse the JSON data into a list of maps
  final exercises = List<Map<String, dynamic>>.from(jsonDecode(jsonString));

  // Path to output CSV file
  const csvFilePath = 'myDBexNames.csv';

  // Write names to the CSV file
  try {
    await File(csvFilePath)
        .writeAsString(exercises.map((exercise) => exercise['name']).join('\n'));
    print('CSV file created successfully at $csvFilePath');
  } catch (e) {
    print('Error writing to CSV file: $e');
  }
}

void doForeign() async {
  // Path to your input CSV file
  const inputCsvFilePath =
      '/Users/lukeknoble/depot/open_fitness_tracker/assets/example_inputs/strong.csv';

  // Path to output CSV file
  const outputCsvFilePath = 'foreignExNames.csv';

  try {
    // Read the contents of the input CSV file
    final fileContent = await File(inputCsvFilePath).readAsString();

    // Split the content into lines and process each line
    final lines = fileContent.split('\n');
    final exerciseNames = <String>[];

    for (final line in lines) {
      if (line.isNotEmpty && !exerciseNames.contains(line.split(',')[3])) {
        // Assuming Exercise Name is the 4th column
        String exName = line.split(',')[3].replaceAll(r'"', "");
        exerciseNames.addIfDNE(exName);
      }
    }

    // Write the extracted exercise names to the output CSV file
    await File(outputCsvFilePath).writeAsString(exerciseNames.join('\n'));

    print('Exercise names written successfully to $outputCsvFilePath');
  } catch (e) {
    print('Error processing the CSV files: $e');
  }
}

extension ListExtension<E> on List<E> {
  void addIfDNE(E? item) {
    if (item != null && !contains(item)) {
      add(item);
    }
  }

  void addAllIfDNE(List<E?> items) {
    for (var item in items) {
      addIfDNE(item);
    }
  }
}
