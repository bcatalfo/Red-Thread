import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: replace other with non-binary
enum Gender { male, female, other }

enum DateSchedule { notScheduled, sent, received, confirmed }

// TODO: Get this from backend
final matchFoundProvider = StateProvider<bool>((ref) => true);
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
final isFirstTimeUserProvider = StateProvider<bool>((ref) => false);
final isAuthenticatedProvider = StateProvider<bool>((ref) => true);
final isAccountSetupCompleteProvider = StateProvider<bool>((ref) => true);
final isVerifiedProvider = StateProvider<bool>((ref) => false);
final inQueueProvider = StateProvider<bool>((ref) => false);
final secsInQueueProvider = StateProvider<int>((ref) => 0);
final isQueueVisibleProvider = StateProvider<bool>((ref) => false);
final dateTimeProvider =
    StateProvider<TimeOfDay?>((ref) => TimeOfDay(hour: 12, minute: 0));
final dateLocationProvider = StateProvider<String?>((ref) => "your moms house");
final dateScheduleProvider =
    StateProvider<DateSchedule>((ref) => DateSchedule.received);
