import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import 'package:red_thread/providers.dart';
import 'package:red_thread/presentation/theme.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends ConsumerState<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Container(
            width: 289,
            height: 61,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: themeMode == ThemeMode.light
                  ? globalLightScheme.surfaceVariant
                  : globalDarkScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text('Red Thread',
                style: TextStyle(
                    fontSize: 48,
                    color: themeMode == ThemeMode.light
                        ? globalLightScheme.primary
                        : globalDarkScheme.primary)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Login to Your Account",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ref.read(isAuthenticatedProvider.notifier).state = true;
                      // Add your authentication logic here
                    }
                  },
                  child: const Text("Login"),
                ),
                const SizedBox(height: 20),
                DividerWithText(
                    text: 'OR', dividerColor: theme.colorScheme.outline),
                const SizedBox(height: 20),
                // TODO: Implement sign in logic
                SignInButton(
                    themeMode == ThemeMode.light
                        ? Buttons.google
                        : Buttons.googleDark,
                    onPressed: () {}),
                const SizedBox(height: 20),
                SignInButton(
                    themeMode == ThemeMode.light
                        ? Buttons.apple
                        : Buttons.appleDark,
                    onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class DividerWithText extends StatelessWidget {
  final String text;
  final Color dividerColor;

  const DividerWithText({
    Key? key,
    required this.text,
    this.dividerColor = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Divider(
            color: dividerColor,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(text),
        ),
        Expanded(
          child: Divider(
            color: dividerColor,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
