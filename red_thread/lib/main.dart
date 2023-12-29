import 'package:flutter/material.dart';
import 'package:red_thread/presentation/pages/main_page.dart';
//import 'models/ModelProvider.dart';

void main() async {
  runApp(const MainApp());
}

class BagoolApp extends StatelessWidget {
  const BagoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Red Thread',
      home: Center(child: Text('Red Thread')),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.red,
                ),
                child: Text('Red Thread'),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Contact Us'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('About'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Log Out'),
                onTap: () {},
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: const Text('Red Thread'),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        ),
        body: MainPage(title: 'Red Thread'),
      ),
      theme: ThemeData.from(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.red,
          backgroundColor: Colors.white,
        ),
      ).copyWith(
        indicatorColor: Colors.red,
      ),
      // set the dark theme (optional)
      darkTheme: ThemeData.from(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.red,
          backgroundColor: Colors.black,
          brightness: Brightness.dark,
        ),
      ),
      // set the theme mode to respond to the user's system preferences (optional)
      themeMode: ThemeMode.system,
    );
  }
}
