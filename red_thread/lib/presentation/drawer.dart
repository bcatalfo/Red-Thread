import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:red_thread/presentation/theme.dart';
import 'package:red_thread/providers.dart';

//define a drawer called top drawer
Drawer myDrawer(BuildContext context, WidgetRef ref) {
  final theme = Theme.of(context);
  final themeMode = ref.watch(themeModeProvider);

  return Drawer(
    backgroundColor: theme.colorScheme.surfaceVariant,
    child: ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        DrawerHeader(
            child: Image.asset('assets/images/iTunesArtwork-1024.png')),
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
        themeMode == ThemeMode.light
            ? ListTile(
                leading: Icon(Icons.dark_mode,
                    size: theme.textTheme.displayMedium?.fontSize),
                title: Text('Dark Mode', style: theme.textTheme.displayMedium),
                onTap: () {
                  ref.read(themeModeProvider.notifier).state = ThemeMode.dark;
                })
            : ListTile(
                leading: Icon(Icons.light_mode,
                    size: theme.textTheme.displayMedium?.fontSize),
                title: Text('Light Mode', style: theme.textTheme.displayMedium),
                onTap: () {
                  ref.read(themeModeProvider.notifier).state = ThemeMode.light;
                },
              )
      ],
    ),
  );
}

AppBar myAppBar(BuildContext context, WidgetRef ref) {
  final themeMode = ref.watch(themeModeProvider);

  return AppBar(
    title: Row(
      children: [
        const Spacer(),
        Container(
          width: 289,
          height: 61,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: themeMode == ThemeMode.light
                ? globalLightScheme.surfaceVariant
                : globalDarkScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text('Red Thread',
              style: TextStyle(
                  fontSize: 48,
                  color: themeMode == ThemeMode.light
                      ? globalLightScheme.primary
                      : globalDarkScheme.primary)),
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
}
