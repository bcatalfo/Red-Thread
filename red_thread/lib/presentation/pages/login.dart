import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import 'package:red_thread/providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  static const String routeName = "/login";

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends ConsumerState<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Login"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text("Login Page"),
              ElevatedButton(
                onPressed: () {
                  ref.read(isAuthenticatedProvider.notifier).state = true;
                  //context.go("/account_setup");
                },
                child: const Text("Go to Account Setup"),
              ),
            ],
          ),
        ));
  }
}
