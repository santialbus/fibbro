import 'dart:io';
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:myapp/screens/edit_profile_page.dart';
import 'package:myapp/screens/main_navigation.dart';
import 'package:myapp/screens/notification_page.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'screens/auth_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().initialize();
  await requestExactAlarmPermission();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  final appDocDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocDir.path);
  await Hive.openBox('festivalCache');
  runApp(const MyApp());
}

Future<void> requestExactAlarmPermission() async {
  if (!Platform.isAndroid) return;

  final status = await Permission.scheduleExactAlarm.status;

  if (!status.isGranted) {
    final result = await Permission.scheduleExactAlarm.request();

    if (!result.isGranted) {
      await openAppSettings();
    }
  } else {}
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FIB Horarios',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      routes: {
        '/notifications': (context) {
          final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
          return NotificationsPage(userId: userId);
        },
        '/editProfile': (context) => const EditProfilePage(),
        '/home': (context) => const MainNavigation(),
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return const MainNavigation();
          } else {
            return const AuthPage();
          }
        },
      ),
    );
  }
}
