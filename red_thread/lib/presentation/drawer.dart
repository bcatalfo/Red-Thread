import 'package:flutter/material.dart';
import 'package:red_thread/presentation/themes.dart';
import 'package:go_router/go_router.dart';

//define a drawer called top drawer
Drawer myDrawer(BuildContext context) {
  final theme = Theme.of(context);

  return Drawer(
    backgroundColor: theme.colorScheme.surfaceVariant,
    child: ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        DrawerHeader(child: Image.asset('assets/images/heart.png')),
        ListTile(
          leading: Icon(Icons.settings,
              size: theme.textTheme.displayMedium?.fontSize),
          title: Text('Settings', style: theme.textTheme.displayMedium),
          onTap: () {
            context.push('/settings');
          },
        ),
        ListTile(
          leading:
              Icon(Icons.phone, size: theme.textTheme.displayMedium?.fontSize),
          title: Text('Contact Us', style: theme.textTheme.displayMedium),
          onTap: () {},
        ),
        ListTile(
          leading:
              Icon(Icons.info, size: theme.textTheme.displayMedium?.fontSize),
          title: Text('About', style: theme.textTheme.displayMedium),
          onTap: () {
            context.push('/about');
          },
        ),
        ListTile(
          leading:
              Icon(Icons.logout, size: theme.textTheme.displayMedium?.fontSize),
          title: Text('Log Out', style: theme.textTheme.displayMedium),
          onTap: () {},
        ),
      ],
    ),
  );
}

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
        child: Text('Red Thread',
            style: TextStyle(fontSize: 48, color: theme.colorScheme.primary)),
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
