import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import 'package:red_thread/providers.dart';

class AccountSetupPage extends ConsumerStatefulWidget {
  const AccountSetupPage({Key? key}) : super(key: key);

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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text("Account Setup Page"),
              ElevatedButton(
                onPressed: () {
                  ref.read(isAccountSetupCompleteProvider.notifier).state =
                      true;
                  //context.go("/account_setup");
                },
                child: const Text("Go to verification"),
              ),
            ],
          ),
        ));
  }
}
