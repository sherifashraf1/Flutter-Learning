import 'package:firebase_auth/firebase_auth.dart';
import '../../sign_in_methods/sign_in_methods.dart';

class FirebaseServices {
 static Future<void> signIn(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

 static Future<UserCredential?> signInWithGoogle() async {
    return await SignInMethods.signInWithGoogle();
  }

 static Future<void> createAccount(String email, String password) async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

 static Future<void> resetPassword(String email) async {
   await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
 }

 static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
