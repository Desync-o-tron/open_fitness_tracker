import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_fitness_tracker/DOM/basic_user_info.dart';
import 'package:open_fitness_tracker/DOM/history_importing_logic.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';
import 'package:open_fitness_tracker/importing/import_matching_page.dart';
import 'package:open_fitness_tracker/styles.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

class ExternalAppImportSelectionDialog extends StatelessWidget {
  const ExternalAppImportSelectionDialog({super.key});

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
  String? filepath;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Import Your Training History"),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(40),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyGenericButton(
                label: (filepath == null) ? "Select file to Import" : "File Selected.",
                onPressed: () async {
                  //todo for web?
                  // https://github.com/miguelpruivo/flutter_file_picker/wiki/FAQ
                  filepath =
                      await getFileWithSnackbarErrors(context, ['csv', 'txt', 'json']);
                  setState(() {});
                },
                color: (filepath == null) ? darkTan : mediumGreen,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<MassUnits>(
                decoration: const InputDecoration(labelText: 'Mass Unit'),
                value: units.preferredMassUnit,
                onChanged: (MassUnits? newValue) {
                  setState(() {
                    units.preferredMassUnit = newValue!;
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
              DropdownButtonFormField<DistanceUnits>(
                decoration: const InputDecoration(labelText: 'Distance Unit'),
                value: units.preferredDistanceUnit,
                onChanged: (DistanceUnits? newValue) {
                  setState(() {
                    units.preferredDistanceUnit = newValue!;
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
                  const Text('Set as Default Units for Me'),
                  Switch(
                    activeTrackColor: mediumGreen,
                    value: setAsStandard,
                    onChanged: (bool value) {
                      setState(() {
                        setAsStandard = value;
                      });
                    },
                  ),
                ],
              ),
              BottomCancelOrCompleteButtons(
                cancelLabel: "Cancel",
                completeLabel: "Import",
                onCancel: () {
                  Navigator.of(context).pop();
                },
                onComplete: () {
                  if (filepath == null) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('No file selected')));
                    return;
                  }

                  List<TrainingSession> sessions = importStrongCsv(filepath!, units);

                  if (setAsStandard) {
                    var userInfoCubit = context.read<BasicUserInfoCubit>();
                    BasicUserInfo userInfo = userInfoCubit.state;
                    userInfo.preferredDistanceUnit = units.preferredDistanceUnit;
                    userInfo.preferredMassUnit = units.preferredMassUnit;
                    userInfoCubit.set(userInfo);
                  }
                  Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          ImportInspectionPage(newTrainingSessions: sessions)));
                },
              ),
            ],
          ),
        ),
      ),
    );

    /*

    for (var session in sessions) {
      myStorage.addTrainingSessionToHistory(session);
    }
    
    */
  }
}

enum OtherTrainingApps {
  strong('Strong');

  const OtherTrainingApps(this.text);
  final String text;
}
