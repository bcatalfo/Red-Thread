import 'dart:async';
import 'package:flutter/material.dart';
import 'package:red_thread/presentation/drawer_closed.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final secsInQueueProvider = StateProvider<int>((ref) => 0);
final inQueueProvider = StateProvider<bool>((ref) => false);
// const _queueOpensAt = TimeOfDay(hour: 18, minute: 0);
// const _queueClosesAt = TimeOfDay(hour: 20, minute: 0);
const _queueOpensAt = TimeOfDay(hour: 3, minute: 0);
const _queueClosesAt = TimeOfDay(hour: 5, minute: 0);

class QueuePage extends ConsumerStatefulWidget {
  const QueuePage({super.key});

  @override
  QueuePageState createState() => QueuePageState();
}

class QueuePageState extends ConsumerState<QueuePage> {
  Timer? _timer;
  Timer? _queueTimer;

  @override
  void initState() {
    super.initState();
    _queueTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _queueTimer?.cancel();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Duration timeUntil() {
    // If the queue is open this gives the time until it closes
    // If the queue is closed this gives the time until it opens
    final now = DateTime.now();
    final queueOpen = now.isAfter(DateTime(now.year, now.month, now.day,
            _queueOpensAt.hour, _queueOpensAt.minute)) &&
        now.isBefore(DateTime(now.year, now.month, now.day, _queueClosesAt.hour,
            _queueClosesAt.minute));
    if (queueOpen) {
      // Queue is open and hasn't closed yet today
      return now.difference(DateTime(now.year, now.month, now.day,
          _queueClosesAt.hour, _queueClosesAt.minute));
    } else if (now.isBefore(DateTime(now.year, now.month, now.day,
        _queueOpensAt.hour, _queueOpensAt.minute))) {
      // Queue is closed and hasn't opened yet today
      return DateTime(now.year, now.month, now.day,
          _queueOpensAt.hour, _queueOpensAt.minute).difference(now);
    } else {
      // Queue is closed and has closed for the day
      return DateTime(now.year, now.month, now.day + 1,
          _queueOpensAt.hour, _queueOpensAt.minute).difference(now);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inQueue = ref.watch(inQueueProvider);
    final secsInQueue = ref.watch(secsInQueueProvider);
    final now = DateTime.now();
    final queueOpen = now.isAfter(DateTime(now.year, now.month, now.day,
            _queueOpensAt.hour, _queueOpensAt.minute)) &&
        now.isBefore(DateTime(now.year, now.month, now.day, _queueClosesAt.hour,
            _queueClosesAt.minute));
    final theme = Theme.of(context);

    Column prompt(String heading, String subheading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(25.0, 8.0, 8.0, 8.0),
            child: Text(heading, style: theme.textTheme.displayLarge),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25.0, 8.0, 8.0, 8.0),
            child: Text(subheading, style: theme.textTheme.displayMedium),
          )
        ],
      );
    }
    
    Column body;
    if (inQueue) {
      // TODO: Edge case where the queue closes while the user is in queue
      assert(queueOpen);
      body = prompt('You have been in the queue for ${formatDuration(Duration(seconds: secsInQueue))}', 'Sit back and relax while we find you a match.');
    } else if (queueOpen) {
      // The queue is open but the user is not in the queue
      body = prompt('The queue is open!', 'Tap the button below to join the queue.');
    } else {
      // The queue is closed
      // TODO: Calculate the 6PM from _queueOpensAt
      body = prompt('Queue opens in ${formatDuration(timeUntil())}', 'The queue opens at 6PM every day.');
    }
    final floatingActionButton = SizedBox(
      width: 100,
      height: 100,
      child: FittedBox(
        child: FloatingActionButton(
          onPressed: () {
            if (inQueue) {
              _timer?.cancel();
              ref.watch(secsInQueueProvider.notifier).state = 0; // Reset timer
            } else {
              _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
                ref.read(secsInQueueProvider.notifier).state++;
              });
            }
            ref.read(inQueueProvider.notifier).state = !inQueue;
          },
          backgroundColor: queueOpen ? theme.colorScheme.primary : theme.colorScheme.primary.withOpacity(0.38),
          child: Text(inQueue ? 'Leave Queue' : 'Join Queue', style: TextStyle(color: queueOpen ? theme.colorScheme.onPrimary : theme.colorScheme.onPrimary.withOpacity(0.38)), textAlign: TextAlign.center),
          ))
      );
    return Scaffold(
      drawer: myDrawer,
      appBar: myAppBar,
      body: body,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: queueOpen ? floatingActionButton : null,
    );
  }
}
