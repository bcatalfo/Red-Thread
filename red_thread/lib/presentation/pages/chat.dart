import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:red_thread/presentation/drawer.dart';
import 'package:red_thread/presentation/theme.dart';
import 'package:red_thread/providers.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends ConsumerState<ChatPage> {
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
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const MatchBar(),
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8),
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

  const ChatInputBar({Key? key, required this.onSend}) : super(key: key);

  @override
  ChatInputBarState createState() => ChatInputBarState();
}

class ChatInputBarState extends State<ChatInputBar> {
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: _isTyping
                ? const SizedBox()
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

class MatchBar extends ConsumerWidget {
  const MatchBar({Key? key}) : super(key: key);

  void unmatch(BuildContext context, WidgetRef ref) {
    // Add your unmatch button logic here
    ref.read(matchFoundProvider.notifier).state = false;
    ref.read(isPreviewCompleteProvider.notifier).state = false;
    debugPrint("Unmatch button pressed");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLight = ref.watch(themeModeProvider) == ThemeMode.light;
    final scheme = isLight ? globalLightScheme : globalDarkScheme;

    return Container(
      color: scheme.surfaceContainerHighest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emma',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('25, 3.5 miles away',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: scheme.primary,
                backgroundColor: scheme.surfaceContainerLow,
              ),
              label: Text('Unmatch', style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.primary,
              )),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    backgroundColor: scheme.surfaceContainerHigh,
                    title: Text('Unmatch with Emma?',
                        style: theme.textTheme.headlineMedium
                            ?.copyWith(color: scheme.onSurface)),
                    content: Text(
                        'Are you sure you want to unmatch? This action cannot be undone.',
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                    actionsAlignment: MainAxisAlignment.center,
                    actions: [
                      ButtonBar(
                        alignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              unmatch(context, ref);
                            },
                            child: Text('Unmatch',
                                style: theme.textTheme.bodyLarge
                                    ?.copyWith(color: scheme.primary)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    12.0), // Adjust the radius as needed
                                color: scheme.primary, // Set the background color
                              ),
                              padding: const EdgeInsets.all(
                                  8.0), // Optional: Add padding for some spacing
                              child: Text(
                                'Cancel',
                                style: theme.textTheme.bodyLarge
                                    ?.copyWith(color: scheme.onPrimary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              icon: Icon(Icons.block, color: scheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
