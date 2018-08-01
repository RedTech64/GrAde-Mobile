import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'dart:async';

FirebaseAnalytics analytics = new FirebaseAnalytics();
FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

Future setupAnalytics(userID) async {
  await analytics.setUserId(userID);
  await analytics.setUserProperty(name: 'Mobile', value: 'true');
  await analytics.android?.setAnalyticsCollectionEnabled(true);
}

Future sendGradeAddEvent(grade,weight) async {
  await analytics.logEvent(
    name: 'grade_add',
    parameters: <String, dynamic>{
      'grade': grade,
      'weight': weight,
    },
  );
}

Future sendGradeDeleteEvent(grade,weight) async {
  await analytics.logEvent(
    name: 'grade_delete',
    parameters: <String, dynamic>{
      'grade': grade,
      'weight': weight,
    },
  );
}

Future sendCategoryAddEvent(name,weight) async {
  await analytics.logEvent(
    name: 'category_add',
    parameters: <String, dynamic>{
      'name': name,
      'weight': weight,
    },
  );
}

Future sendCategoryDeleteEvent(name,weight) async {
  await analytics.logEvent(
    name: 'category_delete',
    parameters: <String, dynamic>{
      'name': name,
      'weight': weight,
    },
  );
}

Future sendCategoryEditEvent(name,weight) async {
  await analytics.logEvent(
    name: 'category_edit',
    parameters: <String, dynamic>{
      'name': name,
      'weight': weight,
    },
  );
}

Future sendAverageAddEvent(name) async {
  await analytics.logEvent(
    name: 'average_add',
    parameters: <String, dynamic>{
      'name': name,
    },
  );
}

Future sendAverageDeleteEvent(name) async {
  await analytics.logEvent(
    name: 'average_delete',
    parameters: <String, dynamic>{
      'name': name,
    },
  );
}

Future sendAverageEditEvent(name) async {
  await analytics.logEvent(
    name: 'average_edit',
    parameters: <String, dynamic>{
      'name': name,
    },
  );
}

Future sendClassAddEvent(name,grade,qp,link) async {
  await analytics.logEvent(
    name: 'class_add',
    parameters: <String, dynamic>{
      'name': name,
      'grade': grade,
      'qp': qp,
      'link': link,
    },
  );
}

Future sendClassDeleteEvent(name,grade,qp,link) async {
  await analytics.logEvent(
    name: 'class_delete',
    parameters: <String, dynamic>{
      'name': name,
      'grade': grade,
      'qp': qp,
      'link': link,
    },
  );
}

Future sendClassEditEvent(name,grade,qp,link) async {
  await analytics.logEvent(
    name: 'class_edit',
    parameters: <String, dynamic>{
      'name': name,
      'grade': grade,
      'qp': qp,
      'link': link,
    },
  );
}

Future sendSwitchAccountEvent() async {
  await analytics.logEvent(
    name: 'class_edit',
  );
}

Future sendSettingsOpenEvent() async {
  await analytics.logEvent(
    name: 'settings_open',
  );
}
