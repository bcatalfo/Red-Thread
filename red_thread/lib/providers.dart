import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: replace other with non-binary
enum Gender { male, female, other }

enum DateSchedule { notScheduled, sent, received, confirmed }

// TODO: Get this from backend
final matchProvider = StateProvider<String?>((ref) => "Michelle");
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
final needsWelcomingProvider = StateProvider<bool>((ref) => false);
final isAuthenticatedProvider =
    StateProvider<bool>((ref) => FirebaseAuth.instance.currentUser != null);
final isAccountSetupCompleteProvider = StateProvider<bool>((ref) => false);
final isVerifiedProvider = StateProvider<bool>((ref) => false);
final inQueueProvider = StateProvider<bool>((ref) => false);
final whenJoinedQueueProvider = StateProvider<DateTime?>((ref) => null);
final dateTimeProvider = StateProvider<DateTime?>(
    (ref) => DateTime.now().add(const Duration(days: 1)));
final dateLocationProvider = StateProvider<String?>((ref) => "your moms house");
final dateScheduleProvider =
    StateProvider<DateSchedule>((ref) => DateSchedule.received);
