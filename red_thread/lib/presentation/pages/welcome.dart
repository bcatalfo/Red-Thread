import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import 'package:red_thread/providers.dart';

class WelcomePage extends ConsumerStatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  WelcomePageState createState() => WelcomePageState();
}

class WelcomePageState extends ConsumerState<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "Welcome to Red Thread",
                style: theme.textTheme.headlineLarge,
              ),
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/iTunesArtwork-1024.png', // Replace with your image path
              width: 200, // Adjust the size as needed
              height: 200,
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Find your thread of connection",
                style: theme.textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                ref.read(isFirstTimeUserProvider.notifier).state = false;
              },
              child: const Text("Go to Login"),
            ),
          ],
        ),
      ),
    );
  }
}
