import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

// TODO: replace other with non-binary
enum Gender { male, female, other }

enum DateSchedule { notScheduled, sent, received, confirmed }

// TODO: Get this from backend
final matchProvider = StateProvider<String?>((ref) => null);
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
final isAuthenticatedProvider = StateProvider<bool>((ref) => false);
final isVerifiedProvider = StateProvider<bool>((ref) => false);
final faceImageProvider = StateProvider<InputImage?>((ref) => null);
final inQueueProvider = StateProvider<bool>((ref) => false);
final whenJoinedQueueProvider = StateProvider<DateTime?>((ref) => null);
final dateTimeProvider = StateProvider<DateTime?>(
    (ref) => DateTime.now().add(const Duration(days: 1)));
final dateLocationProvider = StateProvider<String?>((ref) => "Starbucks");
final dateScheduleProvider =
    StateProvider<DateSchedule>((ref) => DateSchedule.received);
