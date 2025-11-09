import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:promillezone/constant.dart';
import 'package:promillezone/firebase_options.dart';
import 'package:promillezone/route.dart';
import 'package:promillezone/ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: appName,
      theme: lightTheme,
      routerConfig: routerConfig,
    );
  }
}
