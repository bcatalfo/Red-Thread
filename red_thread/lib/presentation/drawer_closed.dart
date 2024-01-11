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
          title: Row(
            children: [
              const Spacer(),
              Container(
                width: 289,
                height: 61,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: extendedTheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text('Red Thread', style: TextStyle(fontSize: 48, color: theme.colorScheme.primary)),
              ),
            ],
          ),
          leading: Builder(
            builder: (BuildContext context) {
              return Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: IconButton(
                  iconSize: 64,
                  icon: const Icon(Icons.menu, size: 40),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  alignment: Alignment.centerLeft,
                ),
              );
            },
          ),
        );