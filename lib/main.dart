import 'package:ectoplasm/prefs/app_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'model/server_info.dart';
import 'model/server_list.dart';
import 'screen/server_list_screen.dart';
import 'services/proxy_foreground.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppPreferences.init();
  await ProxySession.initForegroundTask();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tempest',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const WithForegroundTask(child: ServerListScreen()),
    );
  }
}
