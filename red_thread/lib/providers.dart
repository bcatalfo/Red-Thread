import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:red_thread/presentation/pages/chat.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'providers.g.dart';

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

// Ad providers
final showAdProvider = StateProvider<bool>((ref) => true);

final adInfoProvider = StreamProvider.autoDispose<Map<String, dynamic>>((ref) {
  var uid = FirebaseAuth.instance.currentUser!.uid;
  DatabaseReference adInfoRef =
      FirebaseDatabase.instance.ref('users/$uid/adInfo');
  return adInfoRef.onValue.map((event) {
    final data = event.snapshot.value as Map<dynamic, dynamic>?;
    return data != null
        ? {
            'showAd': data['showAd'] ?? false,
            'price': data['price'] ?? 9.99,
            'isLifetime': data['isLifetime'] ?? false,
          }
        : {'showAd': false, 'price': 9.99, 'isLifetime': false};
  });
});

// Match details providers
@riverpod
Stream<String?> chatId(ChatIdRef ref) {
  var uid = FirebaseAuth.instance.currentUser!.uid;
  DatabaseReference chatRef = FirebaseDatabase.instance.ref('users/$uid/chat');
  return chatRef.onValue.map((event) => event.snapshot.value as String?);
}

@riverpod
Stream<String?> matchName(MatchNameRef ref) {
  final chatId = ref.watch(chatIdProvider);

  final controller = StreamController<String?>();

  chatId.whenData((chatId) {
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
}

@riverpod
Stream<int?> matchAge(MatchAgeRef ref) {
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
}

@riverpod
Stream<double?> matchDistance(MatchDistanceRef ref) {
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
}

enum Author { me, you, system }

class ChatMessageModel {
  final String message;
  final String author; // Store user ID as author
  final DateTime date;

  ChatMessageModel({
    required this.message,
    required this.author, // Author is now a user ID string
    required this.date,
  });

  factory ChatMessageModel.fromJson(Map<dynamic, dynamic> json) {
    return ChatMessageModel(
      message: json['message'],
      author: json['author'], // Author is now a user ID string
      date: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'author': author,
      'timestamp': date.millisecondsSinceEpoch,
    };
  }
}

class ChatMessagesNotifier extends StateNotifier<List<ChatMessageModel>> {
  ChatMessagesNotifier() : super([]);

  void addMessage(ChatMessageModel message) {
    state = [...state, message];
  }

  void setMessages(List<ChatMessageModel> messages) {
    state = messages;
  }
}

final chatMessagesStateProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessageModel>>((ref) {
  return ChatMessagesNotifier();
});

final chatMessagesProvider =
    StreamProvider.autoDispose<List<ChatMessageModel>>((ref) {
  final chatIdAsyncValue = ref.watch(chatIdProvider);

  final controller = StreamController<List<ChatMessageModel>>();

  chatIdAsyncValue.whenData((chatId) {
    if (chatId == null) {
      controller.add([]);
      return;
    }

    DatabaseReference messagesRef =
        FirebaseDatabase.instance.ref('chats/$chatId/messages');
    messagesRef.onValue.listen((event) {
      final messages = <ChatMessageModel>[];
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        data.forEach((key, value) {
          messages.add(ChatMessageModel.fromJson(value));
        });
      }
      controller.add(messages);
    });
  });

  ref.onDispose(() {
    controller.close();
  });

  return controller.stream;
});
