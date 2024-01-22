import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class AccountSetupPage extends ConsumerStatefulWidget {
  const AccountSetupPage({Key? key}) : super(key: key);

  static const String routeName = "/account_setup";

  @override
  AccountSetupPageState createState() => AccountSetupPageState();
}

class AccountSetupPageState extends ConsumerState<AccountSetupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Setup"),
      ),
      body: const Center(
        child: Text("Account Setup Page"),
      ),
    );
  }
}
