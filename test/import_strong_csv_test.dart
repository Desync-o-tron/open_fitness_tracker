import 'package:open_fitness_tracker/DOM/history_importing_logic.dart';
import 'package:flutter_test/flutter_test.dart';

//todo test for import with nothing
void main() {
  group('importStrongCsv', () {
    test('one session of one exercise with one set', () {
      const csvData = '''
Date,Workout Name,Duration,Exercise Name,Set Order,Weight,Reps,Distance,Seconds,Notes,Workout Notes,RPE
2023-01-03 23:24:55,"Evening Workout",31s,"Running",1,0,0,1.0,540,"","",
''';

      final sessions = importStrongCsv(csvData, Units(), true);

      expect(sessions.length, 1);
      expect(sessions[0].name, "Evening Workout");
      expect(sessions[0].trainingData.length, 1);
      expect(sessions[0].trainingData[0].ex.name, "Running");
      expect(sessions[0].trainingData[0].sets.length, 1);
    });

    test('one session of two exercises with one set each', () {
      const csvData = '''
Date,Workout Name,Duration,Exercise Name,Set Order,Weight,Reps,Distance,Seconds,Notes,Workout Notes,RPE
2023-01-03 23:24:55,"Evening Workout",31s,"Running",1,0,0,1.0,540,"","",
2023-01-03 23:24:55,"Evening Workout",31s,"Cycling",1,0,0,5.0,600,"","",
''';

      final sessions = importStrongCsv(csvData, Units(), true);

      expect(sessions.length, 1);
      expect(sessions[0].name, "Evening Workout");
      expect(sessions[0].trainingData.length, 2);
      expect(sessions[0].trainingData[0].ex.name, "Running");
      expect(sessions[0].trainingData[0].sets.length, 1);
      expect(sessions[0].trainingData[1].ex.name, "Cycling");
      expect(sessions[0].trainingData[1].sets.length, 1);
    });

    test('two sessions of one single exercise with one set', () {
      const csvData = '''
Date,Workout Name,Duration,Exercise Name,Set Order,Weight,Reps,Distance,Seconds,Notes,Workout Notes,RPE
2023-01-03 23:24:55,"Morning Workout",31s,"Running",1,0,0,1.0,540,"","",
2023-01-04 23:24:55,"Evening Workout",31s,"Running",1,0,0,1.0,540,"","",
''';

      final sessions = importStrongCsv(csvData, Units(), true);

      expect(sessions.length, 2);
      expect(sessions[0].name, "Morning Workout");
      expect(sessions[0].trainingData.length, 1);
      expect(sessions[0].trainingData[0].ex.name, "Running");
      expect(sessions[0].trainingData[0].sets.length, 1);
      expect(sessions[1].name, "Evening Workout");
      expect(sessions[1].trainingData.length, 1);
      expect(sessions[1].trainingData[0].ex.name, "Running");
      expect(sessions[1].trainingData[0].sets.length, 1);
    });

    test('two sessions of two exercises with two sets each', () {
      const csvData = '''
Date,Workout Name,Duration,Exercise Name,Set Order,Weight,Reps,Distance,Seconds,Notes,Workout Notes,RPE
2023-01-03 23:24:55,"Morning Workout",31s,"Running",1,0,0,1.0,540,"","",
2023-01-03 23:24:55,"Morning Workout",31s,"Running",2,0,0,1.0,540,"","",
2023-01-03 23:24:55,"Morning Workout",31s,"Cycling",1,0,0,5.0,600,"","",
2023-01-03 23:24:55,"Morning Workout",31s,"Cycling",2,0,0,5.0,600,"","",
2023-01-04 23:24:55,"Evening Workout",31s,"Running",1,0,0,1.0,540,"","",
2023-01-04 23:24:55,"Evening Workout",31s,"Running",2,0,0,1.0,540,"","",
2023-01-04 23:24:55,"Evening Workout",31s,"Cycling",1,0,0,5.0,600,"","",
2023-01-04 23:24:55,"Evening Workout",31s,"Cycling",2,0,0,5.0,600,"","",
''';

      final sessions = importStrongCsv(csvData, Units(), true);

      expect(sessions.length, 2);
      expect(sessions[0].name, "Morning Workout");
      expect(sessions[0].trainingData.length, 2);
      expect(sessions[0].trainingData[0].ex.name, "Running");
      expect(sessions[0].trainingData[0].sets.length, 2);
      expect(sessions[0].trainingData[1].ex.name, "Cycling");
      expect(sessions[0].trainingData[1].sets.length, 2);
      expect(sessions[1].name, "Evening Workout");
      expect(sessions[1].trainingData.length, 2);
      expect(sessions[1].trainingData[0].ex.name, "Running");
      expect(sessions[1].trainingData[0].sets.length, 2);
      expect(sessions[1].trainingData[1].ex.name, "Cycling");
      expect(sessions[1].trainingData[1].sets.length, 2);
    });

    test('import with nothing', () {
      const csvData = '''
Date,Workout Name,Duration,Exercise Name,Set Order,Weight,Reps,Distance,Seconds,Notes,Workout Notes,RPE
           ''';

      final sessions = importStrongCsv(csvData, Units(), true);

      expect(sessions.length, 0);
    });
  });
}
