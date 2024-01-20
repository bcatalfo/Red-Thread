import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Gender { male, female, other }

// TODO: Get this from backend
final matchFoundProvider = StateProvider<bool>((ref) => false);
final identifyAsProvider = StateProvider<Gender>((ref) => Gender.male);
final interestedInMaleProvider = StateProvider<bool>((ref) => false);
final interestedInFemaleProvider = StateProvider<bool>((ref) => false);
final interestedInOtherProvider = StateProvider<bool>((ref) => false);
