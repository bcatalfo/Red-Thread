import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:red_thread/presentation/pages/chat.dart';

// TODO: replace other with non-binary
enum Gender { male, female, other }

enum DateSchedule { notScheduled, sent, received, confirmed }

// TODO: Get this from backend
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
final isAuthenticatedProvider = StateProvider<bool>((ref) => true);
final isVerifiedProvider = StateProvider<bool>((ref) => true);
final isDayAfterDateProvider = StateProvider<bool>((ref) => false);
final faceImageProvider = StateProvider<InputImage?>((ref) => null);
final inQueueProvider = StateProvider<bool>((ref) => false);
final whenJoinedQueueProvider = StateProvider<DateTime?>((ref) => null);
final dateTimeProvider = StateProvider<DateTime?>(
    (ref) => DateTime.now().add(const Duration(days: 1)));
final dateLocationProvider = StateProvider<String?>((ref) => "Starbucks");
final dateScheduleProvider =
    StateProvider<DateSchedule>((ref) => DateSchedule.received);

// New providers for settings
final selectedGendersProvider =
    StateProvider<Set<Gender>>((ref) => {Gender.female});
final maxDistanceProvider = StateProvider<double>((ref) => 50);
final ageRangeProvider =
    StateProvider<RangeValues>((ref) => const RangeValues(18, 30));

// Match details providers
final matchProvider = StateProvider<String?>((ref) => "Emma");
final matchAgeProvider = StateProvider<int?>((ref) => 21);
final matchDistanceProvider = StateProvider<double?>((ref) => 7.5);
final chatMessagesProvider = StateProvider<List<ChatMessage>>((ref) => [
      ChatMessage(
        message: 'Where do you wanna go?',
        author: Author.you,
        date: DateTime(2024, 5, 9, 12, 2, 0),
      ),
      ChatMessage(
        message: 'Wanna meet up at Central Park?😍',
        author: Author.me,
        date: DateTime(2024, 5, 9, 12, 3, 0),
      ),
      ChatMessage(
        message: 'Let’s get some food first.',
        author: Author.you,
        date: DateTime(2024, 5, 9, 12, 5, 0),
      ),
      ChatMessage(
        message: 'Test alert from the system',
        author: Author.system,
        date: DateTime(2024, 5, 9, 2, 7, 0),
      ),
      // write a long message from Author.you
      ChatMessage(
        message:
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed non risus. Suspendisse lectus tortor, dignissim sit amet, adipiscing nec, ultricies sed, dolor. Cras elementum ultrices diam. Maecenas ligula massa, varius a, semper congue, euismod non, mi.',
        author: Author.you,
        date: DateTime(2024, 5, 9, 2, 11, 0),
      ),
      ChatMessage(
        message:
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed non risus. Suspendisse lectus tortor, dignissim sit amet, adipiscing nec, ultricies sed, dolor. Cras elementum ultrices diam. Maecenas ligula massa, varius a, semper congue, euismod non, mi.',
        author: Author.me,
        date: DateTime(2024, 5, 9, 2, 13, 0),
      ),
    ]);
