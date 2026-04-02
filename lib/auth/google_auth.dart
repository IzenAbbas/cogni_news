import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

Future<UserCredential?> signInWithGoogle() async {
  try {
    if (kIsWeb) {
      // Use Firebase's built-in Google Auth provider logic for Flutter Web.
      GoogleAuthProvider authProvider = GoogleAuthProvider();
      authProvider.addScope('email');

      return await FirebaseAuth.instance.signInWithPopup(authProvider);
    } else {
      // Initialize GoogleSignIn natively for Android/iOS
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return null; // The user canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    }
  } catch (e) {
    print("Error during Google Sign-In: $e");
    return null;
  }
}
