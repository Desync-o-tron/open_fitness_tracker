import 'package:flutter/material.dart';
import 'package:open_fitness_tracker/DOM/history_importing.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/DOM/basic_user_info.dart';
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
            onTap: () async {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) =>
                      const ImportTrainingDataPage(OtherTrainingApps.strong),
                ),
              );
              // String? filepath = await getFileWithSnackbarErrors(
              //   context,
              //   ['csv', 'txt', 'json'],
              // );
              // if (filepath == null) {
              //   return;
              // }
              // List<TrainingSession> trainingData = [];
              // navigator.push(
              //   MaterialPageRoute<void>(
              //     builder: (BuildContext context) => ImportTrainingDataDialog(
              //         filepath, OtherTrainingApps.strong, trainingData),
              //   ),
              // );
              // _importTrainingDataDialog(filepath, OtherTrainingApps.strong, context);
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
/*
  void _importTrainingDataDialog(
      String filepath, OtherTrainingApps originApp, BuildContext context) async {
    var scaffoldMessenger = ScaffoldMessenger.of(context);

    //todo for web
    // https://github.com/miguelpruivo/flutter_file_picker/wiki/FAQ

    Units units = Units(); // Or fetch existing units
    final unitsResult = await showDialog<Units>(
      context: context,
      builder: (BuildContext context) {
        return UnitsDialog(units: units);
      },
    );

    List<TrainingSession> sessions = [];
    if (originApp == OtherTrainingApps.strong) {
      sessions = importStrongCsv(filepath, units);
    }

    for (var session in sessions) {
      myStorage.addTrainingSessionToHistory(session);
    }

    //todo (low-priority) tell the user if they are importing duplicates..we already discard them. maybe it doesn't matter.

    scaffoldMessenger.showSnackBar(
      SnackBar(content: Text("imported ${sessions.length} sessions.")),
    );
  }
  */
}

class ImportTrainingDataPage extends StatefulWidget {
  const ImportTrainingDataPage(
    this.originApp, {
    super.key,
  });
  final OtherTrainingApps originApp;

  @override
  State<ImportTrainingDataPage> createState() => _ImportTrainingDataPageState();
}

class _ImportTrainingDataPageState extends State<ImportTrainingDataPage> {
  final Units units = Units();
  late MassUnits selectedMassUnit;
  late DistanceUnits selectedDistanceUnit;
  bool setAsStandard = false;

  @override
  void initState() {
    super.initState();
    selectedMassUnit = MassUnits.lb;
    selectedDistanceUnit = DistanceUnits.miles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Training History Importing"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<MassUnits>(
              decoration: const InputDecoration(labelText: 'Mass Unit'),
              value: selectedMassUnit,
              onChanged: (MassUnits? newValue) {
                setState(() {
                  selectedMassUnit = newValue!;
                });
              },
              items: MassUnits.values.map((MassUnits unit) {
                return DropdownMenuItem<MassUnits>(
                  value: unit,
                  child: Text(unit.text),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),
            // Distance Unit Dropdown
            DropdownButtonFormField<DistanceUnits>(
              decoration: const InputDecoration(labelText: 'Distance Unit'),
              value: selectedDistanceUnit,
              onChanged: (DistanceUnits? newValue) {
                setState(() {
                  selectedDistanceUnit = newValue!;
                });
              },
              items: DistanceUnits.values.map((DistanceUnits unit) {
                return DropdownMenuItem<DistanceUnits>(
                  value: unit,
                  child: Text(unit.text),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Toggle Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Set as Standard Units'),
                Switch(
                  value: setAsStandard,
                  onChanged: (bool value) {
                    setState(() {
                      setAsStandard = value;
                    });
                  },
                ),
              ],
            ),

            // Cancel Button
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                // OK Button
                TextButton(
                  onPressed: () {
                    // Update the units
                    units.preferredMassUnit = selectedMassUnit;
                    units.preferredDistanceUnit = selectedDistanceUnit;

                    // Handle the toggle switch functionality here (left blank)
                    if (setAsStandard) {
                      // TODO: Implement setting as standard units
                    }

                    Navigator.of(context).pop(units);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    /*
    String? filepath;
    List<TrainingSession> trainingData;
    var scaffoldMessenger = ScaffoldMessenger.of(context);

    //  filepath = await getFileWithSnackbarErrors(
    //   context,
    //   ['csv', 'txt', 'json'],
    // );
    // if (filepath == null) {
    //   return;
    // }

    //todo for web
    // https://github.com/miguelpruivo/flutter_file_picker/wiki/FAQ

    Units units = Units(); // Or fetch existing units
    final unitsResult = showDialog<Units>(
      context: context,
      builder: (BuildContext context) {
        return UnitsDialog(units: units);
      },
    );

    List<TrainingSession> sessions = [];
    if (widget.originApp == OtherTrainingApps.strong) {
      sessions = importStrongCsv(filepath, units);
    }

    for (var session in sessions) {
      myStorage.addTrainingSessionToHistory(session);
    }

    //todo (low-priority) tell the user if they are importing duplicates..we already discard them. maybe it doesn't matter.

    scaffoldMessenger.showSnackBar(
      SnackBar(content: Text("imported ${sessions.length} sessions.")),
    );
    */
  }
}

enum OtherTrainingApps {
  strong('Strong');

  const OtherTrainingApps(this.text);
  final String text;
}

class UnitsDialog extends StatefulWidget {
  final Units units;

  const UnitsDialog({super.key, required this.units});

  @override
  // ignore: library_private_types_in_public_api
  _UnitsDialogState createState() => _UnitsDialogState();
}

class _UnitsDialogState extends State<UnitsDialog> {
  late MassUnits _selectedMassUnit;
  late DistanceUnits _selectedDistanceUnit;
  bool _setAsStandard = false;

  @override
  void initState() {
    super.initState();
    _selectedMassUnit = widget.units.preferredMassUnit;
    _selectedDistanceUnit = widget.units.preferredDistanceUnit;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Units'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mass Unit Dropdown
            DropdownButtonFormField<MassUnits>(
              decoration: const InputDecoration(labelText: 'Mass Unit'),
              value: _selectedMassUnit,
              onChanged: (MassUnits? newValue) {
                setState(() {
                  _selectedMassUnit = newValue!;
                });
              },
              items: MassUnits.values.map((MassUnits unit) {
                return DropdownMenuItem<MassUnits>(
                  value: unit,
                  child: Text(unit.text),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Distance Unit Dropdown
            DropdownButtonFormField<DistanceUnits>(
              decoration: const InputDecoration(labelText: 'Distance Unit'),
              value: _selectedDistanceUnit,
              onChanged: (DistanceUnits? newValue) {
                setState(() {
                  _selectedDistanceUnit = newValue!;
                });
              },
              items: DistanceUnits.values.map((DistanceUnits unit) {
                return DropdownMenuItem<DistanceUnits>(
                  value: unit,
                  child: Text(unit.text),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Toggle Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Set as Standard Units'),
                Switch(
                  value: _setAsStandard,
                  onChanged: (bool value) {
                    setState(() {
                      _setAsStandard = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        // Cancel Button
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        // OK Button
        TextButton(
          onPressed: () {
            // Update the units
            widget.units.preferredMassUnit = _selectedMassUnit;
            widget.units.preferredDistanceUnit = _selectedDistanceUnit;

            // Handle the toggle switch functionality here (left blank)
            if (_setAsStandard) {
              // TODO: Implement setting as standard units
            }

            Navigator.of(context).pop(widget.units);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
