import 'dart:convert';
import 'dart:isolate';

import 'package:ectoplasm/model/server_info.dart';
import 'package:ectoplasm/network/MCNetService.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void startCallback() {
  FlutterForegroundTask.setTaskHandler(ProxyHandler());
}

class ProxyHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    try {
      await ProxyConnector.instance.connect(await getServerInfo());
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<ServerInfo> getServerInfo() async {
    (await SharedPreferences.getInstance()).reload();
    final rawJson =
        await FlutterForegroundTask.getData<String>(key: 'serverInfo');
    return ServerInfo.fromMap(json.decode(rawJson!));
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    final serverInfo = ProxyConnector.instance.currentServer;

    if (serverInfo == null) {
      return;
    }

    if (ProxyConnector.instance.proxy.online) {
      FlutterForegroundTask.updateService(
          notificationTitle: 'Connected to ${serverInfo.name}',
          notificationText: '${serverInfo.host}:${serverInfo.port}');
    } else {
      FlutterForegroundTask.updateService(
          notificationTitle: ' ${serverInfo.name} is offline',
          notificationText: '${serverInfo.host}:${serverInfo.port}');
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    ProxyConnector.instance.stop();
  }

  @override
  void onButtonPressed(String id) {
    if (id == 'stopButton') {
      FlutterForegroundTask.stopService();
    }
  }
}

class ProxySession {
  Future<void> startConnect(ServerInfo serverInfo, WidgetRef ref) async {
    (await SharedPreferences.getInstance()).reload();
    await FlutterForegroundTask.saveData(
        key: 'serverInfo', value: json.encode(serverInfo.toJson()));

    (await SharedPreferences.getInstance()).reload();

    if (await FlutterForegroundTask.isRunningService) {
      await stop();
    }

    ref.read(currentServerProvider.notifier).currentServer = serverInfo;

    await FlutterForegroundTask.startService(
      notificationTitle: 'Connecting to ${serverInfo.name}',
      notificationText: '${serverInfo.host}:${serverInfo.port}',
      callback: startCallback,
    );
  }

  Future<void> stop() async {
    await FlutterForegroundTask.stopService();
    ProxyConnector.instance.stop();
  }

  static Future<void> initForegroundTask() async {
    await FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notification_channel_id',
        channelName: 'tempest',
        channelDescription: 'tempest proxy service',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        buttons: [
          const NotificationButton(id: 'stopButton', text: 'Stop'),
        ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        autoRunOnBoot: false,
        allowWifiLock: true,
      ),
      printDevLog: true,
    );
  }
}
