import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_fitness_tracker/DOM/basic_user_info.dart';
import 'package:open_fitness_tracker/DOM/training_metadata.dart';
import 'package:open_fitness_tracker/common/common_widgets.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        UserSettingsPageTitle(),
        BasicUserInfoWidget(),
      ],
    );
  }
}

class BasicUserInfoWidget extends StatefulWidget {
  const BasicUserInfoWidget({super.key});

  @override
  State<BasicUserInfoWidget> createState() => _BasicUserInfoWidgetState();
}

class _BasicUserInfoWidgetState extends State<BasicUserInfoWidget> {
  @override
  Widget build(BuildContext context) {
    BasicUserInfo userInfo = context.read<BasicUserInfoCubit>().state;
    final TextEditingController usernameController =
        TextEditingController(text: userInfo.searchableUsername);
    return SafeArea(
      minimum: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Your Username ~',
              hintText: 'Enter a public searchable username',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            maxLength: 100,
            controller: usernameController,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<MassUnits>(
            decoration: const InputDecoration(labelText: 'Mass Unit'),
            value: userInfo.preferredMassUnit,
            onChanged: (MassUnits? newValue) {
              setState(() {
                userInfo.preferredMassUnit = newValue!;
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
            value: userInfo.preferredDistanceUnit,
            onChanged: (DistanceUnits? newValue) {
              setState(() {
                userInfo.preferredDistanceUnit = newValue!;
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
          const SaveSettingsButton(),
        ],
      ),
    );
  }
}

class SaveSettingsButton extends StatelessWidget {
  const SaveSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return MyGenericButton(
      onPressed: () {
        BasicUserInfoCubit userInfo = context.read<BasicUserInfoCubit>();
        userInfo.set(userInfo.state);
      },
      label: "Save Settings",
    );
  }
}

class UserSettingsPageTitle extends StatelessWidget {
  const UserSettingsPageTitle({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10.0),
        child: Text(
          'Settings Page',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
