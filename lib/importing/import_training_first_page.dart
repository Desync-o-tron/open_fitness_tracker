import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_fitness_tracker/DOM/basic_user_info.dart';
import 'package:open_fitness_tracker/DOM/history_importing_logic.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';
import 'package:open_fitness_tracker/importing/history_importing_cubits.dart';
import 'package:open_fitness_tracker/importing/import_inspection_page.dart';
import 'package:open_fitness_tracker/styles.dart';
import 'package:open_fitness_tracker/utils/utils.dart';

class ImportTrainingDataPage extends StatefulWidget {
  const ImportTrainingDataPage({
    super.key,
  });

  @override
  State<ImportTrainingDataPage> createState() => _ImportTrainingDataPageState();
}

class _ImportTrainingDataPageState extends State<ImportTrainingDataPage> {
  final Units units = Units();
  late MassUnits selectedMassUnit;
  late DistanceUnits selectedDistanceUnit;
  bool setAsStandard = true;
  String? filepathORfileStr;
  OtherTrainingApps originApp = OtherTrainingApps.strong;

  @override
  void initState() {
    super.initState();
    var importedTrainingSessionsCubit = context.read<ImportedTrainingSessionsCubit>();
    if (importedTrainingSessionsCubit.getSessions().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSwitchSessionDialog(context);
      });
    }
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
              originAppSelector(),
              const SizedBox(height: 16),
              fileSelectButton(context),
              const SizedBox(height: 16),
              massSelectDropdown(),
              const SizedBox(height: 16),
              distanceSelectDropdown(),
              const SizedBox(height: 16),
              setAsDefaultUnitsSwitch(),
              BottomCancelOrCompleteButtons(
                cancelLabel: "Cancel",
                completeLabel: "Import",
                onCancel: () {
                  Navigator.of(context).pop();
                },
                onComplete: runImport,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row setAsDefaultUnitsSwitch() {
    return Row(
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
    );
  }

  DropdownButtonFormField<DistanceUnits> distanceSelectDropdown() {
    return DropdownButtonFormField<DistanceUnits>(
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
    );
  }

  Widget massSelectDropdown() {
    return DropdownButtonFormField<MassUnits>(
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
    );
  }

  MyGenericButton fileSelectButton(BuildContext context) {
    return MyGenericButton(
      label: (filepathORfileStr == null) ? "Select file to Import" : "File Selected.",
      onPressed: () async {
        filepathORfileStr =
            await getFileWithSnackbarErrors(context, ['csv', 'txt', 'json']);
        setState(() {});
      },
      color: (filepathORfileStr == null) ? darkTan : mediumGreen,
    );
  }

  DropdownMenu<String> originAppSelector() {
    return DropdownMenu(
      hintText: "Pick an app to import from",
      initialSelection: OtherTrainingApps.strong.text,
      width: double.infinity,
      dropdownMenuEntries: <DropdownMenuEntry<String>>[
        DropdownMenuEntry(
          value: OtherTrainingApps.strong.text,
          label: "Strong App",
        ),
        const DropdownMenuEntry(
          value: "Submit a github ticket w/ an example file to import.",
          label: "Submit a github ticket w/ an example file to import.",
        ),
      ],
    );
  }

  void runImport() {
    if (filepathORfileStr == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No file selected')));
      return;
    }

    List<TrainingSession> sessions;
    if (originApp == OtherTrainingApps.strong) {
      try {
        sessions = importStrongCsv(filepathORfileStr!, units);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Failed to import. Is the file malformed? Did you select the correct App')));
        return;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select a valid App to import from.')));
      return;
    }

    if (setAsStandard) {
      var userInfoCubit = context.read<BasicUserInfoCubit>();
      BasicUserInfo userInfo = userInfoCubit.state;
      userInfo.preferredDistanceUnit = units.preferredDistanceUnit;
      userInfo.preferredMassUnit = units.preferredMassUnit;
      userInfoCubit.set(userInfo);
    }
    context.read<ImportedTrainingSessionsCubit>().addSessions(sessions);

    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            ImportInspectionPage(newTrainingSessions: sessions)));
  }

  void _showSwitchSessionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Switch to Last Importing Session'),
          content: const Text(
              'You have an existing import session. Would you like to switch to it?'),
          actions: [
            TextButton(
              onPressed: () {
                context.read<ImportedTrainingSessionsCubit>().deleteSessions();
                context.read<ImportedExerciseMatchesCubit>().deleteAll();
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                List<TrainingSession> importedTrainingSessions =
                    context.read<ImportedTrainingSessionsCubit>().getSessions();

                Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (BuildContext context) => ImportInspectionPage(
                        newTrainingSessions: importedTrainingSessions)));
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}

enum OtherTrainingApps {
  strong('Strong');

  const OtherTrainingApps(this.text);
  final String text;
}
