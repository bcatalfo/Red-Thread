import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:red_thread/presentation/drawer.dart';
import 'package:red_thread/presentation/theme.dart';
import 'package:red_thread/providers.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'dart:async';
import 'package:flutter_animate/flutter_animate.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends ConsumerState<ChatPage> {
  final _scrollController = ScrollController();
  var _timestampSize = 0.0;
  final messages = <ChatMessage>[
    ChatMessage(
      message: 'Where do you wanna go?',
      author: Author.you,
      date: DateTime(2024, 5, 9, 12, 2, 0),
    ),
    ChatMessage(
      message: 'Wanna meet up at Central Park?😍',
      author: Author.me,
      date: DateTime(2024, 5, 9, 12, 3, 0),
    ),
    ChatMessage(
      message: 'Let’s get some food first.',
      author: Author.you,
      date: DateTime(2024, 5, 9, 12, 5, 0),
    ),
    ChatMessage(
      message: 'Test alert from the system',
      author: Author.system,
      date: DateTime(2024, 5, 9, 2, 7, 0),
    ),
    // write a long message from Author.you
    ChatMessage(
      message:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed non risus. Suspendisse lectus tortor, dignissim sit amet, adipiscing nec, ultricies sed, dolor. Cras elementum ultrices diam. Maecenas ligula massa, varius a, semper congue, euismod non, mi.',
      author: Author.you,
      date: DateTime(2024, 5, 9, 2, 11, 0),
    ),
    ChatMessage(
      message:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed non risus. Suspendisse lectus tortor, dignissim sit amet, adipiscing nec, ultricies sed, dolor. Cras elementum ultrices diam. Maecenas ligula massa, varius a, semper congue, euismod non, mi.',
      author: Author.me,
      date: DateTime(2024, 5, 9, 2, 13, 0),
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
      author: Author.me, // TODO: get from backend
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
  var _matchBarVisible = true;
  var _dateBarVisible = true;

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
      setState(() {
        _matchBarVisible = !visible;
        _dateBarVisible = !visible;
      });
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
              AnimatedVisibility(
                visible: _matchBarVisible,
                duration: 300.ms,
                child: const MatchBar()
                    .animate(target: _matchBarVisible ? 1 : 0)
                    .fade(duration: 300.ms),
              ),
              Expanded(
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_timestampSize + details.primaryDelta! <= 0 &&
                        (_timestampSize >= -100 || details.primaryDelta! > 0)) {
                      setState(() {
                        _timestampSize += details.primaryDelta!;
                      });
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    Future.delayed(Duration.zero, () async {
                      for (double i = _timestampSize; i <= 0; i += 1) {
                        await Future.delayed(const Duration(milliseconds: 1));
                        setState(() {
                          _timestampSize = i;
                        });
                      }
                      setState(() {
                        _timestampSize = 0;
                      });
                    });
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      switch (messages[index].author) {
                        case Author.me:
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(child: messages[index]),
                              SizedBox(
                                width: _timestampSize.abs(),
                                height: 24,
                                child: Opacity(
                                  opacity: (_timestampSize / -100).clamp(0, 1),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      DateFormat('h:mm a')
                                          .format(messages[index].date),
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          );
                        case Author.you || Author.system:
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(child: messages[index]),
                              SizedBox(
                                width: _timestampSize.abs(),
                                height: 24,
                                child: Opacity(
                                  opacity: (_timestampSize / -100).clamp(0, 1),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      DateFormat('h:mm a')
                                          .format(messages[index].date),
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          );
                      }
                    },
                  ),
                ),
              ),
              ChatInputBar(
                onSend: _sendMessage,
              ),
              AnimatedVisibility(
                visible: _dateBarVisible,
                duration: 100.ms,
                child: DateBar()
                    .animate(target: _dateBarVisible ? 1 : 0)
                    .fade(duration: 100.ms),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedVisibility extends StatefulWidget {
  final Widget child;
  final bool visible;
  final Duration duration;

  const AnimatedVisibility({
    Key? key,
    required this.child,
    required this.visible,
    required this.duration,
  }) : super(key: key);

  @override
  _AnimatedVisibilityState createState() => _AnimatedVisibilityState();
}

class _AnimatedVisibilityState extends State<AnimatedVisibility> {
  late bool _isVisible;

  @override
  void initState() {
    super.initState();
    _isVisible = widget.visible;
  }

  @override
  void didUpdateWidget(AnimatedVisibility oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.visible) {
      setState(() => _isVisible = true);
    } else {
      Future.delayed(widget.duration, () => setState(() => _isVisible = false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: widget.duration,
      opacity: widget.visible ? 1.0 : 0.0,
      child: _isVisible ? widget.child : const SizedBox.shrink(),
    );
  }
}

enum Author { me, you, system }

class ChatBubbleClipperMe extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double arrowWidth = 8.0;
    const double arrowHeight = 8.0;
    const double radius = 16.0;

    Path path = Path()
      ..moveTo(radius, size.height - arrowHeight)
      ..arcToPoint(
        Offset(0, size.height - arrowHeight - radius),
        radius: const Radius.circular(radius),
      )
      ..lineTo(0, radius)
      ..arcToPoint(
        const Offset(radius, 0),
        radius: const Radius.circular(radius),
      )
      ..lineTo(size.width - 2 * arrowWidth - radius, 0)
      ..arcToPoint(
        Offset(size.width - 2 * arrowWidth, radius),
        radius: const Radius.circular(radius),
      )
      ..lineTo(size.width - 2 * arrowWidth, size.height - 2 * arrowHeight)
      ..lineTo(size.width, size.height - arrowHeight)
      ..lineTo(size.width - arrowWidth, size.height - arrowHeight)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class ChatBubbleClipperYou extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double arrowWidth = 8.0;
    const double arrowHeight = 8.0;
    const double radius = 16.0;

    Path path = Path()
      // Start at the top right of the arrow
      ..moveTo(size.width - radius, size.height - arrowHeight)
      ..arcToPoint(Offset(size.width, size.height - arrowHeight - radius),
          radius: const Radius.circular(radius), clockwise: false)
      ..lineTo(size.width, radius) // Right edge
      ..arcToPoint(Offset(size.width - radius, 0),
          radius: const Radius.circular(radius), clockwise: false)
      ..lineTo(2 * arrowWidth + radius, 0) // Top edge
      ..arcToPoint(const Offset(2 * arrowWidth, radius),
          radius: const Radius.circular(radius), clockwise: false)
      ..lineTo(2 * arrowWidth, size.height - 2 * arrowHeight)
      ..lineTo(0, size.height - arrowHeight)
      ..lineTo(arrowWidth, size.height - arrowHeight)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class ChatMessage extends ConsumerWidget {
  final String message;
  final Author author;
  final DateTime date;

  const ChatMessage(
      {Key? key,
      required this.message,
      required this.author,
      required this.date})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    switch (author) {
      case Author.me:
        return ClipPath(
          clipper: ChatBubbleClipperMe(),
          child: Card(
            elevation: 1,
            color: theme.colorScheme.surfaceVariant,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 4.0, 24.0, 8.0),
              child: Text(
                message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        );

      case Author.you:
        return ClipPath(
          clipper: ChatBubbleClipperYou(),
          child: Card(
            elevation: 1,
            color: theme.colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 4.0, 8.0, 8.0),
              child: Text(
                message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        );
      case Author.system:
        return Center(
          child: Card(
            elevation: 1,
            color: theme.colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      default:
        return const SizedBox();
    }
  }
}

class ChatInputBar extends ConsumerStatefulWidget {
  final Function(String) onSend;

  const ChatInputBar({Key? key, required this.onSend}) : super(key: key);

  @override
  ChatInputBarState createState() => ChatInputBarState();
}

class ChatInputBarState extends ConsumerState<ChatInputBar> {
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
    final theme = Theme.of(context);
    final isLight = ref.watch(themeModeProvider) == ThemeMode.light;
    final scheme = isLight ? globalLightScheme : globalDarkScheme;
    final String? match = ref.watch(matchProvider);
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: _isTyping ? const SizedBox() : Container(),
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
          AnimatedSize(
            duration: 200.ms,
            child: _isTyping
                ? SizedBox(
                    width: 48,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(0),
                      ),
                      onPressed: () async {
                        if (_isTyping) {
                          widget.onSend(_textController.text);
                          _textController.clear();
                          // TODO: Send the message to the backend
                        }
                      },
                      child: const Icon(Icons.send,
                          size: 32, key: ValueKey('send')),
                    ),
                  )
                : Container(),
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
    ref.read(matchProvider.notifier).state = null;
    ref.read(inQueueProvider.notifier).state = false;
    ref.read(whenJoinedQueueProvider.notifier).state = null;
    ref.read(isVerifiedProvider.notifier).state = false;
    debugPrint("Unmatch button pressed");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLight = ref.watch(themeModeProvider) == ThemeMode.light;
    final scheme = isLight ? globalLightScheme : globalDarkScheme;
    final String? match = ref.watch(matchProvider);

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
                  '$match',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // TODO: Hook this up with providers
                Text('25, 3.5 miles away', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          TextButton.icon(
            icon: Icon(Icons.block, color: scheme.primary),
            label: Text(
              'Unmatch',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              // Returns you to the queue
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  backgroundColor: scheme.surfaceContainerHigh,
                  title: Center(
                    child: Text('Unmatch with $match?',
                        style: theme.textTheme.headlineMedium
                            ?.copyWith(color: scheme.onSurface)),
                  ),
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
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ReportDialog();
                  },
                );
              },
              icon: Icon(Icons.flag, color: scheme.primary),
              label: Text(
                'Report',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReportDialog extends ConsumerStatefulWidget {
  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends ConsumerState<ReportDialog> {
  final _formKey = GlobalKey<FormState>();
  final Set<String> _selectedReasons = {};
  String? _otherReason;

  void unmatch(WidgetRef ref) {
    ref.read(matchProvider.notifier).state = null;
    ref.read(inQueueProvider.notifier).state = false;
    ref.read(whenJoinedQueueProvider.notifier).state = null;
    ref.read(isVerifiedProvider.notifier).state = false;
    debugPrint("Unmatch after report");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final isLight = ref.watch(themeModeProvider) == ThemeMode.light;
    final scheme = isLight ? globalLightScheme : globalDarkScheme;
    final String? match = ref.watch(matchProvider);

    return AlertDialog(
      backgroundColor: scheme.surfaceContainerHigh,
      title: Center(
        child: Text('Report $match',
            style: theme.headlineMedium?.copyWith(color: scheme.onSurface)),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select the reason(s) for reporting:',
                style: theme.bodyLarge,
              ),
              CheckboxListTile(
                title: Text('Sexual Harassment', style: theme.bodyMedium),
                value: _selectedReasons.contains('Sexual Harassment'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedReasons.add('Sexual Harassment');
                    } else {
                      _selectedReasons.remove('Sexual Harassment');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Disrespecting Privacy', style: theme.bodyMedium),
                value: _selectedReasons.contains('Disrespecting Privacy'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedReasons.add('Disrespecting Privacy');
                    } else {
                      _selectedReasons.remove('Disrespecting Privacy');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Inappropriate Behavior', style: theme.bodyMedium),
                value: _selectedReasons.contains('Inappropriate Behavior'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedReasons.add('Inappropriate Behavior');
                    } else {
                      _selectedReasons.remove('Inappropriate Behavior');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Scamming or Fraud', style: theme.bodyMedium),
                value: _selectedReasons.contains('Scamming or Fraud'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedReasons.add('Scamming or Fraud');
                    } else {
                      _selectedReasons.remove('Scamming or Fraud');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Other', style: theme.bodyMedium),
                value: _selectedReasons.contains('Other'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedReasons.add('Other');
                    } else {
                      _selectedReasons.remove('Other');
                    }
                  });
                },
              ),
              if (_selectedReasons.contains('Other'))
                TextFormField(
                  decoration: InputDecoration(labelText: 'Please specify'),
                  onChanged: (value) {
                    setState(() {
                      _otherReason = value;
                    });
                  },
                  validator: (value) {
                    if (_selectedReasons.contains('Other') &&
                        (value == null || value.isEmpty)) {
                      return 'Please specify the reason';
                    }
                    return null;
                  },
                ),
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel',
                  style: theme.bodyLarge?.copyWith(color: scheme.primary)),
            ),
            const SizedBox(width: 16), // Space between the buttons
            TextButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  unmatch(ref);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Report submitted')),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: scheme.primary,
                ),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Submit',
                  style: theme.bodyLarge?.copyWith(color: scheme.onPrimary),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DateBar extends ConsumerWidget {
  DateBar({Key? key}) : super(key: key);
  final formatter = DateFormat('M/d h:mm a');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLight = ref.watch(themeModeProvider) == ThemeMode.light;
    final scheme = isLight ? globalLightScheme : globalDarkScheme;
    final dateTime = ref.watch(dateTimeProvider);
    final dateLocation = ref.watch(dateLocationProvider);
    final dateSchedule = ref.watch(dateScheduleProvider);

    // TODO: Make it something special when you are on the date
    if (dateSchedule == DateSchedule.confirmed) {
      return dateContainer(
          context, theme, scheme, dateTime!, dateLocation, ref);
    } else if (dateSchedule == DateSchedule.sent) {
      return dateSentContainer(
          context, theme, scheme, dateTime!, dateLocation, ref);
    } else if (dateSchedule == DateSchedule.received) {
      return dateReceivedContainer(
          context, theme, scheme, dateTime!, dateLocation!, ref);
    } else {
      return notScheduledContainer(context, scheme, theme, ref);
    }
  }

  Widget dateContainer(
      BuildContext context,
      ThemeData theme,
      MaterialScheme scheme,
      DateTime dateTime,
      String? dateLocation,
      WidgetRef ref) {
    return Container(
      color: scheme.surfaceContainerHighest,
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              dateDetailsWidget(context, theme, 'Date Time', 'Date Location'),
              dateDetailsWidget(
                  context, theme, formatter.format(dateTime), dateLocation!),
            ],
          ),
          //const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Center(child: Text('Cancel Date')),
                        backgroundColor: scheme.surfaceContainerHigh,
                        content:
                            Text('Are you sure you want to cancel the date?'),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  ref
                                      .read(dateScheduleProvider.notifier)
                                      .update(
                                          (state) => DateSchedule.notScheduled);
                                  Navigator.of(context).pop();
                                },
                                child: Text('Yes',
                                    style: theme.textTheme.bodyLarge
                                        ?.copyWith(color: scheme.primary)),
                              ),
                              const SizedBox(
                                  width: 16), // Space between the buttons
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
                      );
                    },
                  );
                },
                child: Text('Cancel'),
                style: TextButton.styleFrom(
                  backgroundColor: scheme.secondary,
                  foregroundColor: scheme.onSecondary,
                ),
              ),
              const Spacer(), // Add space between the Cancel and Check In buttons
              TextButton(
                onPressed: () {
                  // Placeholder for check-in functionality
                },
                child: Text('Check In'),
                style: TextButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget dateSentContainer(
      BuildContext context,
      ThemeData theme,
      MaterialScheme scheme,
      DateTime dateTime,
      String? dateLocation,
      WidgetRef ref) {
    return Container(
      color: scheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date Time',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatter.format(dateTime),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date Location',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dateLocation!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Your date is pending confirmation...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: scheme.surfaceContainerHigh,
                        title: Text('Cancel Pending Date',
                            style: theme.textTheme.headlineMedium
                                ?.copyWith(color: scheme.onSurface)),
                        content: Text(
                            'Are you sure you want to cancel the pending date?',
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(color: scheme.onSurfaceVariant)),
                        actionsAlignment: MainAxisAlignment.center,
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  ref
                                      .read(dateScheduleProvider.notifier)
                                      .update(
                                          (state) => DateSchedule.notScheduled);
                                  Navigator.of(context).pop();
                                },
                                child: Text('Cancel Date',
                                    style: theme.textTheme.bodyLarge
                                        ?.copyWith(color: scheme.primary)),
                              ),
                              const SizedBox(
                                  width: 16), // Space between the buttons
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
                                    'Close',
                                    style: theme.textTheme.bodyLarge
                                        ?.copyWith(color: scheme.onPrimary),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: scheme.secondary,
                  foregroundColor: scheme.onSecondary,
                ),
                child: Text('Cancel Pending Date',
                    style: TextStyle(color: scheme.onError)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget dateReceivedContainer(
      BuildContext context,
      ThemeData theme,
      MaterialScheme scheme,
      DateTime dateTime,
      String dateLocation,
      WidgetRef ref) {
    return Container(
      color: scheme.surfaceContainerHighest,
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              dateDetailsWidget(context, theme, 'Date Time', 'Date Location'),
              dateDetailsWidget(
                  context, theme, formatter.format(dateTime), dateLocation!),
            ],
          ),
          //const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => ref
                    .read(dateScheduleProvider.notifier)
                    .update((state) => DateSchedule.notScheduled),
                style: TextButton.styleFrom(
                  backgroundColor: scheme.secondary,
                  foregroundColor: scheme.onSecondary,
                ),
                child: Text('Decline', style: TextStyle(color: scheme.onError)),
              ),
              const SizedBox(width: 20), // Space between the buttons
              TextButton(
                onPressed: () => ref
                    .read(dateScheduleProvider.notifier)
                    .update((state) => DateSchedule.confirmed),
                style: TextButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                ),
                child:
                    Text('Accept', style: TextStyle(color: scheme.onPrimary)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget notScheduledContainer(BuildContext context, MaterialScheme scheme,
      ThemeData theme, WidgetRef ref) {
    return Container(
      color: scheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'No date scheduled yet.',
            style: theme.textTheme.titleLarge?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (BuildContext context) => DateDialog(),
              );
            },
            icon: const Icon(Icons.calendar_today),
            label: const Text('Schedule Date'),
            style: ElevatedButton.styleFrom(
              foregroundColor: scheme.onPrimary,
              backgroundColor: scheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: theme.textTheme.labelLarge?.copyWith(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget dateDetailsWidget(
      BuildContext context, ThemeData theme, String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class DateDialog extends ConsumerStatefulWidget {
  const DateDialog({Key? key}) : super(key: key);

  @override
  _DateDialogState createState() => _DateDialogState();
}

class _DateDialogState extends ConsumerState<DateDialog> {
  final locationController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = ref.watch(themeModeProvider) == ThemeMode.light;
    final scheme = isLight ? globalLightScheme : globalDarkScheme;

    return AlertDialog(
      backgroundColor: scheme.surfaceContainerHigh,
      title: Center(
        child: Text('Date Scheduler',
            style: theme.textTheme.headlineMedium
                ?.copyWith(color: scheme.onSurface)),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: "Location"),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (date != null) {
                  setState(() {
                    selectedDate = date;
                  });
                }
              },
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: selectedDate == null
                          ? 'Select Date'
                          : 'Selected date: ',
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    if (selectedDate != null)
                      TextSpan(
                        text:
                            '${selectedDate!.toLocal().month}/${selectedDate!.toLocal().day}/${selectedDate!.toLocal().year}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() {
                    selectedTime = time;
                  });
                }
              },
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: selectedTime == null
                          ? 'Select Time'
                          : 'Selected time: ',
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    if (selectedTime != null)
                      TextSpan(
                        text: '${selectedTime!.format(context)}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (selectedDate != null &&
                    selectedTime != null &&
                    locationController.text.isNotEmpty) {
                  final dateTime = DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                    selectedTime!.hour,
                    selectedTime!.minute,
                  );
                  ref.read(dateTimeProvider.notifier).state = dateTime;
                  ref.read(dateLocationProvider.notifier).state =
                      locationController.text;
                  ref
                      .read(dateScheduleProvider.notifier)
                      .update((state) => DateSchedule.sent);
                  Navigator.of(context).pop();
                } else {
                  // Show an error message
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text(
                            'Please select a date, time, and enter a location.'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Schedule Date'),
            ),
          ],
        ),
      ),
    );
  }
}
