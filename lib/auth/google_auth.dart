import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

Future<UserCredential?> signInWithGoogle() async {
  try {
    // Initialize GoogleSignIn with the Web Client ID if on the web
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: kIsWeb
          ? '275567862972-ol86fje7026j3akfbjvh05n6rie3qhiv.apps.googleusercontent.com'
          : null,
    );

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
  } catch (e) {
    print("Error during Google Sign-In: $e");
    return null;
  }
}
