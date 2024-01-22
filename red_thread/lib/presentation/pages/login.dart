import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

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
      body: const Center(
        child: Text("Login Page"),
      ),
    );
  }
}
