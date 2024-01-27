import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:ig0tchaapp/pages/common.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  bool _isLoggedIn = false;
  String _name = "";
  String _userId = "";
  String _profileUrl = "";
  String _roleName = "";
  String _aliasName = "";
  CurrentUserSessionData _currentUserSessionData = CurrentUserSessionData(
      loginName: "", aliasName: "", userId: "", profileUrl: "", roleName: "");

  Future<bool> checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userToken = prefs.getString("userToken");
    //print(userToken);
    if (userToken != null) {
      try {
        _isLoggedIn = true;
        Map<String, dynamic>? userData = json.decode(userToken);
        _name = userData?["name"];
        _userId = userData?["userid"];
        _profileUrl = userData?["profile_url"];
        _roleName = userData?["role"];
        _aliasName = userData?["alias"];
        _currentUserSessionData = CurrentUserSessionData(
            loginName: _name,
            aliasName: _aliasName,
            userId: _userId,
            profileUrl: _profileUrl,
            roleName: _roleName);
      } catch (e) {
        print("checkSession: Error signing in with token: $e");
      }
    }

    return _isLoggedIn;
  }

  Future<void> signInSession(
      String userId, Map<String, dynamic>? userData) async {
    try {
      if (userData != null) {
        String jsonUserData = json.encode(userData);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("userToken", jsonUserData);
        _isLoggedIn = true;
        _name = userData["name"];
        _userId = userData["userId"];
        _profileUrl = userData["profile_url"];
        _roleName = userData["role"];
        _aliasName = userData["alias"];
        _currentUserSessionData = CurrentUserSessionData(
            loginName: _name,
            aliasName: _aliasName,
            userId: _userId,
            profileUrl: _profileUrl,
            roleName: _roleName);
      }
    } catch (e) {
      //rethrow;
      print("signInSession: Error signing in: $e");
    }
  }

  Future<void> signOutSession() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove("userToken");
      await FirebaseAuth.instance.signOut();
      _isLoggedIn = false;
      _name = "";
    } catch (e) {
      //rethrow;
      print("signOutSession: Error signing in: $e");
    }
  }

  Future<void> clearSessionData() async {
    try {
      // Code to clear the session data...
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      //rethrow;
      print("clearSessionData: Error signing in: $e");
    }
  }

  Future<String?> handleVerifyGooglePhoneNumber(phoneNumber) async {
    //String? verificationId;
    String signInphoneNumber = "+63${phoneNumber.substring(1)}";
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      /*verificationCompleted(PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
      }

      verificationFailed(FirebaseAuthException e) {
        print('Phone verification failed: $e');
      }

      codeSent(String verificationId, [int? forceResendingToken]) async {
        verificationId = verificationId;
      }

      codeAutoRetrievalTimeout(String verificationId) {
        verificationId = verificationId;
      }

      await auth.verifyPhoneNumber(
          phoneNumber: signInphoneNumber,
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
          timeout: const Duration(seconds: 60));*/

      ConfirmationResult confirmationResult = await auth.signInWithPhoneNumber(
          signInphoneNumber,
          RecaptchaVerifier(
            container: 'recaptcha-container',
            size: RecaptchaVerifierSize.compact,
            theme: RecaptchaVerifierTheme.dark,
            auth: FirebaseAuthWeb.instance,
          ));

      return confirmationResult.verificationId;
    } catch (error) {
      print('Failed to send verification code: $error');
    }
    return null;
  }

  Future<void> handleSignInGooglePhoneNumber(verificationId, smsCode) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      await auth.signInWithCredential(credential);
      _isLoggedIn = true;
    } catch (error) {
      print('Failed to sign in with Google: $error');
    }
  }

  bool get isLoggedIn => _isLoggedIn;
  String get name => _name;
  String get userId => _userId;
  String get profileUrl => _profileUrl;
  String get roleName => _roleName;
  String get aliasName => _aliasName;
  CurrentUserSessionData get currentUserSessionData => _currentUserSessionData;
}
