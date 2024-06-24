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
  double _maxDistance = 1.0;
  RangeValues _ageRange = const RangeValues(18, 100);
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    final selectedGendersAsync = ref.watch(selectedGendersProvider);
    final maxDistanceAsync = ref.watch(maxDistanceProvider);
    final ageRangeAsync = ref.watch(ageRangeProvider);

    selectedGendersAsync.when(
      data: (selectedGenders) {
        if (_isLoading) {
          _selectedGenders = selectedGenders!;
        }
      },
      loading: () {},
      error: (err, stack) => debugPrint('Error loading selected genders: $err'),
    );

    maxDistanceAsync.when(
      data: (maxDistance) {
        if (_isLoading) {
          _maxDistance = maxDistance!;
        }
      },
      loading: () {},
      error: (err, stack) => debugPrint('Error loading max distance: $err'),
    );

    ageRangeAsync.when(
      data: (ageRange) {
        if (_isLoading) {
          _ageRange = ageRange!;
        }
      },
      loading: () {},
      error: (err, stack) => debugPrint('Error loading age range: $err'),
    );

    if (selectedGendersAsync.isLoading ||
        maxDistanceAsync.isLoading ||
        ageRangeAsync.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (selectedGendersAsync.hasError ||
        maxDistanceAsync.hasError ||
        ageRangeAsync.hasError) {
      return Scaffold(
        body: Center(
          child: Text('Error loading settings'),
        ),
      );
    }

    if (_isLoading) {
      _isLoading = false;
    }

    return _buildSettingsPage(context);
  }

  Widget _buildSettingsPage(BuildContext context) {
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
                runSpacing: 10.0,
                children: Gender.values.map((gender) {
                  String label;
                  switch (gender) {
                    case Gender.male:
                      label = 'Male';
                      break;
                    case Gender.female:
                      label = 'Female';
                      break;
                    case Gender.nonBinary:
                      label = 'Non-binary';
                      break;
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: FilterChip(
                      label: Text(label, style: textTheme.headlineSmall),
                      selected: _selectedGenders.contains(gender),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _selectedGenders.add(gender);
                          } else {
                            _selectedGenders.remove(gender);
                          }
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            if (_selectedGenders.isEmpty)
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
            "Current distance: ${_maxDistance.round()} miles",
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          Slider(
            value: _maxDistance,
            inactiveColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.24),
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
          Center(
            child: Text(
              "Age Range",
              style: textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Current age range: ${_ageRange.start.round()} - ${_ageRange.end.round()}",
            style: textTheme.headlineSmall,
          ),
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

  Widget _buildSaveButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          if (_selectedGenders.isNotEmpty) {
            ref
                .read(selectedGendersProvider.notifier)
                .setGenders(_selectedGenders);
            ref.read(maxDistanceProvider.notifier).setMaxDistance(_maxDistance);
            ref.read(ageRangeProvider.notifier).setAgeRange(_ageRange);
            debugPrint(
                'Settings saved: Genders: $_selectedGenders, Max Distance: $_maxDistance, Age Range: ${_ageRange.start} - ${_ageRange.end}');
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
