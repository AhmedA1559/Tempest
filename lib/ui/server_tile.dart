import 'package:ectoplasm/model/server_info.dart';
import 'package:ectoplasm/network/MCNetService.dart';
import 'package:ectoplasm/services/proxy_foreground.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mcproj/ping_tool.dart';
import 'package:mcproj/protocol_structs.dart';

import 'alert_dialog.dart';

final dummyProvider = Provider<Future<void>>((_) async {
  await null;
});

final pingProvider =
    FutureProvider.family<PongData, ServerInfo>((ref, serverInfo) {
  ref.watch(dummyProvider);
  return PingTool.ping(host: serverInfo.host, port: serverInfo.port);
});

class ServerTile extends ConsumerStatefulWidget {
  ServerInfo server;
  final Function(ServerInfo, bool) onPlay;
  final Function(ServerInfo) onEdit;
  final VoidCallback onDelete;
  ServerTile(
      {Key? key,
      required this.server,
      required this.onPlay,
      required this.onEdit,
      required this.onDelete})
      : super(key: key);

  @override
  _ServerTileState createState() =>
      _ServerTileState(server, onPlay, onEdit, onDelete);
}

class _ServerTileState extends ConsumerState<ServerTile> {
  ServerInfo serverInfo;
  final Function(ServerInfo, bool) onPlay;
  final Function(ServerInfo) onEdit;
  final VoidCallback onDelete;

  _ServerTileState(this.serverInfo, this.onPlay, this.onEdit, this.onDelete);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(pingProvider(serverInfo)).when(
          data: _buildExpansionCard,
          loading: () {
            return const SizedBox(
                width: 100, height: 100, child: CircularProgressIndicator());
          },
          error: (Object error, StackTrace? stackTrace) {
            return _buildExpansionCard(null);
          },
        );
  }

  Widget _buildExpansionCard(PongData? pongData) {
    return ExpansionTileCard(
      key: PageStorageKey(serverInfo.uuid),
      title: Text(serverInfo.name),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(serverInfo.host),
        pongData != null
            ? Text("${pongData.players}/${pongData.maxPlayers}")
            : const Text("OFFLINE") // TODO: move hardcoded strings to i18n
      ]),
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          pongData != null // if it's null, it's offline
              ? const Icon(
                  Icons.circle,
                  color: Colors.green,
                )
              : const Icon(
                  Icons.circle,
                  color: Colors.red,
                ),
        ],
      ),
      children: [
        const Divider(
          height: 1.0,
        ),
        ButtonBar(
          alignment: MainAxisAlignment.spaceAround,
          children: [
            _buildPlayButton(),
            _buildButton(
                onPressed: () {
                  editInfo(context, initialServerInfo: serverInfo,
                      onComplete: (editedInfo) {
                    setState(() {
                      serverInfo = editedInfo;
                    });
                    onEdit(editedInfo);
                  });
                },
                icon: Icons.edit),
            _buildButton(onPressed: onDelete, icon: Icons.delete),
          ],
        )
      ],
    );
  }

  Widget _buildPlayButton() {
    final isServerSelected = ref.watch(currentServerProvider) == serverInfo;

    return _buildButton(
              onPressed: () {
                onPlay(serverInfo, isServerSelected);
              },
              icon: isServerSelected ? Icons.pause : Icons.play_arrow);
  }

  Widget _buildButton({required Function() onPressed, required IconData icon}) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon),
        ],
      ),
    );
  }
}
