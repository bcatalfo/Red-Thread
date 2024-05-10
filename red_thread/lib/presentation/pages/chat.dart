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
  var areTimestampsVisible = true;
  var messages = <ChatMessage>[
    ChatMessage(
      message: 'Where do you wanna go?',
      author: Author.you,
      date: DateTime(2024, 5, 9, 12, 2, 0),
      areTimestampsVisible: true,
    ),
    ChatMessage(
      message: 'Wanna meet up at Central Park?😍',
      author: Author.me,
      date: DateTime(2024, 5, 9, 12, 3, 0),
      areTimestampsVisible: true,
    ),
    ChatMessage(
      message: 'Let’s get some food first.',
      author: Author.you,
      date: DateTime(2024, 5, 9, 12, 5, 0),
      areTimestampsVisible: true,
    ),
    ChatMessage(
        message: 'Test alert from the system',
        author: Author.system,
        date: DateTime.now(),
        areTimestampsVisible: true),
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
      areTimestampsVisible: areTimestampsVisible,
    );
    setState(() {
      messages.add(newMessage);
    });
    // wait for the new message to appear before scrolling to the bottom
    // TODO: instead of using a set timeout, use a listener for when the layout is done
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void hideTimestamps() {
    setState(() {
      areTimestampsVisible = false;
      // replace each message in messages with a new message where areTimestampsVisible is false
      messages.asMap().forEach((index, message) {
        messages[index] = ChatMessage(
            message: message.message,
            author: message.author,
            date: message.date,
            areTimestampsVisible: false);
      });
    });
  }

  void showTimestamps() {
    setState(() {
      areTimestampsVisible = true;
      // replace each message in messages with a new message where areTimestampsVisible is true
      messages.asMap().forEach((index, message) {
        messages[index] = ChatMessage(
            message: message.message,
            author: message.author,
            date: message.date,
            areTimestampsVisible: true);
      });
    });
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
                duration: 100.ms,
                child: MatchBar()
                    .animate(target: _matchBarVisible ? 1 : 0)
                    .fade(duration: 100.ms),
              ),
              Expanded(
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (details.primaryDelta! > 8) {
                      debugPrint('Swiped right');
                      hideTimestamps();
                    } else if (details.primaryDelta! < -8) {
                      debugPrint('Swiped left');
                      showTimestamps();
                    }
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      //var visible = ref.watch(areTimestampsVisibleProvider);
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: messages[index],
                      );
                    },
                  ),
                ),
              ),
              AnimatedVisibility(
                visible: _dateBarVisible,
                duration: 100.ms,
                child: DateBar()
                    .animate(target: _dateBarVisible ? 1 : 0)
                    .fade(duration: 100.ms),
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
      child: _isVisible ? widget.child : SizedBox.shrink(),
    );
  }
}

enum Author { me, you, system }

class ChatBubbleClipperMe extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double arrowWidth = 8.0;
    final double arrowHeight = 8.0;
    final double radius = 16.0;

    Path path = Path()
      ..moveTo(radius, size.height - arrowHeight)
      ..arcToPoint(
        Offset(0, size.height - arrowHeight - radius),
        radius: Radius.circular(radius),
      )
      ..lineTo(0, radius)
      ..arcToPoint(
        Offset(radius, 0),
        radius: Radius.circular(radius),
      )
      ..lineTo(size.width - 2 * arrowWidth - radius, 0)
      ..arcToPoint(
        Offset(size.width - 2 * arrowWidth, radius),
        radius: Radius.circular(radius),
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
    final double arrowWidth = 8.0;
    final double arrowHeight = 8.0;
    final double radius = 16.0;

    Path path = Path()
      // Start at the top right of the arrow
      ..moveTo(size.width - radius, size.height - arrowHeight)
      ..arcToPoint(Offset(size.width, size.height - arrowHeight - radius),
          radius: Radius.circular(radius), clockwise: false)
      ..lineTo(size.width, radius) // Right edge
      ..arcToPoint(Offset(size.width - radius, 0),
          radius: Radius.circular(radius), clockwise: false)
      ..lineTo(2 * arrowWidth + radius, 0) // Top edge
      ..arcToPoint(Offset(2 * arrowWidth, radius),
          radius: Radius.circular(radius), clockwise: false)
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
  final bool areTimestampsVisible;

  const ChatMessage(
      {Key? key,
      required this.message,
      required this.author,
      required this.date,
      required this.areTimestampsVisible})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final DateFormat formatter = DateFormat('h:mm a');

    switch (author) {
      case Author.me:
        return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          ClipPath(
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
          ),
          areTimestampsVisible
              ? Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    formatter.format(date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : const SizedBox(),
        ]);

      case Author.you:
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipPath(
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
              ),
              areTimestampsVisible
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        formatter.format(date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : const SizedBox(),
            ]);
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    formatter.format(date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  Text(
                    message,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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

  void unmatch(BuildContext context, WidgetRef ref) {
    // Add your unmatch button logic here
    ref.read(matchProvider.notifier).state = null;
    debugPrint("Unmatch button pressed");
  }

  void scheduleDate(
      BuildContext context, WidgetRef ref, DateTime time, String location) {
    // TODO: Implement date scheduling
    debugPrint("Date button pressed");
    ref.read(dateTimeProvider.notifier).state = time;
    ref.read(dateLocationProvider.notifier).state = location;
    ref
        .read(dateScheduleProvider.notifier)
        .update((state) => DateSchedule.sent);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = ref.watch(themeModeProvider) == ThemeMode.light;
    final scheme = isLight ? globalLightScheme : globalDarkScheme;
    final String match = ref.watch(matchProvider.notifier).state!;
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: _isTyping
                ? const SizedBox()
                : SizedBox(
                    width: 64,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: () {
                        // Returns you to the queue
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            backgroundColor: scheme.surfaceContainerHigh,
                            title: Text('Unmatch with ${match}?',
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
                                        borderRadius:
                                            BorderRadius.circular(12.0),
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
                      child: const Icon(Icons.block, size: 48),
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
            width: 64,
            height: 64,
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
                  // Schedule a date
                  final _locationController = TextEditingController();
                  TimeOfDay? _selectedTime;

                  showDialog(
                    context: context,
                    builder: (BuildContext context) => StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) =>
                          AlertDialog(
                        backgroundColor: scheme.surfaceContainerHigh,
                        title: Text('Let\'s schedule a date!',
                            style: theme.textTheme.headlineMedium
                                ?.copyWith(color: scheme.onSurface)),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: [
                              TextField(
                                controller: _locationController,
                                decoration:
                                    InputDecoration(labelText: "Location"),
                              ),
                              SizedBox(height: 8),
                              Text(
                                _selectedTime == null
                                    ? 'No time selected.'
                                    : 'Selected time: ${_selectedTime!.format(context)}',
                                style: theme.textTheme.bodyLarge
                                    ?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  ).then((selectedTime) {
                                    if (selectedTime != null) {
                                      _selectedTime = selectedTime;
                                      setState(
                                          () {}); // Call setState to update the UI
                                    }
                                  });
                                },
                                child: Text('Select Time'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (_selectedTime != null &&
                                      _locationController.text.isNotEmpty) {
                                    // TODO: Use the selected time and location
                                    scheduleDate(
                                        context,
                                        ref,
                                        DateTime(
                                            DateTime.now().year,
                                            DateTime.now().month,
                                            DateTime.now().day,
                                            _selectedTime!.hour,
                                            _selectedTime!.minute),
                                        _locationController.text);
                                    Navigator.of(context).pop();
                                  } else {
                                    // Show an error message
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Error'),
                                          content: Text(
                                              'Please select a time and enter a location.'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text('OK'),
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
                                child: Text('Schedule Date'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isTyping
                    ? const Icon(Icons.send, size: 48, key: ValueKey('send'))
                    : const Icon(Icons.calendar_month,
                        size: 48, key: ValueKey('schedule date')),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLight = ref.watch(themeModeProvider) == ThemeMode.light;
    final scheme = isLight ? globalLightScheme : globalDarkScheme;
    final String match = ref.watch(matchProvider.notifier).state!;

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
                  '${match}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('25, 3.5 miles away', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: RichText(
                text: TextSpan(
                  text: 'Time Left: ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                        text: '2:30',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              )),
        ],
      ),
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

    if (dateSchedule == DateSchedule.confirmed) {
      return dateContainer(context, theme, scheme, dateTime!, dateLocation);
    } else if (dateSchedule == DateSchedule.sent) {
      return dateSentContainer(context, theme, scheme, dateTime!, dateLocation);
    } else if (dateSchedule == DateSchedule.received) {
      return dateReceivedContainer(
          context, theme, scheme, dateTime!, dateLocation!, ref);
    } else {
      return notScheduledContainer(context, scheme, theme);
    }
  }

  Widget dateContainer(BuildContext context, ThemeData theme,
      MaterialScheme scheme, DateTime dateTime, String? dateLocation) {
    return Container(
      color: scheme.surfaceContainerHighest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          dateDetailsWidget(context, theme, 'Date Time', 'Date Location'),
          dateDetailsWidget(
              context, theme, formatter.format(dateTime), dateLocation!),
        ],
      ),
    );
  }

  Widget dateSentContainer(BuildContext context, ThemeData theme,
      MaterialScheme scheme, DateTime dateTime, String? dateLocation) {
    return Container(
      color: scheme.surfaceContainerHighest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          dateDetailsWidget(context, theme, 'Date Time', 'Date Location'),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                dateDetailsWidget(
                    context, theme, formatter.format(dateTime), dateLocation!),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                  ),
                ),
              ],
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
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Date Time:',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                formatter.format(dateTime),
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Date Location:',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                dateLocation,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => ref
                    .read(dateScheduleProvider.notifier)
                    .update((state) => DateSchedule.notScheduled),
                child: Text('Decline', style: TextStyle(color: scheme.onError)),
                style: TextButton.styleFrom(backgroundColor: scheme.error),
              ),
              SizedBox(width: 20), // Space between the buttons
              TextButton(
                onPressed: () => ref
                    .read(dateScheduleProvider.notifier)
                    .update((state) => DateSchedule.confirmed),
                child:
                    Text('Accept', style: TextStyle(color: scheme.onPrimary)),
                style: TextButton.styleFrom(backgroundColor: scheme.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget notScheduledContainer(
      BuildContext context, MaterialScheme scheme, ThemeData theme) {
    return Container(
      color: scheme.surfaceContainerHighest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          dateDetailsWidget(context, theme, 'Date Time', 'Date Location'),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Not Scheduled Yet',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.bold,
              ),
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
