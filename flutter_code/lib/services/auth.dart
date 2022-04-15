import 'package:firebase_auth/firebase_auth.dart';
import 'package:isdp/models/app_user.dart';
import 'package:isdp/services/database.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create user object based on FirebaseUser
  AppUser? _userFromFirebaseUser(User? user) {
    if (user != null) {
      return AppUser(
        uid: user.uid,
        email: user.email.toString()
      );
    } else {
      return null;
    }
  }

  // Auth change user stream
  Stream<AppUser?> get user {
    return _auth.authStateChanges().map((User? user) => _userFromFirebaseUser(user));
  }

  // Sign up
  Future register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        print('Updating user data...');
        print('Updating user data...');
        print('Updating user data...');
        await DatabaseService(uid: user.uid).updateUserData(
            user.uid,
            '',
            user.email.toString().contains('patient.com') ? 'patient' : 'doctor',
            '',
            '',
            {},
            false,
            0,
            0,
            0,
            0
        );
      }

      return _userFromFirebaseUser(user);
    } catch(e) {
      if (e.toString().contains('email-already-in-use')) {
        print('Email Used');
        return 0;
      } else {
        print(e.toString());
        return null;
      }
    }
  }

  // Sign in
  Future signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      return _userFromFirebaseUser(user);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  // Sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

}