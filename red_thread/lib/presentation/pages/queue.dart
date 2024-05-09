import 'dart:async';
import 'package:flutter/material.dart';
import 'package:red_thread/presentation/drawer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:red_thread/providers.dart';
import 'package:go_router/go_router.dart';

class QueuePage extends ConsumerStatefulWidget {
  const QueuePage({super.key});

  @override
  QueuePageState createState() => QueuePageState();
}

class QueuePageState extends ConsumerState<QueuePage> {
  Timer? timer; // updates UI every second

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    timer?.cancel();
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
    ref.read(matchFoundProvider.notifier).state = true;
  }

  Column bodyColumn(String heading, String subheading, ThemeData theme) {
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
        const SizedBox(
          height: 25,
        ),
      ],
    );
  }

  SizedBox fab(bool inQueue, ThemeData theme) => SizedBox(
      width: 100,
      height: 100,
      child: FittedBox(
          child: FloatingActionButton(
        onPressed: () {
          // if not verified navigate to the verification page
          if (!ref.read(isVerifiedProvider)) {
            context.push('/verification');
            return;
          }
          ref.read(inQueueProvider.notifier).state = !inQueue;
          if (inQueue) {
            ref.read(whenJoinedQueueProvider.notifier).state = null;
          } else {
            ref.read(whenJoinedQueueProvider.notifier).state = DateTime.now();
          }
        },
        backgroundColor: theme.colorScheme.primaryContainer,
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
    final secsInQueue = DateTime.now()
        .difference(ref.read(whenJoinedQueueProvider) ?? DateTime.now())
        .inSeconds;
    final now = DateTime.now();
    final theme = Theme.of(context);
    final matchFound = ref.watch(matchFoundProvider);

    // Artificially make a match happen after 5 seconds
    if (!matchFound && secsInQueue > 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        findMatch(context);
      });
    }

    Column body;
    if (inQueue) {
      // TODO: Edge case where the queue closes while the user is in queue
      body = bodyColumn(
          'You have been in the queue for ${formatDuration(Duration(seconds: secsInQueue))}',
          'Sit back and relax while we find you a match.',
          theme);
    } else {
      // The queue is open but the user is not in the queue
      body = bodyColumn('The queue is open!',
          'Tap the button below to join the queue.', theme);
    }
    final floatingActionButton = fab(inQueue, theme);
    return Scaffold(
      drawer: myDrawer(context, ref),
      appBar: myAppBar(context, ref),
      body: body,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: floatingActionButton,
    );
  }
}
