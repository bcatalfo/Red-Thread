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

@riverpod
Stream<String?> authUser(AuthUserRef ref) {
  return FirebaseAuth.instance.authStateChanges().map((user) => user?.uid);
}

@riverpod
class MyTheme extends _$MyTheme {
  @override
  Stream<ThemeMode?> build() async* {
    final prefs = await SharedPreferences.getInstance();
    final localTheme = prefs.getString('themeMode') ?? 'light';
    yield localTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;

    final uidAsyncValue = ref.watch(authUserProvider);
    yield* uidAsyncValue.when(
      data: (uid) async* {
        if (uid == null) {
          yield null;
          return;
        }
        DatabaseReference themeModeRef =
            FirebaseDatabase.instance.ref('users/$uid/themeMode');
        final subscription = themeModeRef.onValue.listen((event) async {
          final themeMode = event.snapshot.value as String?;
          final mode = themeMode == 'dark' ? ThemeMode.dark : ThemeMode.light;
          await prefs.setString('themeMode', themeMode ?? 'light');
          state = AsyncValue.data(mode);
        });

        ref.onDispose(() => subscription.cancel());
      },
      error: (error, stack) async* {
        yield ThemeMode.light;
      },
      loading: () async* {
        yield ThemeMode.light;
      },
    );
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'themeMode', themeMode == ThemeMode.dark ? 'dark' : 'light');

    final uid = ref.read(authUserProvider).value;
    if (uid != null) {
      DatabaseReference themeModeRef =
          FirebaseDatabase.instance.ref('users/$uid/themeMode');
      await themeModeRef.set(themeMode == ThemeMode.dark ? 'dark' : 'light');
    }
  }
}

@riverpod
class SurveyDue extends _$SurveyDue {
  @override
  Stream<bool?> build() async* {
    final uidAsyncValue = ref.watch(authUserProvider);
    yield* uidAsyncValue.when(
      data: (uid) async* {
        if (uid == null) {
          yield null;
          return;
        }
        final surveyDueRef =
            FirebaseDatabase.instance.ref('users/$uid/surveyDue');
        final subscription = surveyDueRef.onValue.listen((event) {
          final surveyDue = event.snapshot.value as bool?;
          state = AsyncValue.data(surveyDue);
        });

        ref.onDispose(() => subscription.cancel());
      },
      error: (error, stack) async* {
        yield null;
      },
      loading: () async* {
        yield null;
      },
    );
  }

  Future<void> setSurveyDue(bool surveyDue) async {
    final uid = ref.read(authUserProvider).value;
    if (uid != null) {
      final surveyDueRef =
          FirebaseDatabase.instance.ref('users/$uid/surveyDue');
      await surveyDueRef.set(surveyDue);
    }
  }
}

@riverpod
class Queue extends _$Queue {
  DateTime? _joinedQueueTime;

  @override
  Stream<bool?> build() async* {
    final uidAsyncValue = ref.watch(authUserProvider);
    yield* uidAsyncValue.when(
      data: (uid) async* {
        if (uid == null) {
          yield null;
          return;
        }

        final queueRef = FirebaseDatabase.instance.ref('queue/$uid');
        final subscription = queueRef.onValue.listen((event) {
          if (event.snapshot.value != null) {
            _joinedQueueTime = DateTime.fromMillisecondsSinceEpoch(
                event.snapshot.value as int);
            state = const AsyncValue.data(true);
          } else {
            _joinedQueueTime = null;
            state = const AsyncValue.data(false);
          }
        });

        ref.onDispose(() => subscription.cancel());
      },
      error: (error, stack) async* {
        yield null;
      },
      loading: () async* {
        yield null;
      },
    );
  }

  Future<void> joinQueue() async {
    final uid = ref.read(authUserProvider).value;
    if (uid != null) {
      final queueRef = FirebaseDatabase.instance.ref('queue/$uid');
      final now = DateTime.now();
      await queueRef.set(now.millisecondsSinceEpoch);
      _joinedQueueTime = now;
      state = const AsyncValue.data(true);
    }
  }

  Future<void> leaveQueue() async {
    final uid = ref.read(authUserProvider).value;
    if (uid != null) {
      final queueRef = FirebaseDatabase.instance.ref('queue/$uid');
      await queueRef.remove();
      _joinedQueueTime = null;
      state = const AsyncValue.data(false);
    }
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
  Stream<DateScheduleState?> build() async* {
    final prefs = await SharedPreferences.getInstance();
    final localStatusString =
        prefs.getString('dateScheduleStatus') ?? 'notScheduled';
    final localStatus = DateScheduleStatus.values.firstWhere(
      (e) => e.toString().split('.').last == localStatusString,
      orElse: () => DateScheduleStatus.notScheduled,
    );

    final localDateTimeString = prefs.getString('dateTime');
    final localDateTime = localDateTimeString != null
        ? DateTime.parse(localDateTimeString)
        : null;

    final localDateLocation = prefs.getString('dateLocation');

    yield DateScheduleState(
      status: localStatus,
      dateTime: localDateTime,
      dateLocation: localDateLocation,
    );

    final uidAsyncValue = ref.watch(authUserProvider);
    yield* uidAsyncValue.when(
      data: (uid) async* {
        if (uid == null) {
          yield null;
          return;
        }

        final chatId = await ref.watch(chatIdProvider.future);

        if (chatId == null) {
          yield DateScheduleState(status: DateScheduleStatus.notScheduled);
          return;
        }

        DatabaseReference dateScheduleRef =
            FirebaseDatabase.instance.ref('chats/$chatId');
        final subscription = dateScheduleRef.onValue.listen((event) async {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            final statusString = data['dateSchedule_$uid'] as String?;
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

            state = AsyncValue.data(
              DateScheduleState(
                status: status,
                dateTime: dateTime,
                dateLocation: dateLocation,
              ),
            );
          } else {
            state = AsyncValue.data(
              DateScheduleState(status: DateScheduleStatus.notScheduled),
            );
          }
        });

        ref.onDispose(() => subscription.cancel());
      },
      error: (error, stack) async* {
        yield null;
      },
      loading: () async* {
        yield null;
      },
    );
  }

  Future<void> setDateSchedule(DateScheduleStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'dateScheduleStatus', status.toString().split('.').last);

    final uid = ref.read(authUserProvider).value;
    final chatId = await ref.watch(chatIdProvider.future);
    if (uid != null && chatId != null) {
      DatabaseReference dateScheduleRef =
          FirebaseDatabase.instance.ref('chats/$chatId');
      await dateScheduleRef
          .update({'dateSchedule_$uid': status.toString().split('.').last});

      state = AsyncValue.data(
        state.value?.copyWith(status: status),
      );
    }
  }

  Future<void> setDateScheduleForMatch(DateScheduleStatus status) async {
    final userId = ref.read(authUserProvider).value;
    final chatId = await ref.watch(chatIdProvider.future);
    if (userId != null && chatId != null) {
      final matchUserId = await _getMatchUserId(chatId, userId);

      DatabaseReference dateScheduleRef =
          FirebaseDatabase.instance.ref('chats/$chatId');
      await dateScheduleRef.update(
          {'dateSchedule_$matchUserId': status.toString().split('.').last});

      state = AsyncValue.data(
        state.value?.copyWith(status: status),
      );
    }
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
    if (chatId != null) {
      DatabaseReference dateTimeRef =
          FirebaseDatabase.instance.ref('chats/$chatId/dateTime');
      await dateTimeRef.set(dateTime.toIso8601String());

      state = AsyncValue.data(
        state.value?.copyWith(dateTime: dateTime),
      );
    }
  }

  Future<void> setLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dateLocation', location);

    final chatId = await ref.watch(chatIdProvider.future);
    if (chatId != null) {
      DatabaseReference locationRef =
          FirebaseDatabase.instance.ref('chats/$chatId/dateLocation');
      await locationRef.set(location);

      state = AsyncValue.data(
        state.value?.copyWith(dateLocation: location),
      );
    }
  }
}

@riverpod
class SelectedGenders extends _$SelectedGenders {
  @override
  Stream<Set<Gender>?> build() async* {
    final uidAsyncValue = ref.watch(authUserProvider);
    yield* uidAsyncValue.when(
      data: (uid) async* {
        if (uid == null) {
          yield null;
          return;
        }

        final lookingForRef =
            FirebaseDatabase.instance.ref('users/$uid/lookingFor');
        final subscription = lookingForRef.onValue.listen((event) {
          final data = event.snapshot.value as List<dynamic>? ?? [];
          final genders = data
              .map((gender) => Gender.values
                  .firstWhere((e) => e.toString() == gender as String))
              .toSet();
          state = AsyncValue.data(genders);
        });

        ref.onDispose(() => subscription.cancel());
      },
      error: (error, stack) async* {
        yield null;
      },
      loading: () async* {
        yield null;
      },
    );
  }

  Future<void> setGenders(Set<Gender> genders) async {
    final uid = ref.read(authUserProvider).value;
    if (uid != null) {
      final lookingForRef =
          FirebaseDatabase.instance.ref('users/$uid/lookingFor');
      final genderList = genders.map((gender) => gender.toString()).toList();
      await lookingForRef.set(genderList);
    }
  }
}

@riverpod
class MaxDistance extends _$MaxDistance {
  @override
  Stream<double?> build() async* {
    final uidAsyncValue = ref.watch(authUserProvider);
    yield* uidAsyncValue.when(
      data: (uid) async* {
        if (uid == null) {
          yield null;
          return;
        }

        final maxDistanceRef =
            FirebaseDatabase.instance.ref('users/$uid/maxDistance');
        final subscription = maxDistanceRef.onValue.listen((event) {
          final value = event.snapshot.value;
          final maxDistance =
              (value is int) ? value.toDouble() : value as double?;
          state = AsyncValue.data(maxDistance);
        });

        ref.onDispose(() => subscription.cancel());
      },
      error: (error, stack) async* {
        yield null;
      },
      loading: () async* {
        yield null;
      },
    );
  }

  Future<void> setMaxDistance(double maxDistance) async {
    final uid = ref.read(authUserProvider).value;
    if (uid != null) {
      final maxDistanceRef =
          FirebaseDatabase.instance.ref('users/$uid/maxDistance');
      await maxDistanceRef.set(maxDistance);
    }
  }
}

@riverpod
class AgeRange extends _$AgeRange {
  @override
  Stream<RangeValues?> build() async* {
    final uidAsyncValue = ref.watch(authUserProvider);
    yield* uidAsyncValue.when(
      data: (uid) async* {
        if (uid == null) {
          yield null;
          return;
        }

        final ageRangeRef =
            FirebaseDatabase.instance.ref('users/$uid/ageRange');
        final subscription = ageRangeRef.onValue.listen((event) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            final start = data['start'] as int? ?? 18;
            final end = data['end'] as int? ?? 30;
            final ageRange = RangeValues(start.toDouble(), end.toDouble());
            state = AsyncValue.data(ageRange);
          } else {
            state = const AsyncValue.data(RangeValues(18, 30));
          }
        });

        ref.onDispose(() => subscription.cancel());
      },
      error: (error, stack) async* {
        yield null;
      },
      loading: () async* {
        yield null;
      },
    );
  }

  Future<void> setAgeRange(RangeValues ageRange) async {
    final uid = ref.read(authUserProvider).value;
    if (uid != null) {
      final ageRangeRef = FirebaseDatabase.instance.ref('users/$uid/ageRange');
      await ageRangeRef.set({
        'start': ageRange.start.toInt(),
        'end': ageRange.end.toInt(),
      });
    }
  }
}

final showAdProvider = StateProvider<bool>((ref) => true);

final adInfoProvider = StreamProvider.autoDispose<Map<String, dynamic>?>((ref) {
  final uidAsyncValue = ref.watch(authUserProvider);

  return uidAsyncValue.when(
    data: (uid) {
      if (uid == null) return const Stream.empty();
      final adInfoRef = FirebaseDatabase.instance.ref('users/$uid/adInfo');
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
    },
    error: (error, stack) => Stream.value(null),
    loading: () => Stream.value(null),
  );
});

@riverpod
Future<String?> myName(MyNameRef ref) async {
  final uid = ref.watch(authUserProvider).value;
  if (uid == null) return null;

  final nameRef = FirebaseDatabase.instance.ref('users/$uid/displayName');
  final snapshot = await nameRef.once();
  return snapshot.snapshot.value as String?;
}

@riverpod
class ChatId extends _$ChatId {
  StreamSubscription<DatabaseEvent>? _subscription;

  @override
  Stream<String?> build() async* {
    debugPrint('ChatId build');
    final prefs = await SharedPreferences.getInstance();
    final localChatId = prefs.getString('chatId');
    if (localChatId != null) {
      debugPrint('ChatId localChatId: $localChatId');
      yield localChatId;
    }

    final uidAsyncValue = ref.watch(authUserProvider);

    yield* uidAsyncValue.when(
      data: (uid) async* {
        if (uid == null) {
          debugPrint('ChatId uid is null');
          yield null;
          return;
        }

        final chatRef = FirebaseDatabase.instance.ref('users/$uid/chat');
        try {
          _subscription = chatRef.onValue.listen((event) async {
            final chatId = event.snapshot.value as String?;
            if (chatId != null) {
              await prefs.setString('chatId', chatId);
            } else {
              await prefs.remove('chatId');
            }
            debugPrint('ChatId chatId: $chatId');
            state = AsyncValue.data(chatId);
          });
        } catch (e, stack) {
          debugPrint('ChatId error: $e');
          state = AsyncValue.error(e, stack);
          ref.invalidateSelf();
        }

        ref.onDispose(() {
          debugPrint('ChatId onDispose');
          _subscription?.cancel();
        });
      },
      error: (error, stack) async* {
        yield null;
      },
      loading: () async* {
        yield null;
      },
    );
  }

  Future<void> unmatch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chatId');

    final uid = ref.read(authUserProvider).value;
    if (uid != null) {
      final chatRef = FirebaseDatabase.instance.ref('users/$uid/chat');
      await chatRef.remove();
    }
  }
}

@riverpod
class MatchName extends _$MatchName {
  StreamSubscription<DatabaseEvent>? _subscription;

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

      final uid = ref.watch(authUserProvider).value;
      if (uid == null) {
        yield null;
        continue;
      }

      final matchInfoRef =
          FirebaseDatabase.instance.ref('chats/$chatId/match_info');
      try {
        _subscription = matchInfoRef.onValue.listen((event) async {
          final matchInfo = event.snapshot.value as Map<dynamic, dynamic>;
          final user1Id = matchInfo['user1_id'];
          final user2Name = matchInfo['user2_name'] as String;
          final user1Name = matchInfo['user1_name'] as String;
          final name = (user1Id == uid) ? user2Name : user1Name;
          await prefs.setString('matchName', name);
          state = AsyncValue.data(name);
        });
      } catch (e, stack) {
        state = AsyncValue.error(e, stack);
        ref.invalidateSelf();
      }

      ref.onDispose(() {
        _subscription?.cancel();
      });
    }
  }
}

@riverpod
class MatchAge extends _$MatchAge {
  StreamSubscription<DatabaseEvent>? _subscription;

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

      final uid = ref.watch(authUserProvider).value;
      if (uid == null) {
        yield null;
        continue;
      }

      final matchInfoRef =
          FirebaseDatabase.instance.ref('chats/$chatId/match_info');
      try {
        _subscription = matchInfoRef.onValue.listen((event) async {
          final matchInfo = event.snapshot.value as Map<dynamic, dynamic>;
          final user1Id = matchInfo['user1_id'];
          final user2Age = matchInfo['user2_age'] as int;
          final user1Age = matchInfo['user1_age'] as int;
          final age = (user1Id == uid) ? user2Age : user1Age;
          await prefs.setInt('matchAge', age);
          state = AsyncValue.data(age);
        });
      } catch (e, stack) {
        state = AsyncValue.error(e, stack);
        ref.invalidateSelf();
      }

      ref.onDispose(() {
        _subscription?.cancel();
      });
    }
  }
}

@riverpod
class MatchDistance extends _$MatchDistance {
  StreamSubscription<DatabaseEvent>? _subscription;

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

      final uid = ref.watch(authUserProvider).value;
      if (uid == null) {
        yield null;
        continue;
      }

      final matchDistanceRef =
          FirebaseDatabase.instance.ref('chats/$chatId/match_info/distance');
      try {
        _subscription = matchDistanceRef.onValue.listen((event) async {
          final distance = event.snapshot.value as double?;
          if (distance != null) {
            await prefs.setDouble('matchDistance', distance);
          } else {
            await prefs.remove('matchDistance');
          }
          state = AsyncValue.data(distance);
        });
      } catch (e, stack) {
        state = AsyncValue.error(e, stack);
        ref.invalidateSelf();
      }

      ref.onDispose(() {
        _subscription?.cancel();
      });
    }
  }
}

enum Author { me, you, system }

class ChatMessageModel {
  final String message;
  final String author;
  final DateTime date;

  ChatMessageModel({
    required this.message,
    required this.author,
    required this.date,
  });

  factory ChatMessageModel.fromJson(Map<dynamic, dynamic> json) {
    return ChatMessageModel(
      message: json['message'],
      author: json['author'],
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
  Stream<List<ChatMessageModel>?> build() async* {
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

    final uidAsyncValue = ref.watch(authUserProvider);
    yield* uidAsyncValue.when(
      data: (uid) async* {
        if (uid == null) {
          yield [];
          return;
        }

        final chatId = await ref.watch(chatIdProvider.future);

        if (chatId == null) {
          yield [];
          return;
        }

        DatabaseReference messagesRef =
            FirebaseDatabase.instance.ref('chats/$chatId/messages');
        final subscription = messagesRef.onValue.listen((event) {
          final messages = <ChatMessageModel>[];
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            data.forEach((key, value) {
              messages.add(ChatMessageModel.fromJson(value));
            });
          }
          prefs.setStringList('chatMessages',
              messages.map((e) => jsonEncode(e.toJson())).toList());
          state = AsyncValue.data(messages);
        });

        ref.onDispose(() => subscription.cancel());
      },
      error: (error, stack) async* {
        yield [];
      },
      loading: () async* {
        yield [];
      },
    );
  }

  Future<void> addMessage(ChatMessageModel message) async {
    final uid = ref.read(authUserProvider).value;
    if (uid != null) {
      final chatId = await ref.watch(chatIdProvider.future);
      if (chatId != null) {
        DatabaseReference messagesRef =
            FirebaseDatabase.instance.ref('chats/$chatId/messages');
        await messagesRef.push().set(message.toJson());
      }
    }
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

@riverpod
class VoiceCallScreenState extends _$VoiceCallScreenState {
  @override
  bool build() {
    return true; // Default to voice call
  }

  void toggle() {
    state = !state;
  }
}

@riverpod
class VoiceCallState extends _$VoiceCallState {
  @override
  bool build() {
    return false;
  }

  void toggle() {
    state = !state;
  }
}

final hadFirstCallProvider = StateProvider<bool>((ref) => false);
