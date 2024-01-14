import 'dart:async';
import 'package:flutter/material.dart';
import 'package:red_thread/presentation/drawer_closed.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:red_thread/providers.dart';
import 'package:go_router/go_router.dart';

final secsInQueueProvider = StateProvider<int>((ref) => 0);
final inQueueProvider = StateProvider<bool>((ref) => false);
const queueOpensAt = TimeOfDay(hour: 23, minute: 00);
const queueClosesAt = TimeOfDay(hour: 23, minute: 35);

class QueuePage extends ConsumerStatefulWidget {
  const QueuePage({super.key});

  @override
  QueuePageState createState() => QueuePageState();
}

class QueuePageState extends ConsumerState<QueuePage> {
  Timer? _inQueueTimer; // increments secsInQueue every second
  Timer? _queueOpensTimer; // updates UI every second

  @override
  void initState() {
    super.initState();
    _queueOpensTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _inQueueTimer?.cancel();
    _queueOpensTimer?.cancel();
    super.dispose();
  }

  // TODO: I may want to change this to display like 03H 21M 52S
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void joinPreview(BuildContext context) {
    _inQueueTimer?.cancel(); // Cancel the timer when navigating away
    _queueOpensTimer?.cancel(); // Cancel the timer when navigating away
    ref.read(secsInQueueProvider.notifier).state = 0; // Reset seconds in queue
    ref.read(inQueueProvider.notifier).state = false; // Reset in queue
    context.go('/preview');
  }

  void findMatch(BuildContext context) {
    // This is a placeholder for getting AWS working with the provider
    ref.read(matchFoundProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    final inQueue = ref.watch(inQueueProvider);
    final secsInQueue = ref.watch(secsInQueueProvider);
    final now = DateTime.now();
    final queueOpen = now.isAfter(DateTime(now.year, now.month, now.day,
            queueOpensAt.hour, queueOpensAt.minute)) &&
        now.isBefore(DateTime(now.year, now.month, now.day, queueClosesAt.hour,
            queueClosesAt.minute));
    final theme = Theme.of(context);
    final matchFound = ref.watch(matchFoundProvider);

    // Artificially make a match happen after 5 seconds
    if (queueOpen && !matchFound && secsInQueue > 5) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        findMatch(context);
      });
    }

    if (matchFound) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        joinPreview(context);
      });
    }

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
      body = prompt(
          'You have been in the queue for ${formatDuration(Duration(seconds: secsInQueue))}',
          'Sit back and relax while we find you a match.');
    } else if (queueOpen) {
      // The queue is open but the user is not in the queue
      body = prompt(
          'The queue is open!', 'Tap the button below to join the queue.');
    } else {
      // The queue is closed
      // TODO: Calculate the 6PM from _queueOpensAt
      final timeUntil = now.isBefore(DateTime(now.year, now.month, now.day,
              queueOpensAt.hour, queueOpensAt.minute))
          ? DateTime(now.year, now.month, now.day, queueOpensAt.hour,
                  queueOpensAt.minute)
              .difference(now)
          : DateTime(now.year, now.month, now.day + 1, queueOpensAt.hour,
                  queueOpensAt.minute)
              .difference(now);
      body = prompt('Queue opens in ${formatDuration(timeUntil)}',
          'The queue opens at 6PM every day.');
    }
    final floatingActionButton = SizedBox(
        width: 100,
        height: 100,
        child: FittedBox(
            child: FloatingActionButton(
          onPressed: () {
            if (inQueue) {
              _inQueueTimer?.cancel();
              ref.watch(secsInQueueProvider.notifier).state = 0; // Reset timer
            } else {
              _inQueueTimer =
                  Timer.periodic(const Duration(seconds: 1), (timer) {
                ref.read(secsInQueueProvider.notifier).state++;
              });
            }
            ref.read(inQueueProvider.notifier).state = !inQueue;
          },
          backgroundColor: queueOpen
              ? theme.colorScheme.primary
              : theme.colorScheme.primary.withOpacity(0.38),
          child: Text(inQueue ? 'Leave Queue' : 'Join Queue',
              style: TextStyle(
                  color: queueOpen
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onPrimary.withOpacity(0.38)),
              textAlign: TextAlign.center),
        )));
    return Scaffold(
      drawer: myDrawer,
      appBar: myAppBar,
      body: body,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: queueOpen ? floatingActionButton : null,
    );
  }
}
