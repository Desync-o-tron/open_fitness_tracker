import 'package:flutter/material.dart';
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
        SaveSettingsButton(),
      ],
    );
  }
}

class SaveSettingsButton extends StatelessWidget {
  const SaveSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return MyGenericButton(
      onPressed: () {},
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
