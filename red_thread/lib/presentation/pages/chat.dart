import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:red_thread/presentation/drawer.dart';
import 'package:red_thread/providers.dart';
import 'package:go_router/go_router.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends ConsumerState<ChatPage> {
  void unmatch(BuildContext context) {
    // Add your unmatch button logic here
    ref.read(matchFoundProvider.notifier).state = false;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar,
      drawer: myDrawer(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => unmatch(context),
        child: const Icon(Icons.close),
      ),
      body: const Center(
        child: Text('Chat Page'),
      ),
    );
  }
}
