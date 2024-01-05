import 'package:flutter/material.dart';
import 'package:red_thread/presentation/themes.dart';

//define a drawer called top drawer
Widget myDrawer = Drawer(
  backgroundColor: theme.colorScheme.surfaceVariant,
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      DrawerHeader(child: Image.asset('assets/images/heart.png')),
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
);


AppBar myAppBar = AppBar(
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
        );