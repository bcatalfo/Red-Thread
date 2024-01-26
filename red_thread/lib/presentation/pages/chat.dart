import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:red_thread/presentation/drawer.dart';
import 'package:red_thread/providers.dart';
import 'package:go_router/go_router.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  static const String routeName = '/chat';

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends ConsumerState<ChatPage> {
  void unmatch(BuildContext context) {
    // Add your unmatch button logic here
    ref.read(matchFoundProvider.notifier).state = false;
    context.go('/');
  }

  final messages = <ChatMessage>[
    ChatMessage(
      message: 'Where do you wanna go?',
      author: 'Emma',
      date: DateTime(2023, 12, 18, 12, 0, 2),
    ),
    ChatMessage(
      message: 'Wanna meet up at Central Park?😍',
      author: 'Ben',
      date: DateTime(2023, 12, 18, 12, 0, 3),
    ),
    ChatMessage(
      message: 'Let’s get some food first.',
      author: 'Emma',
      date: DateTime(2023, 12, 18, 12, 0, 5),
    ),
  ];

  void _sendMessage(String text) {
    final newMessage = ChatMessage(
      message: text,
      author: 'Ben', // TODO: get from backend
      date: DateTime.now(),
    );
    setState(() {
      messages.add(newMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context, ref),
      drawer: myDrawer(context, ref),
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: messages[index],
                  );
                },
              ),
            ),
            ChatInputBar(onSend: _sendMessage),
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String message;
  final String author;
  final DateTime date;

  const ChatMessage({
    Key? key,
    required this.message,
    required this.author,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final DateFormat formatter = DateFormat('M/d/yyyy h:mm a');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(author,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8.0),
            Text(formatter.format(date), style: theme.textTheme.bodySmall),
          ],
        ),
        Text(message, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}

class ChatInputBar extends StatefulWidget {
  final Function(String) onSend;

  ChatInputBar({Key? key, required this.onSend}) : super(key: key);

  @override
  _ChatInputBarState createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _textController = TextEditingController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() {
        _isTyping = _textController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          AnimatedSize(
            duration: Duration(milliseconds: 200),
            child: _isTyping
                ? SizedBox()
                : ElevatedButton(
                    onPressed: () {
                      // TODO: start video call
                    },
                    child: const Icon(Icons.video_call),
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: "Type a message",
                border: UnderlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              if (_isTyping) {
                widget.onSend(_textController.text);
                _textController.clear();
                // TODO: Send the message to the backend
              } else {
                // Implement other button functionality
                debugPrint("Other button pressed");
              }
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isTyping
                  ? const Icon(Icons.send, key: ValueKey('send'))
                  : const Icon(Icons.edit_calendar_sharp,
                      key: ValueKey('calendar')),
            ),
          ),
        ],
      ),
    );
  }
}
