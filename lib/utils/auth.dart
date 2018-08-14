import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
FirebaseUser user;
GoogleSignInAccount googleUser;
String userID;
bool simpleFAB;
final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();

class SignInData {
  String uid;
  bool simpleFAB;
  bool signedin;

  SignInData(this.uid,this.simpleFAB,this.signedin);
}

Future initFCM() async{
  _firebaseMessaging.requestNotificationPermissions();
  _firebaseMessaging.configure(
    onMessage: (Map<String,dynamic> message) {print('test');},
    onLaunch: (Map<String,dynamic> message) {},
    onResume: (Map<String,dynamic> message) {},
  );
}

Future setupFRC() async {
  final RemoteConfig remoteConfig = await RemoteConfig.instance;
}

Future<SignInData> signInWithGoogle(bool silently) async {
  if(silently) {
    googleUser = await _googleSignIn.signInSilently();
    if(googleUser == null) {
      return new SignInData("", false, false);
    }
  } else {
    try {
      googleUser = await _googleSignIn.signIn();
    } catch(e) {
      return new SignInData("", false, false);
    }
  }

  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  user = await _auth.signInWithGoogle(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  if(user == null) {
    return new SignInData("", false, false);
  } else {
    userID = user.uid.toString();
    setupAnalytics(userID);
    await setupData();
    await setupFRC();
    initFCM();
    return new SignInData(user.uid, simpleFAB, true);
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
    if(userDoc.data['simpleFAB'] == null) {
      simpleFAB = false;
      await updateSettings();
    } else {
      simpleFAB = userDoc.data['simpleFAB'];
    }
    return userDocRef.updateData({
      'name': googleUser.displayName,
      'email': googleUser.email,
      'id': user.uid,
      'mobile': true,
    });
  } else {
    simpleFAB = false;
    return userDocRef.setData({
      'name': googleUser.displayName,
      'email': googleUser.email,
      'id': user.uid,
      'mobile': true,
      'simpleFAB': false,
    });
  }
}

Future updateSettings() async {
  DocumentReference userDocRef = Firestore.instance.collection('users').document(userID);
  userDocRef.updateData({
    'simpleFAB': simpleFAB
  });
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