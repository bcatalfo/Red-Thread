import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:red_thread/providers.dart';
import 'package:red_thread/authentication_service.dart';

// TODO: Reorganize this garbage, update the logo code, add it to the widgets folder
//define a drawer called top drawer
Drawer myDrawer(BuildContext context, WidgetRef ref) {
  final theme = Theme.of(context);
  final themeMode = ref.watch(myThemeProvider).when(
      data: (data) => data,
      error: (_, __) => ThemeMode.light,
      loading: () => ThemeMode.light);
  final authService = AuthenticationService(ref);

  return Drawer(
    backgroundColor: theme.colorScheme.surfaceContainerHighest,
    child: LayoutBuilder(
      builder: (context, constraints) => Column(
        children: [
          DrawerHeader(
            child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Image.asset('assets/images/red thread.png')),
          ),
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
                    ref.read(myThemeProvider.notifier).setTheme(ThemeMode.dark);
                    FirebaseAnalytics.instance
                        .logEvent(name: 'dark_mode_enabled');
                  })
              : ListTile(
                  leading: Icon(Icons.light_mode,
                      size: theme.textTheme.displayMedium?.fontSize),
                  title:
                      Text('Light Mode', style: theme.textTheme.displayMedium),
                  onTap: () {
                    ref
                        .read(myThemeProvider.notifier)
                        .setTheme(ThemeMode.light);
                    FirebaseAnalytics.instance
                        .logEvent(name: "light_mode_enabled");
                  },
                ),
          ListTile(
            leading: Icon(Icons.settings,
                size: theme.textTheme.displayMedium?.fontSize),
            title: Text('Settings', style: theme.textTheme.displayMedium),
            onTap: () {
              context.push('/settings');
            },
          ),
          const Spacer(),
          ListTile(
            leading: Icon(Icons.logout,
                size: theme.textTheme.displayMedium?.fontSize),
            title: Text('Log Out', style: theme.textTheme.displayMedium),
            onTap: authService.logout,
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
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
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
                            onPressed: () async {
                              await FirebaseAuth.instance.currentUser?.delete();
                              FirebaseAnalytics.instance
                                  .logEvent(name: 'user_deleted');
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
  return AppBar(
    title: Row(
      children: [
        const Spacer(),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: Image.asset(
            'assets/images/red thread.png',
            height: 24.0,
          ),
        ),
        const SizedBox(width: 12.0),
        Container(
          alignment: Alignment.center,
          child: const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Text('Red Thread',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffff5757))),
          ),
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
