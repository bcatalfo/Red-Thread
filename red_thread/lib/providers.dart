import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:red_thread/presentation/pages/chat.dart';

// TODO: replace other with non-binary
enum Gender { male, female, other }

enum DateSchedule { notScheduled, sent, received, confirmed, onDate }

// TODO: Get this from backend
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
final isAuthenticatedProvider = StreamProvider<bool>((ref) =>
    FirebaseAuth.instance.authStateChanges().map((user) => user != null));
final isVerifiedProvider = StateProvider<bool>((ref) => false);
final isSurveyDueProvider = StateProvider<bool>((ref) => false);
final faceImageProvider = StateProvider<InputImage?>((ref) => null);
final inQueueProvider = StateProvider<bool>((ref) => false);
final whenJoinedQueueProvider = StateProvider<DateTime?>((ref) => null);
final dateTimeProvider =
    StateProvider<DateTime?>((ref) => DateTime(2024, 6, 5, 17, 0));
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
final chatIdProvider = StreamProvider<String?>((ref) {
  var uid = FirebaseAuth.instance.currentUser!.uid;
  DatabaseReference chatRef = FirebaseDatabase.instance.ref('users/$uid/chat');
  return chatRef.onValue.map((event) => event.snapshot.value as String?);
});

final matchNameProvider = StreamProvider<String?>((ref) {
  final chatIdAsyncValue = ref.watch(chatIdProvider);

  final controller = StreamController<String?>();

  chatIdAsyncValue.whenData((chatId) {
    if (chatId == null) {
      controller.add(null);
      return;
    }

    var uid = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference matchInfoRef =
        FirebaseDatabase.instance.ref('chats/$chatId/match_info');
    matchInfoRef.onValue.listen((event) {
      final matchInfo = event.snapshot.value as Map<dynamic, dynamic>;
      final user1Id = matchInfo['user1_id'];
      final user2Name = matchInfo['user2_name'] as String;
      final user1Name = matchInfo['user1_name'] as String;
      controller.add((user1Id == uid) ? user2Name : user1Name);
    });
  });

  ref.onDispose(() {
    controller.close();
  });

  return controller.stream;
});

final matchAgeProvider = StreamProvider<int?>((ref) {
  final chatIdAsyncValue = ref.watch(chatIdProvider);

  final controller = StreamController<int?>();

  chatIdAsyncValue.whenData((chatId) {
    if (chatId == null) {
      controller.add(null);
      return;
    }

    var uid = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference matchInfoRef =
        FirebaseDatabase.instance.ref('chats/$chatId/match_info');
    matchInfoRef.onValue.listen((event) {
      final matchInfo = event.snapshot.value as Map<dynamic, dynamic>;
      final user1Id = matchInfo['user1_id'];
      final user2Age = matchInfo['user2_age'] as int;
      final user1Age = matchInfo['user1_age'] as int;
      controller.add((user1Id == uid) ? user2Age : user1Age);
    });
  });

  ref.onDispose(() {
    controller.close();
  });

  return controller.stream;
});

final matchDistanceProvider = StreamProvider<double?>((ref) {
  final chatIdAsyncValue = ref.watch(chatIdProvider);

  final controller = StreamController<double?>();

  chatIdAsyncValue.whenData((chatId) {
    if (chatId == null) {
      controller.add(null);
      return;
    }

    DatabaseReference matchDistanceRef =
        FirebaseDatabase.instance.ref('chats/$chatId/match_info/distance');
    matchDistanceRef.onValue.listen((event) {
      controller.add(event.snapshot.value as double?);
    });
  });

  ref.onDispose(() {
    controller.close();
  });

  return controller.stream;
});

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
        message: 'Date requested at Starbucks, Wednesday, June 5, 5:00 PM.',
        author: Author.system,
        date: DateTime(2024, 5, 9, 12, 6, 0),
      ),
    ]);
