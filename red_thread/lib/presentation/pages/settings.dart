import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:red_thread/providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends ConsumerState<SettingsPage> {
  Set<Gender> _selectedGenders = {};
  double _maxDistance = 50;
  RangeValues _ageRange = const RangeValues(18, 30);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Column(
        children: [
          _buildLookingForPage(context),
          const Divider(),
          _buildDistancePage(context),
          const Divider(),
          _buildAgeRangePage(context),
        ],
      ),
    );
  }

  Widget _buildLookingForPage(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Select the gender(s) you're interested in",
              style: textTheme.headlineMedium),
          const SizedBox(height: 20),
          FormField<Set<Gender>>(
            validator: (value) {
              if (_selectedGenders.isEmpty) {
                return "Please select at least one gender";
              }
              return null;
            },
            builder: (formFieldState) {
              return Column(
                children: [
                  CheckboxListTile(
                    title: Text('Male', style: textTheme.headlineSmall),
                    value: _selectedGenders.contains(Gender.male),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedGenders.add(Gender.male);
                        } else {
                          _selectedGenders.remove(Gender.male);
                        }
                        formFieldState.didChange(_selectedGenders);
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Female', style: textTheme.headlineSmall),
                    value: _selectedGenders.contains(Gender.female),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedGenders.add(Gender.female);
                        } else {
                          _selectedGenders.remove(Gender.female);
                        }
                        formFieldState.didChange(_selectedGenders);
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Other', style: textTheme.headlineSmall),
                    value: _selectedGenders.contains(Gender.other),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedGenders.add(Gender.other);
                        } else {
                          _selectedGenders.remove(Gender.other);
                        }
                        formFieldState.didChange(_selectedGenders);
                      });
                    },
                  ),
                  if (formFieldState.hasError)
                    Text(
                      formFieldState.errorText!,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDistancePage(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Set max distance for match", style: textTheme.headlineMedium),
          Text("This is how far your matches can be from you.",
              style: textTheme.bodyLarge),
          const SizedBox(height: 20),
          Text("Current distance: ${_maxDistance.round()} miles",
              style: textTheme.headlineSmall),
          const SizedBox(height: 20),
          Slider(
            value: _maxDistance,
            min: 1,
            max: 100,
            divisions: 99,
            label: "${_maxDistance.round()} miles",
            onChanged: (double value) {
              setState(() {
                _maxDistance = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAgeRangePage(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Set age range for match", style: textTheme.headlineMedium),
          Text("You will only match with people in this age range",
              style: textTheme.bodyLarge),
          const SizedBox(height: 20),
          Text(
              "Current age range: ${_ageRange.start.round()} - ${_ageRange.end.round()}",
              style: textTheme.headlineSmall),
          const SizedBox(height: 20),
          RangeSlider(
            values: _ageRange,
            min: 18,
            max: 100,
            divisions: 82,
            labels: RangeLabels(
              "${_ageRange.start.round()}",
              "${_ageRange.end.round()}",
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _ageRange = values;
              });
            },
          ),
        ],
      ),
    );
  }
}
