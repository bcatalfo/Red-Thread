import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:red_thread/providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends ConsumerState<SettingsPage> {
  late Set<Gender> _localSelectedGenders;
  late double _localMaxDistance;
  late RangeValues _localAgeRange;

  @override
  void initState() {
    super.initState();
    _localSelectedGenders = Set.from(ref.read(selectedGendersProvider));
    _localMaxDistance = ref.read(maxDistanceProvider);
    _localAgeRange = ref.read(ageRangeProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildLookingForPage(context),
            const Divider(),
            _buildDistancePage(context),
            const Divider(),
            _buildAgeRangePage(context),
            const Divider(),
            _buildSaveButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLookingForPage(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: GlobalKey<FormState>(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Interested in gender(s)",
                style: textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10.0,
                runSpacing: 10.0, // Adds vertical padding between lines
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: FilterChip(
                      label: Text('Male', style: textTheme.headlineSmall),
                      selected: _localSelectedGenders.contains(Gender.male),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _localSelectedGenders.add(Gender.male);
                          } else {
                            _localSelectedGenders.remove(Gender.male);
                          }
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: FilterChip(
                      label: Text('Female', style: textTheme.headlineSmall),
                      selected: _localSelectedGenders.contains(Gender.female),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _localSelectedGenders.add(Gender.female);
                          } else {
                            _localSelectedGenders.remove(Gender.female);
                          }
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: FilterChip(
                      label: Text('Other', style: textTheme.headlineSmall),
                      selected: _localSelectedGenders.contains(Gender.other),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _localSelectedGenders.add(Gender.other);
                          } else {
                            _localSelectedGenders.remove(Gender.other);
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (_localSelectedGenders.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Please select at least one gender",
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
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
          Center(
            child: Text(
              "Max Distance",
              style: textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Current distance: ${_localMaxDistance.round()} miles",
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          Slider(
            value: _localMaxDistance,
            min: 1,
            max: 100,
            divisions: 99,
            label: "${_localMaxDistance.round()} miles",
            onChanged: (double value) {
              setState(() {
                _localMaxDistance = value;
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
          Center(
            child: Text(
              "Age Range",
              style: textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Current age range: ${_localAgeRange.start.round()} - ${_localAgeRange.end.round()}",
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          RangeSlider(
            values: _localAgeRange,
            min: 18,
            max: 100,
            divisions: 82,
            labels: RangeLabels(
              "${_localAgeRange.start.round()}",
              "${_localAgeRange.end.round()}",
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _localAgeRange = values;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          if (_localSelectedGenders.isNotEmpty) {
            ref.read(selectedGendersProvider.notifier).state =
                _localSelectedGenders;
            ref.read(maxDistanceProvider.notifier).state = _localMaxDistance;
            ref.read(ageRangeProvider.notifier).state = _localAgeRange;
          } else {
            // Show validation error
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Error"),
                content: const Text("Please select at least one gender."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          }
        },
        child: const Text("Save Settings"),
      ),
    );
  }
}
