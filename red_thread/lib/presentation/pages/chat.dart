import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:red_thread/presentation/drawer.dart';
import 'package:red_thread/presentation/theme.dart';
import 'package:red_thread/providers.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'dart:async';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends ConsumerState<ChatPage> {
  final _scrollController = ScrollController();
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

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      final position = _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage(String text) {
    final newMessage = ChatMessage(
      message: text,
      author: 'Ben', // TODO: get from backend
      date: DateTime.now(),
    );
    setState(() {
      messages.add(newMessage);
    });
    // wait for the new message to appear before scrolling to the bottom
    // TODO: instead of using a set timeout, use a listener for when the layout is done
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  late StreamSubscription<bool> keyboardSubscription;

  @override
  void initState() {
    super.initState();

    var keyboardVisibilityController = KeyboardVisibilityController();
    // Query
    debugPrint(
        'Keyboard visibility direct query: ${keyboardVisibilityController.isVisible}');

    // Subscribe
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      debugPrint('Keyboard visibility update. Is visible: $visible');
      if (visible) {
        Future.delayed(const Duration(milliseconds: 350), _scrollToBottom);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    keyboardSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(context, ref),
      drawer: myDrawer(context, ref),
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: KeyboardDismissOnTap(
          child: Column(
            children: [
              const MatchBar(),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: messages[index],
                    );
                  },
                ),
              ),
              ChatInputBar(
                onSend: _sendMessage,
              )
            ],
          ),
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
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: _isTyping
                ? const SizedBox()
                : SizedBox(
                    width: 48,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: start video call
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(0),
                      ),
                      child: const Icon(Icons.video_call),
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              keyboardType: TextInputType.multiline,
              controller: _textController,
              minLines: 1,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Type a message",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 48,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(0),
              ),
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
              label: Text('Unmatch',
                  style: theme.textTheme.bodyLarge?.copyWith(
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
                                borderRadius: BorderRadius.circular(12.0),
                                color: scheme.primary,
                              ),
                              padding: const EdgeInsets.all(8.0),
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
