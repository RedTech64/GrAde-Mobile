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
GoogleSignIn _googleSignIn = new GoogleSignIn();

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
  GoogleSignInAuthentication googleAuth;
  if(googleUser == null) {
    return new SignInData("", false, false);
  } else {
    googleAuth = await googleUser.authentication;
  }
  final AuthCredential credential = GoogleAuthProvider.getCredential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
  user = await _auth.signInWithCredential(credential);
  if(user == null) {
    return new SignInData("", false, false);
  } else {
    userID = user.uid.toString();
    setupAnalytics(userID);
    await setupData(user.uid.toString());
    await setupFRC();
    initFCM();
    return new SignInData(user.uid, simpleFAB, true);
  }
}

Future<SignInData> signInAnonymously() async {
  user = await _auth.signInAnonymously();
  userID = user.uid.toString();
  String uid = user.uid.toString();
  setupAnalytics(userID);
  await setupData(user.uid.toString());
  await setupFRC();
  initFCM();
  return new SignInData(uid, simpleFAB, true);
}

Future<void> signOut() async {
  print(_googleSignIn.currentUser);
  try {
    await _googleSignIn.disconnect();
  } catch (error) {
    print(error.toString());
  }
  await _googleSignIn.signOut();
  user = null;
  googleUser = null;
  userID = null;
  _googleSignIn = null;

  _googleSignIn = new GoogleSignIn();
}

Future setupData(id) async {
  DocumentReference userDocRef = Firestore.instance.collection('users').document(id);
  DocumentSnapshot userDoc = await userDocRef.get();
  if(userDoc.exists) {
    if(userDoc.data['simpleFAB'] == null) {
      simpleFAB = false;
      await updateSettings();
    } else {
      simpleFAB = userDoc.data['simpleFAB'];
    }
    if(googleUser != null) {
      await userDocRef.updateData({
        'name': googleUser.displayName,
        'email': googleUser.email,
      });
    }
    await userDocRef.updateData({
      'id': id,
      'mobile': true,
    });
  } else {
    simpleFAB = false;
    await userDocRef.setData({
      'id': id,
      'mobile': true,
      'simpleFAB': false,
    });
    if(googleUser != null) {
      await userDocRef.updateData({
        'name': googleUser.displayName,
        'email': googleUser.email,
      });
    }
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
  return await setupData(userID);
}