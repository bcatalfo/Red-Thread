import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  static const String routeName = '/settings';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title:
              Text('Settings', style: Theme.of(context).textTheme.displayLarge),
        ),
        body: const Center(
          child: Text('Settings Page'),
        ),
      );
}
