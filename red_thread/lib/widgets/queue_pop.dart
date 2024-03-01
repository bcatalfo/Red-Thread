import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'timed_border_painter.dart';

class QueuePop extends StatefulWidget {
  final void Function()? onQueueAccepted;
  final void Function()? onQueueDeclined;
  const QueuePop({this.onQueueAccepted, this.onQueueDeclined, super.key});

  @override
  QueuePopState createState() => QueuePopState();
}

class QueuePopState extends State<QueuePop> {
  bool _isQueueAccepted = false;
  bool _isQueueDeclined = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      type: MaterialType.circle,
      color: Theme.of(context).colorScheme.primaryContainer,
      //shape: const OvalBorder(),
      child: CustomPaint(
        foregroundPainter:
            TimedBorderPainter(timeRemaining: 10.0, duration: 10.0),
        child: ClipOval(
            child: Row(
          children: [
            Expanded(
              flex: 2,
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isQueueDeclined = true;
                    });
                  },
                  child: Text(
                    'Decline',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary),
                  )),
            ),
            Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Emma, 22'),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipOval(
                          child: Image.network(
                              'https://i.imgur.com/I42fFXL.jpeg')),
                    ),
                    Text('2 miles away'),
                  ],
                )),
            Expanded(
              flex: 2,
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isQueueAccepted = true;
                    });
                  },
                  child: Text(
                    'Accept',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer),
                  )),
            ),
          ],
        )),
      ),
    );
  }
}
