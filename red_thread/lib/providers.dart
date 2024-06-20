import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'providers.g.dart';

enum Gender { male, female, nonBinary }

enum DateSchedule { notScheduled, sent, received, confirmed, onDate }

// TODO: Get this from backend
@riverpod
class MyTheme extends _$MyTheme {
  @override
  Stream<ThemeMode> build() async* {
    final prefs = await SharedPreferences.getInstance();
    final localTheme = prefs.getString('themeMode') ?? 'light';
    yield localTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;

    var uid = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference themeModeRef =
        FirebaseDatabase.instance.ref('users/$uid/themeMode');
    await for (var event in themeModeRef.onValue) {
      final themeMode = event.snapshot.value as String?;
      final mode = themeMode == 'dark' ? ThemeMode.dark : ThemeMode.light;
      await prefs.setString('themeMode', themeMode ?? 'light');
      yield mode;
    }
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'themeMode', themeMode == ThemeMode.dark ? 'dark' : 'light');

    var uid = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference themeModeRef =
        FirebaseDatabase.instance.ref('users/$uid/themeMode');
    await themeModeRef.set(themeMode == ThemeMode.dark ? 'dark' : 'light');
  }
}

final isAuthenticatedProvider = StreamProvider<bool>((ref) =>
    FirebaseAuth.instance.authStateChanges().map((user) => user != null));

@riverpod
class SurveyDue extends _$SurveyDue {
  @override
  Stream<bool> build() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final surveyDueRef = FirebaseDatabase.instance.ref('users/$uid/surveyDue');
    return surveyDueRef.onValue.map((event) => event.snapshot.value as bool);
  }

  Future<void> setSurveyDue(bool surveyDue) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final surveyDueRef = FirebaseDatabase.instance.ref('users/$uid/surveyDue');
    await surveyDueRef.set(surveyDue);
  }
}

@riverpod
class Queue extends _$Queue {
  DateTime? _joinedQueueTime;

  @override
  Stream<bool> build() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final queueRef = FirebaseDatabase.instance.ref('queue/$uid');
    return queueRef.onValue.map((event) {
      if (event.snapshot.value != null) {
        _joinedQueueTime =
            DateTime.fromMillisecondsSinceEpoch(event.snapshot.value as int);
        return true;
      } else {
        _joinedQueueTime = null;
        return false;
      }
    });
  }

  Future<void> joinQueue() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final queueRef = FirebaseDatabase.instance.ref('queue/$uid');
    final now = DateTime.now();
    await queueRef.set(now.millisecondsSinceEpoch);
    _joinedQueueTime = now;
    state = const AsyncValue.data(true);
  }

  Future<void> leaveQueue() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final queueRef = FirebaseDatabase.instance.ref('queue/$uid');
    await queueRef.remove();
    _joinedQueueTime = null;
    state = const AsyncValue.data(false);
  }

  DateTime? whenJoinedQueue() {
    return _joinedQueueTime;
  }
}

final dateTimeProvider =
    StateProvider<DateTime?>((ref) => DateTime(2024, 6, 5, 17, 0));
final dateLocationProvider = StateProvider<String?>((ref) => "Starbucks");
final dateScheduleProvider =
    StateProvider<DateSchedule>((ref) => DateSchedule.received);

// New providers for settings
@riverpod
class SelectedGenders extends _$SelectedGenders {
  @override
  Stream<Set<Gender>> build() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final lookingForRef =
        FirebaseDatabase.instance.ref('users/$uid/lookingFor');
    return lookingForRef.onValue.map((event) {
      final data = event.snapshot.value as List<dynamic>? ?? [];
      return data
          .map((gender) =>
              Gender.values.firstWhere((e) => e.toString() == gender as String))
          .toSet();
    });
  }

  Future<void> setGenders(Set<Gender> genders) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final lookingForRef =
        FirebaseDatabase.instance.ref('users/$uid/lookingFor');
    final genderList = genders.map((gender) => gender.toString()).toList();
    await lookingForRef.set(genderList);
  }
}

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

@riverpod
Future<String?> myName(MyNameRef ref) async {
  var uid = FirebaseAuth.instance.currentUser!.uid;
  DatabaseReference nameRef =
      FirebaseDatabase.instance.ref('users/$uid/displayName');

  final snapshot = await nameRef.once();
  return snapshot.snapshot.value as String?;
}

// Match details providers
@riverpod
class ChatId extends _$ChatId {
  @override
  Stream<String?> build() async* {
    final prefs = await SharedPreferences.getInstance();
    final localChatId = prefs.getString('chatId');
    yield localChatId;

    var uid = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference chatRef =
        FirebaseDatabase.instance.ref('users/$uid/chat');
    await for (var event in chatRef.onValue) {
      final chatId = event.snapshot.value as String?;
      if (chatId != null) {
        await prefs.setString('chatId', chatId);
      } else {
        await prefs.remove('chatId');
      }
      yield chatId;
    }
  }
}

@riverpod
class MatchName extends _$MatchName {
  @override
  Stream<String?> build() async* {
    final prefs = await SharedPreferences.getInstance();
    final localMatchName = prefs.getString('matchName');
    yield localMatchName;

    final chatIdAsyncValue = ref.watch(chatIdProvider);

    await for (var chatId in chatIdAsyncValue.maybeWhen(
      data: (data) => Stream.value(data),
      orElse: () => Stream.value(null),
    )) {
      if (chatId == null) {
        yield null;
        continue;
      }

      var uid = FirebaseAuth.instance.currentUser!.uid;
      DatabaseReference matchInfoRef =
          FirebaseDatabase.instance.ref('chats/$chatId/match_info');
      await for (var event in matchInfoRef.onValue) {
        final matchInfo = event.snapshot.value as Map<dynamic, dynamic>;
        final user1Id = matchInfo['user1_id'];
        final user2Name = matchInfo['user2_name'] as String;
        final user1Name = matchInfo['user1_name'] as String;
        final name = (user1Id == uid) ? user2Name : user1Name;
        await prefs.setString('matchName', name);
        yield name;
      }
    }
  }
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
