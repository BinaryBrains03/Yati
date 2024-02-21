import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyB8uwSHXrG5_sYLFhqceNIaphAMZoCUsX4",
            authDomain: "yati-414805.firebaseapp.com",
            projectId: "yati-414805",
            storageBucket: "yati-414805.appspot.com",
            messagingSenderId: "613497193532",
            appId: "1:613497193532:web:f479787ef4abc94c55af39",
            measurementId: "G-25PW5848V6"));
  } else {
    await Firebase.initializeApp();
  }
}
