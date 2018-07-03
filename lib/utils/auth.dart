import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

FirebaseUser user;
String userID;
final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();

Future<bool> signInWithGoogle(bool force) async {
  GoogleSignInAccount googleUser;
  if(force) {
    googleUser = await _googleSignIn.signIn();
  } else {
    googleUser = await _googleSignIn.signInSilently();
    if(googleUser == null) {
      googleUser = await _googleSignIn.signIn();
    }
  }

  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  user = await _auth.signInWithGoogle(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  if(user == null) {
    return false;
  } else {
    userID = user.providerData[0].uid;
    return true;
  }
}

Future<void> switchAccounts() async {
  await _googleSignIn.signOut();
  await signInWithGoogle(true);
}