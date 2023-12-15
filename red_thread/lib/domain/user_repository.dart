import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class UserRepository {
  Future<Map<String, String>> getUserAttributes() async {
    final attributes = await Amplify.Auth.fetchUserAttributes();
    final data = {for (var e in attributes) e.userAttributeKey.key: e.value};
    return data;
  }
}
