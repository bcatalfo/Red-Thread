import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:red_thread/providers.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  static const String routeName = '/settings';

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title:
            Text('Settings', style: Theme.of(context).textTheme.displayLarge),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 8, 8, 8),
            child: Text('Identify As',
                style: Theme.of(context).textTheme.displayLarge),
          ),
          const Center(child: IdentifyAsButton()),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 8, 8, 8),
            child: Text('Interested In',
                style: Theme.of(context).textTheme.displayLarge),
          ),
          const Center(child: InterestedInSwitches()),
        ],
      ));
}

class IdentifyAsButton extends ConsumerStatefulWidget {
  const IdentifyAsButton({Key? key}) : super(key: key);

  @override
  IdentifyAsButtonState createState() => IdentifyAsButtonState();
}

class IdentifyAsButtonState extends ConsumerState<IdentifyAsButton> {
  @override
  Widget build(BuildContext context) {
    final gender = ref.watch(identifyAsProvider);

    return Column(children: <Widget>[
      RadioListTile<Gender>(
          title: Text('Male', style: Theme.of(context).textTheme.displayMedium),
          value: Gender.male,
          groupValue: gender,
          onChanged: (value) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(identifyAsProvider.notifier).state = value!;
            });
          }),
      RadioListTile<Gender>(
          title:
              Text('Female', style: Theme.of(context).textTheme.displayMedium),
          value: Gender.female,
          groupValue: gender,
          onChanged: (value) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(identifyAsProvider.notifier).state = value!;
            });
          }),
      RadioListTile<Gender>(
          title:
              Text('Other', style: Theme.of(context).textTheme.displayMedium),
          value: Gender.other,
          groupValue: gender,
          onChanged: (value) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(identifyAsProvider.notifier).state = value!;
            });
          }),
    ]);
  }
}

class InterestedInSwitches extends ConsumerWidget {
  const InterestedInSwitches({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interestedInMale = ref.watch(interestedInMaleProvider);
    final interestedInFemale = ref.watch(interestedInFemaleProvider);
    final interestedInOther = ref.watch(interestedInOtherProvider);

    return Column(
      children: [
        SwitchListTile(
          title: Text('Male', style: Theme.of(context).textTheme.displayMedium),
          value: interestedInMale,
          onChanged: (bool value) {
            ref.read(interestedInMaleProvider.notifier).state = value;
          },
        ),
        SwitchListTile(
          title:
              Text('Female', style: Theme.of(context).textTheme.displayMedium),
          value: interestedInFemale,
          onChanged: (bool value) {
            ref.read(interestedInFemaleProvider.notifier).state = value;
          },
        ),
        SwitchListTile(
          title:
              Text('Other', style: Theme.of(context).textTheme.displayMedium),
          value: interestedInOther,
          onChanged: (bool value) {
            ref.read(interestedInOtherProvider.notifier).state = value;
          },
        ),
      ],
    );
  }
}
