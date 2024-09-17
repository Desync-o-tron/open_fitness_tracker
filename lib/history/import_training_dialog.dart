import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_fitness_tracker/DOM/history_importing.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/cloud_io/firestore_sync.dart';

class ExternalAppTrainingImportDialog extends StatelessWidget {
  const ExternalAppTrainingImportDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose Import Source'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: const Text('Strong App'),
            onTap: () {
              Navigator.of(context).pop();
              _importTrainingData('strong', context);
            },
          ),
          ListTile(
            title: const Text('more to come..submit ticket on github'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void _importTrainingData(String source, BuildContext context) async {
    var scaffoldMessenger = ScaffoldMessenger.of(context);

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'txt', 'json'],
    );

    if (result == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
      return;
    }
    String? filePath = result.files.single.path;
    if (filePath == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('No file selected. Is the path unaccessable?')),
      );
      return;
    }

    List<TrainingSession> sessions = [];
    if (source == 'strong') {
      sessions = importStrongCsv(filePath);
    }

    //todo for web
    // https://github.com/miguelpruivo/flutter_file_picker/wiki/FAQ

    for (var session in sessions) {
      print("test");
      print(session.toJson());
      myStorage.addTrainingSessionToHistory(session);
    }

    //todo (low-priority) tell the user if they are importing duplicates..we already discard them. maybe it doesn't matter.

    scaffoldMessenger.showSnackBar(
      SnackBar(content: Text("imported ${sessions.length} sessions.")),
    );
  }
}
