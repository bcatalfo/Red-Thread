import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:red_thread/presentation/drawer.dart';
import 'package:red_thread/presentation/theme.dart';
import 'package:red_thread/providers.dart'; // Adjust this import based on your file structure

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends ConsumerState<ChatPage> {
  final _scrollController = ScrollController();
  var _timestampSize = 0.0;

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
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Handle the case where the user is not authenticated
      return;
    }

    final newMessage = ChatMessageModel(
      message: text,
      author: currentUser.uid,
      date: DateTime.now(),
    );

    ref.read(chatMessagesProvider.notifier).addMessage(newMessage);

    FirebaseAnalytics.instance.logEvent(
      name: "send_message",
      parameters: {
        "message": text,
      },
    );
  }

  late StreamSubscription<bool> keyboardSubscription;
  var _dateBarVisible = true;

  @override
  void initState() {
    super.initState();

    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      if (visible) {
        Future.delayed(const Duration(milliseconds: 350), _scrollToBottom);
      }
      setState(() {
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

  Widget _buildDateSeparator(DateTime date) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          DateFormat('EEEE, MMM d').format(date),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);

    ref.listen<AsyncValue<List<ChatMessageModel>?>>(chatMessagesProvider,
        (previous, next) {
      if (next is AsyncData && previous != next) {
        ref.read(chatMessagesProvider.notifier).setMessages(next.value ?? []);
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      }
    });

    return Scaffold(
      appBar: myAppBar(context, ref),
      drawer: myDrawer(context, ref),
      resizeToAvoidBottomInset: true,
      body: messages.when(
        data: (messages) {
          final sortedMessages = List<ChatMessageModel>.from(messages!)
            ..sort((a, b) => a.date.compareTo(b.date));
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: KeyboardDismissOnTap(
              child: Column(
                children: [
                  const MatchBar(),
                  Expanded(
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        if (_timestampSize + details.primaryDelta! <= 0 &&
                            (_timestampSize >= -100 ||
                                details.primaryDelta! > 0)) {
                          setState(() {
                            _timestampSize += details.primaryDelta!;
                          });
                        }
                      },
                      onHorizontalDragEnd: (details) {
                        Future.delayed(Duration.zero, () async {
                          for (double i = _timestampSize; i <= 0; i += 1) {
                            await Future.delayed(
                                const Duration(milliseconds: 1));
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
                        itemCount: sortedMessages.length,
                        itemBuilder: (context, index) {
                          List<Widget> messageWidgets = [];
                          if (index == 0 ||
                              sortedMessages[index].date.day !=
                                  sortedMessages[index - 1].date.day) {
                            messageWidgets.add(_buildDateSeparator(
                                sortedMessages[index].date));
                          }
                          messageWidgets
                              .add(_buildMessageWidget(sortedMessages[index]));

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: messageWidgets,
                          );
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildMessageWidget(ChatMessageModel messageModel) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Handle the case where the user is not authenticated
      return const SizedBox.shrink();
    }

    Author author;
    if (messageModel.author == "system") {
      author = Author.system;
    } else if (messageModel.author == currentUser.uid) {
      author = Author.me;
    } else {
      author = Author.you;
    }

    final message = ChatMessage(
      message: messageModel.message,
      author: author,
      date: messageModel.date,
    );

    switch (author) {
      case Author.me:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(child: message),
            SizedBox(
              width: _timestampSize.abs(),
              height: 24,
              child: Opacity(
                opacity: (_timestampSize / -100).clamp(0, 1),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    DateFormat('h:mm a').format(message.date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
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
            Flexible(child: message),
            SizedBox(
              width: _timestampSize.abs(),
              height: 24,
              child: Opacity(
                opacity: (_timestampSize / -100).clamp(0, 1),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    DateFormat('h:mm a').format(message.date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            )
          ],
        );
    }
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

class ChatMessage extends StatelessWidget {
  final String message;
  final Author author;
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
    final isLight = Theme.of(context).brightness == Brightness.light;

    switch (author) {
      case Author.me:
        return ClipPath(
          clipper: ChatBubbleClipperMe(),
          child: Container(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 4.0, 24.0, 12.0),
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
          child: Container(
            color: isLight ? Colors.grey[200] : Colors.grey[800],
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 4.0, 8.0, 12.0),
              child: Text(
                message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isLight ? Colors.grey[800] : Colors.grey[200],
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
                textAlign: TextAlign.center,
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

  void unmatch(BuildContext context, WidgetRef ref) async {
    final name = await ref.read(myNameProvider.future);
    final leftMessage = ChatMessageModel(
      message: '$name has unmatched with you',
      author: 'system',
      date: DateTime.now(),
    );
    ref.read(chatMessagesProvider.notifier).addMessage(leftMessage);
    ref.read(chatIdProvider.notifier).unmatch();
    FirebaseAnalytics.instance.logEvent(name: 'unmatch');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLight = ref.watch(myThemeProvider).maybeWhen(
        data: (theme) => theme == ThemeMode.light, orElse: () => true);
    final scheme = isLight ? globalLightScheme : globalDarkScheme;
    final match = ref.watch(matchNameProvider);
    final age = ref.watch(matchAgeProvider);
    final distance = ref.watch(matchDistanceProvider);

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
                match.when(
                  data: (match) => Text(
                    '$match',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                ),
                age.when(
                  data: (age) => distance.when(
                    data: (distance) => Text(
                        '$age, ${distance?.toStringAsFixed(1)} miles away',
                        style: theme.textTheme.bodySmall),
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => Text('Error: $e'),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                ),
              ],
            ),
          ),
          PopupMenuButton<int>(
            icon: Icon(Icons.more_vert, color: scheme.primary),
            color: scheme.surfaceContainerHigh,
            onSelected: (int result) {
              if (result == 1) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: scheme.surfaceContainerHigh,
                      title: Center(
                        child: match.when(
                          data: (match) => Text('Unmatch with $match?',
                              style: theme.textTheme.headlineMedium
                                  ?.copyWith(color: scheme.onSurface)),
                          error: (e, _) => Text('Error: $e'),
                          loading: () => const CircularProgressIndicator(),
                        ),
                      ),
                      content: Text(
                          'Are you sure you want to unmatch? This action cannot be undone.',
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(color: scheme.onSurfaceVariant)),
                      actionsAlignment: MainAxisAlignment.center,
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    );
                  },
                );
              } else if (result == 2) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const ReportDialog();
                  },
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              PopupMenuItem<int>(
                value: 1,
                child: ListTile(
                  leading: Icon(Icons.block, color: scheme.onSurface),
                  title: Text('Unmatch',
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: scheme.onSurface)),
                ),
              ),
              PopupMenuItem<int>(
                value: 2,
                child: ListTile(
                  leading: Icon(Icons.flag, color: scheme.onSurface),
                  title: Text('Report',
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: scheme.onSurface)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ReportDialog extends ConsumerStatefulWidget {
  const ReportDialog({Key? key}) : super(key: key);

  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends ConsumerState<ReportDialog> {
  final _formKey = GlobalKey<FormState>();
  final Set<String> _selectedReasons = {};
  String? _otherReason;

  void unmatch(WidgetRef ref) async {
    final name = await ref.read(myNameProvider.future);
    final leftMessage = ChatMessageModel(
      message: '$name has unmatched with you',
      author: 'system',
      date: DateTime.now(),
    );
    ref.read(chatMessagesProvider.notifier).addMessage(leftMessage);
    ref.read(chatIdProvider.notifier).unmatch();
    FirebaseAnalytics.instance.logEvent(name: 'unmatch_after_report');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final isLight = ref.watch(myThemeProvider).maybeWhen(
        data: (theme) => theme == ThemeMode.light, orElse: () => true);
    final scheme = isLight ? globalLightScheme : globalDarkScheme;
    final match = ref.watch(matchNameProvider).when(
        data: (data) => data,
        error: (e, _) => Text(e.toString()),
        loading: () => const CircularProgressIndicator());

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
                  decoration:
                      const InputDecoration(labelText: 'Please specify'),
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
                    const SnackBar(content: Text('Report submitted')),
                  );
                  // TODO: Add User ID to the report (of reported user)
                  // TODO: Maybe upload to database
                  FirebaseAnalytics.instance.logEvent(
                    name: 'report_user',
                    parameters: {
                      'reason1': _selectedReasons.isNotEmpty
                          ? _selectedReasons.elementAt(0)
                          : '',
                      'reason2': _selectedReasons.length > 1
                          ? _selectedReasons.elementAt(1)
                          : '',
                      'reason3': _selectedReasons.length > 2
                          ? _selectedReasons.elementAt(2)
                          : '',
                      'reason4': _selectedReasons.length > 3
                          ? _selectedReasons.elementAt(3)
                          : '',
                      'reason5': _selectedReasons.length > 4
                          ? _selectedReasons.elementAt(4)
                          : '',
                      'other_reason': _otherReason ?? '',
                    },
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
    final isLight = ref.watch(myThemeProvider).maybeWhen(
        data: (theme) => theme == ThemeMode.light, orElse: () => true);
    final scheme = isLight ? globalLightScheme : globalDarkScheme;
    final dateScheduleState = ref.watch(dateScheduleProvider);

    return dateScheduleState.when(
      data: (dateSchedule) {
        dateSchedule = dateSchedule!;
        final dateTime = dateSchedule.dateTime;
        final dateLocation = dateSchedule.dateLocation;

        if (dateSchedule.status == DateScheduleStatus.confirmed ||
            dateSchedule.status == DateScheduleStatus.onDate) {
          return dateContainer(context, theme, scheme, dateTime!, dateLocation,
              dateSchedule.status == DateScheduleStatus.onDate, ref);
        } else if (dateSchedule.status == DateScheduleStatus.sent) {
          return dateSentContainer(
              context, theme, scheme, dateTime!, dateLocation, ref);
        } else if (dateSchedule.status == DateScheduleStatus.received) {
          return dateReceivedContainer(
              context, theme, scheme, dateTime!, dateLocation!, ref);
        } else {
          return notScheduledContainer(context, scheme, theme, ref);
        }
      },
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
    );
  }

  Widget dateContainer(
      BuildContext context,
      ThemeData theme,
      MaterialScheme scheme,
      DateTime dateTime,
      String? dateLocation,
      bool hasCheckedIn,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Center(child: Text('Cancel Date')),
                        backgroundColor: scheme.surfaceContainerHigh,
                        content: const Text(
                            'Are you sure you want to cancel the date?'),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  ref
                                      .read(dateScheduleProvider.notifier)
                                      .setDateSchedule(
                                          DateScheduleStatus.notScheduled);
                                  ref
                                      .read(dateScheduleProvider.notifier)
                                      .setDateScheduleForMatch(
                                          DateScheduleStatus.notScheduled);
                                  Navigator.of(context).pop();

                                  final newMessage = ChatMessageModel(
                                    message: "Date canceled",
                                    author: "system",
                                    date: DateTime.now(),
                                  );

                                  ref
                                      .read(chatMessagesProvider.notifier)
                                      .addMessage(newMessage);

                                  FirebaseAnalytics.instance.logEvent(
                                    name: 'date_canceled',
                                  );
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
                                    'No',
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
                child: const Text('Cancel'),
              ),
              const Spacer(), // Add space between the Cancel and Check In buttons
              TextButton(
                onPressed: () {
                  if (hasCheckedIn) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Center(child: Text('End Date')),
                            backgroundColor: scheme.surfaceContainerHigh,
                            content: const Text(
                                'Are you sure you want to end the date?'),
                            actions: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      ref
                                          .read(dateScheduleProvider.notifier)
                                          .setDateSchedule(
                                              DateScheduleStatus.notScheduled);

                                      Navigator.of(context).pop();

                                      ref
                                          .read(surveyDueProvider.notifier)
                                          .setSurveyDue(true);

                                      FirebaseAnalytics.instance.logEvent(
                                        name: 'date_ended',
                                      );
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
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        color: scheme.primary,
                                      ),
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'No',
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(color: scheme.onPrimary),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        });
                  } else {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Center(child: Text('Check In')),
                            backgroundColor: scheme.surfaceContainerHigh,
                            content: const Text(
                                'Are you sure you want to check in to the date? This means that you are at the location and will notify your match that you are there.'),
                            actions: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      ref
                                          .read(dateScheduleProvider.notifier)
                                          .setDateSchedule(
                                              DateScheduleStatus.onDate);
                                      Navigator.of(context).pop();
                                      var name =
                                          await ref.read(myNameProvider.future);
                                      final newMessage = ChatMessageModel(
                                        message: "$name has checked in",
                                        author: "system",
                                        date: DateTime.now(),
                                      );

                                      ref
                                          .read(chatMessagesProvider.notifier)
                                          .addMessage(newMessage);

                                      // Log the event
                                      FirebaseAnalytics.instance.logEvent(
                                        name: 'date_checked_in',
                                      );
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
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        color: scheme.primary,
                                      ),
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'No',
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(color: scheme.onPrimary),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        });
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                ),
                child: hasCheckedIn
                    ? const Text('End Date')
                    : const Text("I'm Here"),
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
          Center(
            child: TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: scheme.surfaceContainerHigh,
                      title: Center(
                        child: Text('Cancel Pending Date',
                            style: theme.textTheme.headlineMedium
                                ?.copyWith(color: scheme.onSurface)),
                      ),
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
                                    .setDateSchedule(
                                        DateScheduleStatus.notScheduled);
                                ref
                                    .read(dateScheduleProvider.notifier)
                                    .setDateScheduleForMatch(
                                        DateScheduleStatus.notScheduled);
                                Navigator.of(context).pop();

                                final newMessage = ChatMessageModel(
                                  message: "Pending date canceled",
                                  author: "system",
                                  date: DateTime.now(),
                                );

                                // Update local state
                                ref
                                    .read(chatMessagesProvider.notifier)
                                    .addMessage(newMessage);

                                // Log the event
                                FirebaseAnalytics.instance.logEvent(
                                  name: 'pending_date_canceled',
                                );
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
                                  'No',
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
                  context, theme, formatter.format(dateTime), dateLocation),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  ref
                      .read(dateScheduleProvider.notifier)
                      .setDateSchedule(DateScheduleStatus.notScheduled);
                  ref
                      .read(dateScheduleProvider.notifier)
                      .setDateScheduleForMatch(DateScheduleStatus.notScheduled);

                  final newMessage = ChatMessageModel(
                    message: "Date declined",
                    author: "system",
                    date: DateTime.now(),
                  );

                  // Update local state
                  ref
                      .read(chatMessagesProvider.notifier)
                      .addMessage(newMessage);

                  // Log the event
                  FirebaseAnalytics.instance.logEvent(
                    name: 'date_declined',
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: scheme.secondary,
                  foregroundColor: scheme.onSecondary,
                ),
                child: Text('Decline', style: TextStyle(color: scheme.onError)),
              ),
              const SizedBox(width: 20), // Space between the buttons
              TextButton(
                onPressed: () {
                  ref
                      .read(dateScheduleProvider.notifier)
                      .setDateSchedule(DateScheduleStatus.confirmed);
                  ref
                      .read(dateScheduleProvider.notifier)
                      .setDateScheduleForMatch(DateScheduleStatus.confirmed);

                  final newMessage = ChatMessageModel(
                    message: "Date accepted",
                    author: "system",
                    date: DateTime.now(),
                  );

                  ref
                      .read(chatMessagesProvider.notifier)
                      .addMessage(newMessage);

                  FirebaseAnalytics.instance.logEvent(
                    name: 'date_accepted',
                  );
                },
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
                builder: (BuildContext context) => const DateDialog(),
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
    final isLight = ref.watch(myThemeProvider).maybeWhen(
        data: (theme) => theme == ThemeMode.light, orElse: () => true);
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
                  lastDate: DateTime.now().add(const Duration(days: 32)),
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
                        text: selectedTime!.format(context),
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
                  ref.read(dateScheduleProvider.notifier).setDateTime(dateTime);
                  var formatter = DateFormat('EEEE, MMMM d, h:mm a');
                  ref
                      .read(dateScheduleProvider.notifier)
                      .setLocation(locationController.text);
                  ref
                      .read(dateScheduleProvider.notifier)
                      .setDateSchedule(DateScheduleStatus.sent);
                  ref
                      .read(dateScheduleProvider.notifier)
                      .setDateScheduleForMatch(DateScheduleStatus.received);

                  final newMessage = ChatMessageModel(
                    message:
                        "Date requested at ${locationController.text}, ${formatter.format(dateTime)}",
                    author: "system",
                    date: DateTime.now(),
                  );

                  ref
                      .read(chatMessagesProvider.notifier)
                      .addMessage(newMessage);

                  FirebaseAnalytics.instance.logEvent(
                    name: 'date_requested',
                    parameters: {
                      'date_time': formatter.format(dateTime),
                      'location': locationController.text,
                    },
                  );
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
