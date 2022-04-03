import 'package:ectoplasm/model/server_info.dart';
import 'package:ectoplasm/prefs/app_preferences.dart';

class ServerList {
  static List<ServerInfo>? getServerList() {
    return AppPreferences.instance.sharedPref
        .read<List<ServerInfo>>('serverList');
  }

  static setServerList(List<ServerInfo> serverList) async {
    await AppPreferences.instance.sharedPref.write('serverList', serverList);
  }
}
