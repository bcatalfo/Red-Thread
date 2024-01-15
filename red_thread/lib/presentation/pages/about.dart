import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  static const String routeName = '/about';

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          title:
              Text('About', style: Theme.of(context).textTheme.displayLarge)),
      body: Column(children: [
        MyCustomCard(
          mainText: 'Red Thread is...',
          subText: 'A dating app that actually gets you dating.',
        ),
        MyCustomCard(
          mainText: 'Not like Tinder',
          subText: 'No swiping. No profiles. Just dates.',
        ),
        MyCustomCard(
          mainText: 'Who we are',
          subText: 'Sam and Ben Catalfo of Catalfo Technologies LLC',
        )
      ]));
}

class MyCustomCard extends StatelessWidget {
  final String mainText;
  final String subText;

  MyCustomCard({
    required this.mainText,
    required this.subText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: theme.colorScheme.surfaceVariant,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
              child: Text(
                mainText,
                style: theme.textTheme.displayLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
              child: Text(
                subText,
                style: theme.textTheme.displayMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
