import 'package:ectoplasm/model/server_info.dart';
import 'package:ectoplasm/model/server_list.dart';
import 'package:ectoplasm/services/proxy_foreground.dart';
import 'package:ectoplasm/ui/alert_dialog.dart';
import 'package:ectoplasm/ui/server_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ServerListScreen extends ConsumerStatefulWidget {
  const ServerListScreen({Key? key}) : super(key: key);

  @override
  _ServerScreenWidgetState createState() => _ServerScreenWidgetState();
}

class _ServerScreenWidgetState extends ConsumerState<ServerListScreen> {
  final List<ServerInfo> _serverListData =
      ServerList.getServerList() ?? <ServerInfo>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addConfirm(context);
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text("Tempest"),
      ),
      body: Center(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(dummyProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: _serverListData.length,
            itemBuilder: (BuildContext context, int index) {
              return ServerTile(
                  key: UniqueKey(),
                  server: _serverListData[index],
                  onPlay: (serverInfo, isConnected) {
                    if (!isConnected) {
                      ProxySession().startConnect(serverInfo, ref);
                    } else {
                      ProxySession().stop();
                    }
                  },
                  onEdit: (serverInfo) {
                    _serverListData[index] = serverInfo;
                    ServerList.setServerList(_serverListData);
                  },
                  onDelete: () {
                    _deleteConfirm(context, index);
                  });
            },
          ),
        ),
      ),
    );
  }

  void _addConfirm(BuildContext context) {
    editInfo(context,
        onComplete: (editedInfo) {
          setState(() {
            _serverListData.add(editedInfo);
            ServerList.setServerList(
                _serverListData);
          });});
  }

  void _deleteConfirm(BuildContext context, int index) {
    showConfirmationDialog(context,
        title: "Delete ${_serverListData[index].name}?",
        body: "Are you sure you want to delete this?", onComplete: (confirm) {
      if (confirm) {
        setState(() {
          _serverListData.removeAt(index);
          ServerList.setServerList(
              _serverListData); // TODO: use change provider to save automatically when list is modified
        });
      }
      Navigator.of(context).pop();
    });
  }
}
