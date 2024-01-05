import 'package:flutter/material.dart';
import 'package:red_thread/presentation/drawer_closed.dart';
import 'package:red_thread/presentation/themes.dart';

// make a stateful widget
class VideoPreview extends StatefulWidget {
  const VideoPreview({Key? key}) : super(key: key);

  @override
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: myDrawer,
        appBar: myAppBar,
        body: Padding(padding: const EdgeInsets.all(25), child: Text('Get lookin snazzy', style: theme.textTheme.displayLarge)),
        backgroundColor: theme.colorScheme.surface,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(
          height: 100.0, // Set your desired height
          width: 100.0, // Set your desired width
          child: FittedBox(
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                'Join Queue',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ));
  }
}
