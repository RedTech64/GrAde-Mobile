import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
FirebaseUser user;
GoogleSignInAccount googleUser;
String userID;
final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();

Future initFCM() async{
  _firebaseMessaging.requestNotificationPermissions();
  _firebaseMessaging.configure(
    onMessage: (Map<String,dynamic> message) {print('test');},
    onLaunch: (Map<String,dynamic> message) {},
    onResume: (Map<String,dynamic> message) {},
  );
}

Future<bool> signInWithGoogle(bool silently) async {
  if(silently) {
    googleUser = await _googleSignIn.signInSilently();
    if(googleUser == null) {
      return false;
    }
  } else {
    googleUser = await _googleSignIn.signIn();
  }

  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  user = await _auth.signInWithGoogle(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  if(user == null) {
    return false;
  } else {
    userID = user.providerData[0].uid.toString();
    await setupData();
    await initFCM();
    return true;
  }
}

Future<void> switchAccounts() async {
  await _googleSignIn.signOut();
  await signInWithGoogle(false);
}

Future setupData() async {
  DocumentReference userDocRef = Firestore.instance.collection('users').document(userID);
  DocumentSnapshot userDoc = await userDocRef.get();
  if(userDoc.exists) {
    return userDocRef.updateData({
      'name': googleUser.displayName,
      'email': googleUser.email,
      'id': user.uid,
      'mobile': true,
    });
  } else {
    return userDocRef.setData({
      'name': googleUser.displayName,
      'email': googleUser.email,
      'id': user.uid,
      'mobile': true,
    });
  }
}

Future deleteData() async {
  DocumentReference userDoc = Firestore.instance.collection('users').document(userID);
  var averageDocs = await userDoc.collection('averages').getDocuments();
  averageDocs.documents.forEach((doc) {
    doc.reference.delete();
  });
  var classDocs = await userDoc.collection('classes').getDocuments();
  classDocs.documents.forEach((doc) {
    doc.reference.delete();
  });
  await Firestore.instance.collection('users').document(userID).delete();
  return await setupData();
}