import 'package:flutter/material.dart';
import 'package:red_thread/presentation/drawer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:red_thread/providers.dart';
//import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class PreviewPage extends ConsumerStatefulWidget {
  const PreviewPage({super.key});

  static const String routeName = '/preview';

  @override
  PreviewPageState createState() => PreviewPageState();
}

class PreviewPageState extends ConsumerState<PreviewPage> {
  //UnityWidgetController? _unityWidgetController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: myDrawer(context, ref),
      appBar: myAppBar(context, ref),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(25.0, 8.0, 8.0, 8.0),
            child: Text(
                'TODO: Replace this with the top bar from the Chat page',
                style: theme.textTheme.displayLarge),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            // TODO: Replace this with the flutter unity widget
            child: Container(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(matchFoundProvider.notifier).state = false;
        },
        child: const Icon(Icons.cancel),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      backgroundColor: theme.colorScheme.surface,
    );
  }
}
