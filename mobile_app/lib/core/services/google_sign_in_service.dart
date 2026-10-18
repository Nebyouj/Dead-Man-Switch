import 'package:google_sign_in/google_sign_in.dart';

/// A thin wrapper around [GoogleSignIn] to isolate the native sign-in
/// flow and make it easy to mock in tests.
class GoogleSignInService {
  final GoogleSignIn _googleSignIn;

  GoogleSignInService({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ?? GoogleSignIn(
          scopes: ['email'],
          serverClientId: '561846531125-ke0rin5ki8bdbt4t2t613kiu3g6ls6ul.apps.googleusercontent.com',
        );

  /// Launches the Google Sign-In UI and returns the `idToken`.
  ///
  /// Returns `null` if the user cancels the sign-in flow.
  /// Throws if the sign-in succeeds but the auth object is missing.
  Future<String?> signIn() async {
   
    try {
      // Force sign-out to clear any cached sessions without an idToken
      await _googleSignIn.signOut();

      final account = await _googleSignIn.signIn();

      if (account == null) {
        return null;
      }

      final auth = await account.authentication;
      return auth.idToken;
    } catch (e) {
      rethrow;
    }
  }

  /// Signs out of the Google account (useful on logout).
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
