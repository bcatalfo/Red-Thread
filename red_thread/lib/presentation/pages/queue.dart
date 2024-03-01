import 'dart:async';
import 'package:flutter/material.dart';
import 'package:red_thread/presentation/drawer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:red_thread/providers.dart';
import 'package:red_thread/widgets/widgets.dart';

const queueOpensAt = TimeOfDay(hour: 0, minute: 00);
const queueClosesAt = TimeOfDay(hour: 23, minute: 59);

class QueuePage extends ConsumerStatefulWidget {
  const QueuePage({super.key});

  @override
  QueuePageState createState() => QueuePageState();
}

class QueuePageState extends ConsumerState<QueuePage> {
  Timer? _inQueueTimer; // increments secsInQueue every second
  Timer? _queueOpensTimer; // updates UI every second
  bool _isQueueVisible = false;

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

  void findMatch(BuildContext context) {
    setState(() {
      _isQueueVisible = true;
    });
    // This is a placeholder for getting AWS working with the provider
    ref.read(secsInQueueProvider.notifier).state = 0;
    ref.read(matchFoundProvider.notifier).state = true;
  }

  void acceptMatch(BuildContext context) {
    // wait two seconds for a little animation to play then navigate to the call page
    Future.delayed(const Duration(seconds: 2), () {
      ref.read(inQueueProvider.notifier).state = false;
    });
  }

  Column bodyColumn(
      String heading, String subheading, ThemeData theme, double queuePopSize) {
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
        ),
        Align(
          alignment: Alignment.center,
          child: SizedBox(
              width: queuePopSize,
              height: queuePopSize,
              child: const QueuePop()),
        ),
      ],
    );
  }

  SizedBox fab(bool inQueue, bool queueOpen, ThemeData theme) => SizedBox(
      width: 100,
      height: 100,
      child: FittedBox(
          child: FloatingActionButton(
        onPressed: () {
          if (inQueue) {
            _inQueueTimer?.cancel();
            ref.watch(secsInQueueProvider.notifier).state = 0; // Reset timer
          } else {
            _inQueueTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
              ref.read(secsInQueueProvider.notifier).state++;
            });
          }
          ref.read(inQueueProvider.notifier).state = !inQueue;
        },
        backgroundColor: queueOpen
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.primaryContainer.withOpacity(0.38),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            inQueue
                ? Icon(Icons.cancel,
                    color: theme.colorScheme.onPrimaryContainer)
                : Icon(Icons.arrow_forward,
                    color: theme.colorScheme.onPrimaryContainer),
            Text(inQueue ? 'Leave' : 'Join',
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                textAlign: TextAlign.center),
          ],
        ),
      )));

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
    final queuePopSize = MediaQuery.of(context).size.width * .7;

    // Artificially make a match happen after 5 seconds
    if (queueOpen && !matchFound && secsInQueue > 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        findMatch(context);
      });
    }

    Column body;
    if (inQueue) {
      // TODO: Edge case where the queue closes while the user is in queue
      assert(queueOpen);
      body = bodyColumn(
          'You have been in the queue for ${formatDuration(Duration(seconds: secsInQueue))}',
          'Sit back and relax while we find you a match.',
          theme,
          queuePopSize);
    } else if (queueOpen) {
      // The queue is open but the user is not in the queue
      body = bodyColumn('The queue is open!',
          'Tap the button below to join the queue.', theme, queuePopSize);
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
      body = bodyColumn('Queue opens in ${formatDuration(timeUntil)}',
          'The queue opens at 6PM every day.', theme, queuePopSize);
    }
    final floatingActionButton = fab(inQueue, queueOpen, theme);
    return Scaffold(
      drawer: myDrawer(context, ref),
      appBar: myAppBar(context, ref),
      body: body,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: queueOpen ? floatingActionButton : null,
    );
  }
}
