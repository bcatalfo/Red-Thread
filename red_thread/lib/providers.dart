import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Gender { male, female, other }

// TODO: Get this from AWS
final matchFoundProvider = StateProvider<bool>((ref) => false);
final identifyAsProvider = StateProvider<Gender>((ref) => Gender.male);
