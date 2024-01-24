import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Gender { male, female, other }

// TODO: Get this from backend
final matchFoundProvider = StateProvider<bool>((ref) => false);
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
final isFirstTimeUserProvider = StateProvider<bool>((ref) => true);
final isAuthenticatedProvider = StateProvider<bool>((ref) => false);
final isAccountSetupCompleteProvider = StateProvider<bool>((ref) => false);
final isVerifiedProvider = StateProvider<bool>((ref) => false);
