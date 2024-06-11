import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
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

  Future<void> findMatch(BuildContext context, Object? data) async {
    String? user1ID;
    final user1 = await FirebaseDatabase.instance
        .ref('chats/$data/match_info/user1_id')
        .get();
    if (user1.exists) {
      print('user1: ${user1.value}');
      user1ID = user1.value.toString();
    }
    final distance = await FirebaseDatabase.instance
        .ref('chats/$data/match_info/distance')
        .get();
    if (distance.exists) {
      ref.read(matchDistanceProvider.notifier).state =
          double.parse((distance.value as double?)!.toStringAsFixed(1));
    }
    if (user1ID == FirebaseAuth.instance.currentUser!.uid) {
      final user2Age = await FirebaseDatabase.instance
          .ref('chats/$data/match_info/user2_age')
          .get();
      ref.read(matchAgeProvider.notifier).state = user2Age.value as int?;
      final user2Name = await FirebaseDatabase.instance
          .ref('chats/$data/match_info/user2_name')
          .get();
      ref.read(matchProvider.notifier).state = user2Name.value.toString();
      print('matchProvider: ${ref.read(matchProvider)}');
    } else {
      final user1Age = await FirebaseDatabase.instance
          .ref('chats/$data/match_info/user1_age')
          .get();
      ref.read(matchAgeProvider.notifier).state = user1Age.value as int?;
      final user1Name = await FirebaseDatabase.instance
          .ref('chats/$data/match_info/user1_name')
          .get();
      ref.read(matchProvider.notifier).state = user1Name.value.toString();
      print('matchProvider: ${ref.read(matchProvider)}');
    }
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
            FirebaseDatabase.instance
                .ref()
                .child('queue')
                .child(FirebaseAuth.instance.currentUser!.uid)
                .remove();
            ref.read(whenJoinedQueueProvider.notifier).state = null;
            FirebaseAnalytics.instance.logEvent(name: 'exit_queue');
          } else {
            FirebaseDatabase.instance
                .ref()
                .child('queue')
                .child(FirebaseAuth.instance.currentUser!.uid)
                .set(DateTime.now().millisecondsSinceEpoch);
            ref.read(whenJoinedQueueProvider.notifier).state = DateTime.now();
            FirebaseAnalytics.instance.logEvent(name: 'enter_queue');
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
    final matchFound = ref.watch(matchProvider) != null;
    var uid = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference chatRef =
        FirebaseDatabase.instance.ref('users/$uid/chat');
    chatRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data != null) {
        print('data: $data');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          findMatch(context, data);
        });
      }
    });
    /*  // Artificially make a match happen after 5 seconds
    if (!matchFound && secsInQueue > 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        findMatch(context);
      });
    } */

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
