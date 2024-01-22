import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:red_thread/presentation/theme.dart';
import 'package:red_thread/providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({Key? key}) : super(key: key);

  static const String routeName = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(
          title:
              Text('Settings', style: Theme.of(context).textTheme.displayLarge),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text("What genders are you looking to match with?",
                        style: Theme.of(context).textTheme.headlineLarge),
                    MultiSelectChoiceChipDemo()
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class MultiSelectChoiceChipDemo extends StatefulWidget {
  @override
  _MultiSelectChoiceChipDemoState createState() =>
      _MultiSelectChoiceChipDemoState();
}

class _MultiSelectChoiceChipDemoState extends State<MultiSelectChoiceChipDemo> {
  final List<String> _options = ['Male', 'Female', 'Other'];
  final Set<String> _selectedOptions = <String>{};

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 8.0,
        children: _options.map((String option) {
          return ChoiceChip(
            label: Text(option, style: Theme.of(context).textTheme.labelLarge),
            selected: _selectedOptions.contains(option),
            onSelected: (bool selected) {
              setState(() {
                if (selected) {
                  _selectedOptions.add(option);
                } else {
                  _selectedOptions.remove(option);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }
}
