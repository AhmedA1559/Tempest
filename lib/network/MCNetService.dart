import 'dart:async';

import 'package:ectoplasm/model/server_info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mcproj/ping_tool.dart';
import 'package:mcproj/protocol_structs.dart';
import 'package:mcproj/proxy.dart';

final currentServerProvider = StateNotifierProvider<ProxyConnector, ServerInfo?>((ref) {
  return ProxyConnector.instance;
});

class ProxyConnector extends StateNotifier<ServerInfo?> {
  ProxyConnector._internal() : super(null);

  static final ProxyConnector instance = ProxyConnector._internal();

  //ServerInfo? _currentServer;

  ServerInfo? get currentServer => state;
  set currentServer(serverInfo) {
    state = serverInfo;
  }

  Proxy? _proxy;
  get proxy => _proxy;

  Future<void> connect(ServerInfo serverInfo) async {
    if (currentServer != null) {
      stop();
    }

    currentServer = serverInfo;

    _proxy =
      await Proxy.bindRemote(host: serverInfo.host, port: serverInfo.port);
    _proxy!.start();
  }

  void stop() {
    _proxy?.stop();
    _proxy = null;
    currentServer = null;
  }

}
class PingProvider {
  Future<PongData?> pingServer(ServerInfo serverInfo) async {
    try {
      return await PingTool.ping(host: serverInfo.host, port: serverInfo.port);
    } catch (error) {
      return null;
    }
  }
}
