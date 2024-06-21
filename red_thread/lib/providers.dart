import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
part 'providers.g.dart';

enum Gender { male, female, nonBinary }

enum DateScheduleStatus { notScheduled, sent, received, confirmed, onDate }

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

class DateScheduleState {
  final DateScheduleStatus status;
  final DateTime? dateTime;
  final String? dateLocation;

  DateScheduleState({
    required this.status,
    this.dateTime,
    this.dateLocation,
  });

  DateScheduleState copyWith({
    DateScheduleStatus? status,
    DateTime? dateTime,
    String? dateLocation,
  }) {
    return DateScheduleState(
      status: status ?? this.status,
      dateTime: dateTime ?? this.dateTime,
      dateLocation: dateLocation ?? this.dateLocation,
    );
  }
}

@riverpod
class DateSchedule extends _$DateSchedule {
  @override
  Stream<DateScheduleState> build() async* {
    final prefs = await SharedPreferences.getInstance();
    final localStatusString =
        prefs.getString('dateScheduleStatus') ?? 'notScheduled';
    final localStatus = DateScheduleStatus.values.firstWhere(
      (e) => e.toString().split('.').last == localStatusString,
      orElse: () => DateScheduleStatus.notScheduled,
    );

    final localDateTimeString = prefs.getString('dateTime');
    debugPrint('localDateTimeString: $localDateTimeString');
    final localDateTime = localDateTimeString != null
        ? DateTime.parse(localDateTimeString)
        : null;

    final localDateLocation = prefs.getString('dateLocation');

    yield DateScheduleState(
      status: localStatus,
      dateTime: localDateTime,
      dateLocation: localDateLocation,
    );

    final chatId = await ref.watch(chatIdProvider.future);

    if (chatId == null) {
      yield DateScheduleState(status: DateScheduleStatus.notScheduled);
      return;
    }

    final userId = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference dateScheduleRef =
        FirebaseDatabase.instance.ref('chats/$chatId');

    await for (var event in dateScheduleRef.onValue) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        final statusString = data['dateSchedule_$userId'] as String?;
        debugPrint('statusString: $statusString');
        final status = statusString != null
            ? DateScheduleStatus.values.firstWhere(
                (e) => e.toString().split('.').last == statusString,
                orElse: () => DateScheduleStatus.notScheduled,
              )
            : DateScheduleStatus.notScheduled;

        final dateTimeString = data['dateTime'] as String?;
        final dateTime =
            dateTimeString != null ? DateTime.parse(dateTimeString) : null;

        final dateLocation = data['dateLocation'] as String?;

        await prefs.setString(
            'dateScheduleStatus', statusString ?? 'notScheduled');
        await prefs.setString(
            'dateTime', dateTimeString ?? DateTime.now().toIso8601String());
        await prefs.setString('dateLocation', dateLocation ?? '');

        yield DateScheduleState(
          status: status,
          dateTime: dateTime,
          dateLocation: dateLocation,
        );
      } else {
        yield DateScheduleState(status: DateScheduleStatus.notScheduled);
      }
    }
  }

  Future<void> setDateSchedule(DateScheduleStatus status) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'dateScheduleStatus', status.toString().split('.').last);

    final chatId = await ref.watch(chatIdProvider.future);
    if (chatId == null) return;

    DatabaseReference dateScheduleRef =
        FirebaseDatabase.instance.ref('chats/$chatId');
    await dateScheduleRef
        .update({'dateSchedule_$userId': status.toString().split('.').last});

    state = AsyncValue.data(
      state.value!.copyWith(status: status),
    );
  }

  Future<void> setDateScheduleForMatch(DateScheduleStatus status) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final chatId = await ref.watch(chatIdProvider.future);
    if (chatId == null) return;

    final matchUserId = await _getMatchUserId(chatId, userId);

    DatabaseReference dateScheduleRef =
        FirebaseDatabase.instance.ref('chats/$chatId');
    await dateScheduleRef.update(
        {'dateSchedule_$matchUserId': status.toString().split('.').last});

    state = AsyncValue.data(
      state.value!.copyWith(status: status),
    );
  }

  Future<String> _getMatchUserId(String chatId, String currentUserId) async {
    final chatRef = FirebaseDatabase.instance.ref('chats/$chatId/match_info');
    final snapshot = await chatRef.once();
    final matchInfo = snapshot.snapshot.value as Map<dynamic, dynamic>;
    final user1Id = matchInfo['user1_id'] as String;
    final user2Id = matchInfo['user2_id'] as String;

    return currentUserId == user1Id ? user2Id : user1Id;
  }

  Future<void> setDateTime(DateTime dateTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dateTime', dateTime.toIso8601String());

    final chatId = await ref.watch(chatIdProvider.future);
    if (chatId == null) return;

    DatabaseReference dateTimeRef =
        FirebaseDatabase.instance.ref('chats/$chatId/dateTime');
    await dateTimeRef.set(dateTime.toIso8601String());

    state = AsyncValue.data(
      state.value!.copyWith(dateTime: dateTime),
    );
  }

  Future<void> setLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dateLocation', location);

    final chatId = await ref.watch(chatIdProvider.future);
    if (chatId == null) return;

    DatabaseReference locationRef =
        FirebaseDatabase.instance.ref('chats/$chatId/dateLocation');
    await locationRef.set(location);

    state = AsyncValue.data(
      state.value!.copyWith(dateLocation: location),
    );
  }
}

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

@riverpod
class MaxDistance extends _$MaxDistance {
  @override
  Stream<double> build() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final maxDistanceRef =
        FirebaseDatabase.instance.ref('users/$uid/maxDistance');
    return maxDistanceRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is int) {
        return value.toDouble();
      } else if (value is double) {
        return value;
      } else {
        throw StateError('Unexpected value type: ${value.runtimeType}');
      }
    });
  }

  Future<void> setMaxDistance(double maxDistance) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final maxDistanceRef =
        FirebaseDatabase.instance.ref('users/$uid/maxDistance');
    await maxDistanceRef.set(maxDistance);
  }
}

@riverpod
class AgeRange extends _$AgeRange {
  @override
  Stream<RangeValues> build() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ageRangeRef = FirebaseDatabase.instance.ref('users/$uid/ageRange');
    return ageRangeRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        final start = data['start'] as int? ?? 18;
        final end = data['end'] as int? ?? 30;
        return RangeValues(start.toDouble(), end.toDouble());
      } else {
        throw StateError('Invalid data format: ${event.snapshot.value}');
      }
    });
  }

  Future<void> setAgeRange(RangeValues ageRange) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ageRangeRef = FirebaseDatabase.instance.ref('users/$uid/ageRange');
    await ageRangeRef.set({
      'start': ageRange.start.toInt(),
      'end': ageRange.end.toInt(),
    });
  }
}

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

  Future<void> unmatch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chatId');

    var uid = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference chatRef =
        FirebaseDatabase.instance.ref('users/$uid/chat');
    await chatRef.remove();
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
class MatchAge extends _$MatchAge {
  @override
  Stream<int?> build() async* {
    final prefs = await SharedPreferences.getInstance();
    final localMatchAge = prefs.getInt('matchAge');
    yield localMatchAge;

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
        final user2Age = matchInfo['user2_age'] as int;
        final user1Age = matchInfo['user1_age'] as int;
        final age = (user1Id == uid) ? user2Age : user1Age;
        await prefs.setInt('matchAge', age);
        yield age;
      }
    }
  }
}

@riverpod
class MatchDistance extends _$MatchDistance {
  @override
  Stream<double?> build() async* {
    final prefs = await SharedPreferences.getInstance();
    final localMatchDistance = prefs.getDouble('matchDistance');
    yield localMatchDistance;

    final chatIdAsyncValue = ref.watch(chatIdProvider);

    await for (var chatId in chatIdAsyncValue.maybeWhen(
      data: (data) => Stream.value(data),
      orElse: () => Stream.value(null),
    )) {
      if (chatId == null) {
        yield null;
        continue;
      }

      DatabaseReference matchDistanceRef =
          FirebaseDatabase.instance.ref('chats/$chatId/match_info/distance');
      await for (var event in matchDistanceRef.onValue) {
        final distance = event.snapshot.value as double?;
        if (distance != null) {
          await prefs.setDouble('matchDistance', distance);
        } else {
          await prefs.remove('matchDistance');
        }
        yield distance;
      }
    }
  }
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

@riverpod
class ChatMessages extends _$ChatMessages {
  @override
  Stream<List<ChatMessageModel>> build() async* {
    final prefs = await SharedPreferences.getInstance();
    final cachedMessages = prefs.getStringList('chatMessages');
    if (cachedMessages != null) {
      final messages = cachedMessages
          .map((json) => ChatMessageModel.fromJson(jsonDecode(json)))
          .toList();
      yield messages;
    } else {
      yield [];
    }

    final chatId = await ref.watch(chatIdProvider.future);

    if (chatId == null) {
      yield [];
      return;
    }

    DatabaseReference messagesRef =
        FirebaseDatabase.instance.ref('chats/$chatId/messages');
    await for (var event in messagesRef.onValue) {
      final messages = <ChatMessageModel>[];
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        data.forEach((key, value) {
          messages.add(ChatMessageModel.fromJson(value));
        });
      }
      await prefs.setStringList(
          'chatMessages', messages.map((e) => jsonEncode(e.toJson())).toList());
      yield messages;
    }
  }

  Future<void> addMessage(ChatMessageModel message) async {
    final chatId = await ref.watch(chatIdProvider.future);
    if (chatId == null) {
      return;
    }

    DatabaseReference messagesRef =
        FirebaseDatabase.instance.ref('chats/$chatId/messages');
    await messagesRef.push().set(message.toJson());
    // No need to update local state here since it will be updated by the stream listener
  }

  Future<void> setMessages(List<ChatMessageModel> messages) async {
    state = AsyncValue.data(messages);
    await _cacheMessages(messages);
  }

  Future<void> _cacheMessages(List<ChatMessageModel> messages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'chatMessages', messages.map((e) => jsonEncode(e.toJson())).toList());
  }
}
