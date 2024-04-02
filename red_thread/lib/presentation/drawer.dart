import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:red_thread/presentation/theme.dart';
import 'package:red_thread/providers.dart';

// TODO: Reorganize this garbage, update the logo code, add it to the widgets folder
//define a drawer called top drawer
Drawer myDrawer(BuildContext context, WidgetRef ref) {
  final theme = Theme.of(context);
  final themeMode = ref.watch(themeModeProvider);

  return Drawer(
    backgroundColor: theme.colorScheme.surfaceVariant,
    child: LayoutBuilder(
      builder: (context, constraints) => Column(
        children: [
          DrawerHeader(
              child: Image.asset('assets/images/iTunesArtwork-1024.png')),
          ListTile(
            leading:
                Icon(Icons.home, size: theme.textTheme.displayMedium?.fontSize),
            title: Text('Home', style: theme.textTheme.displayMedium),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.phone,
                size: theme.textTheme.displayMedium?.fontSize),
            title: Text('Contact Us', style: theme.textTheme.displayMedium),
            onTap: () {
              context.push('/contact_us');
            },
          ),
          ListTile(
            leading:
                Icon(Icons.info, size: theme.textTheme.displayMedium?.fontSize),
            title: Text('About', style: theme.textTheme.displayMedium),
            onTap: () {
              context.push('/about');
            },
          ),
          themeMode == ThemeMode.light
              ? ListTile(
                  leading: Icon(Icons.dark_mode,
                      size: theme.textTheme.displayMedium?.fontSize),
                  title:
                      Text('Dark Mode', style: theme.textTheme.displayMedium),
                  onTap: () {
                    ref.read(themeModeProvider.notifier).state = ThemeMode.dark;
                  })
              : ListTile(
                  leading: Icon(Icons.light_mode,
                      size: theme.textTheme.displayMedium?.fontSize),
                  title:
                      Text('Light Mode', style: theme.textTheme.displayMedium),
                  onTap: () {
                    ref.read(themeModeProvider.notifier).state =
                        ThemeMode.light;
                  },
                ),
          const Spacer(),
          ListTile(
            leading: Icon(Icons.logout,
                size: theme.textTheme.displayMedium?.fontSize),
            title: Text('Log Out', style: theme.textTheme.displayMedium),
            onTap: () {
              // TODO: Actually log out
              ref.read(isAuthenticatedProvider.notifier).state = false;
            },
          ),
          ListTile(
              leading: Icon(Icons.delete,
                  size: theme.textTheme.displayMedium?.fontSize),
              title:
                  Text('Delete Account', style: theme.textTheme.displayMedium),
              onTap: () {
                // Make an alert dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    title: Text('Delete Account?',
                        style: theme.textTheme.headlineMedium),
                    content: Text(
                        'Are you sure you want to delete your account? This action cannot be undone.',
                        style: theme.textTheme.bodyLarge),
                    actionsAlignment: MainAxisAlignment.center,
                    actions: [
                      ButtonBar(
                        alignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              ref.read(isAuthenticatedProvider.notifier).state =
                                  false;
                            },
                            child: Text('Delete',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.primary)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.primary)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          const SizedBox(height: 32),
        ],
      ),
    ),
  );
}

AppBar myAppBar(BuildContext context, WidgetRef ref) {
  final themeMode = ref.watch(themeModeProvider);
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  return AppBar(
    title: Row(
      children: [
        const Spacer(),
        Container(
          width: screenWidth * 0.5,
          height: screenHeight * 0.05,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: themeMode == ThemeMode.light
                ? globalLightScheme.surfaceVariant
                : globalDarkScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text('Red Thread',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
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
