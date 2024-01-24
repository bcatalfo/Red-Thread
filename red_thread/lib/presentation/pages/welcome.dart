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
    return Scaffold(
        appBar: AppBar(
          title: const Text("Welcome"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text("Welcome Page"),
              ElevatedButton(
                onPressed: () {
                  ref.read(isFirstTimeUserProvider.notifier).state = false;
                },
                child: const Text("Go to Login"),
              ),
            ],
          ),
        ));
  }
}
