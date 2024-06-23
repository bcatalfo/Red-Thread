import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers.dart';

class AuthenticationService {
  final WidgetRef ref;

  AuthenticationService(this.ref);

  Future<void> login(String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    await FirebaseAuth.instance
        .signInWithCredential(credential)
        .then((value) async {
      var userRef = FirebaseDatabase.instance
          .ref('users/${FirebaseAuth.instance.currentUser!.uid}');
      var event = await userRef.once();

      if (event.snapshot.value == null) {
        await FirebaseAuth.instance.signOut();
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // _invalidateProviders();
      }
    }).catchError((error) {
      throw error;
    });
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    //_invalidateProviders();
  }

  void _invalidateProviders() {
    ref.invalidate(myNameProvider);
    ref.invalidate(authUserProvider);
    ref.invalidate(surveyDueProvider);
    ref.invalidate(queueProvider);
    ref.invalidate(dateScheduleProvider);
    ref.invalidate(selectedGendersProvider);
    ref.invalidate(maxDistanceProvider);
    ref.invalidate(ageRangeProvider);
    ref.invalidate(showAdProvider);
    ref.invalidate(adInfoProvider);
    ref.invalidate(chatIdProvider);
    ref.invalidate(matchNameProvider);
    ref.invalidate(matchAgeProvider);
    ref.invalidate(matchDistanceProvider);
    ref.invalidate(chatMessagesProvider);
  }
}
