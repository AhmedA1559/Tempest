import 'package:uuid/uuid.dart';

class ServerInfo {
  final String name;
  final String host;
  final int port;
  late final String? uuid;

//<editor-fold desc="Data Methods">

  ServerInfo({
    uuid,
    required this.name,
    required this.host,
    required this.port,
  }) {
    uuid ??= const Uuid().v4();
    this.uuid = uuid;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServerInfo &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          host == other.host &&
          port == other.port &&
          uuid == other.uuid);

  @override
  int get hashCode =>
      name.hashCode ^ host.hashCode ^ port.hashCode ^ uuid.hashCode;

  @override
  String toString() {
    return 'ServerInfo{' +
        ' name: $name,' +
        ' host: $host,' +
        ' port: $port,' +
        ' uuid: $uuid,' +
        '}';
  }

  ServerInfo copyWith({
    String? name,
    String? host,
    int? port,
    String? uuid,
  }) {
    return ServerInfo(
      name: name ?? this.name,
      host: host ?? this.host,
      port: port ?? this.port,
      uuid: uuid ?? this.uuid,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'host': this.host,
      'port': this.port,
      'uuid': this.uuid,
    };
  }

  factory ServerInfo.fromMap(Map<String, dynamic> map) {
    return ServerInfo(
      name: map['name'] as String,
      host: map['host'] as String,
      port: map['port'] as int,
      uuid: map['uuid'] as String,
    );
  }

//</editor-fold>
}
