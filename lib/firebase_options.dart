import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCxjs9xJOJXqqRvpejolvvYlSZlRm7l-XQ',
    appId: '1:163840053579:web:bc6eee3b4df5fbfa9558ce',
    messagingSenderId: '163840053579',
    projectId: 'cogninews-3f6c1',
    authDomain: 'cogninews-3f6c1.firebaseapp.com',
    storageBucket: 'cogninews-3f6c1.firebasestorage.app',
    measurementId: 'G-X783Y8XV95',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB59Q4wv807E_Cq-z6K2IapgFqTgPnb2Q4',
    appId: '1:163840053579:android:f840353df82109349558ce',
    messagingSenderId: '163840053579',
    projectId: 'cogninews-3f6c1',
    storageBucket: 'cogninews-3f6c1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyChOpRIxC68a9PTozNBr_2OtJwLX4G68_c',
    appId: '1:163840053579:ios:62418ffde245fdb49558ce',
    messagingSenderId: '163840053579',
    projectId: 'cogninews-3f6c1',
    storageBucket: 'cogninews-3f6c1.firebasestorage.app',
    iosBundleId: 'com.example.cogniNews',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyChOpRIxC68a9PTozNBr_2OtJwLX4G68_c',
    appId: '1:163840053579:ios:62418ffde245fdb49558ce',
    messagingSenderId: '163840053579',
    projectId: 'cogninews-3f6c1',
    storageBucket: 'cogninews-3f6c1.firebasestorage.app',
    iosBundleId: 'com.example.cogniNews',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCxjs9xJOJXqqRvpejolvvYlSZlRm7l-XQ',
    appId: '1:163840053579:web:6027bc07497b16cc9558ce',
    messagingSenderId: '163840053579',
    projectId: 'cogninews-3f6c1',
    authDomain: 'cogninews-3f6c1.firebaseapp.com',
    storageBucket: 'cogninews-3f6c1.firebasestorage.app',
    measurementId: 'G-R7WTCB3RR9',
  );
}
