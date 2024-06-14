import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:red_thread/presentation/drawer.dart';
import 'package:red_thread/providers.dart';

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

  String formatDuration(Duration duration) {
    int days = duration.inDays;
    int hours = duration.inHours.remainder(24);
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    return "$days Days $hours Hours $minutes Minutes $seconds Seconds";
  }

  Column bodyColumn(String heading, String subheading, ThemeData theme,
      {bool isQueueOpen = false}) {
    List<InlineSpan> spanList = [];

    if (!isQueueOpen) {
      subheading.split(' ').asMap().forEach((index, part) {
        if (index % 2 == 0) {
          // Even index, number part
          spanList.add(TextSpan(
            text: part,
            style: theme.textTheme.displayLarge,
          ));
        } else {
          // Odd index, text part
          spanList.add(TextSpan(
            text: ' $part ',
            style: theme.textTheme.bodySmall,
          ));
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(25.0, 8.0, 8.0, 8.0),
          child: Text(heading, style: theme.textTheme.bodyLarge),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(25.0, 8.0, 8.0, 8.0),
          child: isQueueOpen
              ? Text(subheading, style: theme.textTheme.displayLarge)
              : RichText(
                  text: TextSpan(children: spanList),
                ),
        ),
        const SizedBox(
          height: 25,
        ),
      ],
    );
  }

  Widget premiumAd(BuildContext context, double price, bool isLifetime) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Animate(
        effects: [FadeEffect(duration: 500.ms), ScaleEffect(duration: 600.ms)],
        child: Container(
          padding: const EdgeInsets.all(24.0),
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: scheme.onSurface.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tired of long queue times?',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 600.ms).then().scale(),
              const SizedBox(height: 8),
              Text(
                isLifetime
                    ? 'Exclusive offer: Red Thread Lifetime Premium for only \$$price!'
                    : 'Try Red Thread Premium for only \$$price per month!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: scheme.onSurface,
                ),
              ).animate().fadeIn(duration: 800.ms).then().shake(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        ref.read(showAdProvider.notifier).state = false;
                      });
                      FirebaseAnalytics.instance.logEvent(
                        name: 'buy_premium',
                        parameters: {
                          'price': price,
                          'is_lifetime': isLifetime,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: scheme.onPrimary,
                      backgroundColor: scheme.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 12.0),
                    ),
                    child: const Text('Buy'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        ref.read(showAdProvider.notifier).state = false;
                      });
                      FirebaseAnalytics.instance.logEvent(
                        name: 'decline_premium',
                        parameters: {
                          'price': price,
                          'is_lifetime': isLifetime,
                        },
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: scheme.primary,
                      side: BorderSide(color: scheme.primary),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 12.0),
                    ),
                    child: const Text('No Thanks'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
    final theme = Theme.of(context);
    final adInfoAsyncValue = ref.watch(adInfoProvider);
    final showAd = ref.watch(showAdProvider);

    Column body;
    if (inQueue) {
      // Edge case where the queue closes while the user is in queue
      body = Column(
        children: [
          bodyColumn('Time in queue:',
              '${formatDuration(Duration(seconds: secsInQueue))}', theme),
          const SizedBox(height: 20),
          adInfoAsyncValue.when(
            data: (adInfo) {
              if (showAd && adInfo != null && adInfo['showAd']) {
                return premiumAd(
                  context,
                  adInfo['price'],
                  adInfo['isLifetime'] ?? false,
                );
              } else {
                return Container();
              }
            },
            loading: () => Column(
              children: const [
                Center(child: CircularProgressIndicator()),
              ],
            ),
            error: (err, stack) => Column(
              children: [
                Center(child: Text('Error: $err')),
              ],
            ),
          ),
        ],
      );
    } else {
      // The queue is open but the user is not in the queue
      body = bodyColumn('The queue is open!',
          'Tap the button below to join the queue.', theme,
          isQueueOpen: true);
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
