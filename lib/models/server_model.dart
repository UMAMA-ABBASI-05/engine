class Server {
  final int serverId;
  final String name;
  final String ip;
  final String systemIp;
  final int port;
  final String protocol;
  final String status;
  final String category;

  Server({
    required this.serverId,
    required this.name,
    required this.ip,
    required this.systemIp,
    required this.port,
    required this.protocol,
    required this.status,
    required this.category,
  });

  // JSON se Dart object banane ke liye
  factory Server.fromJson(Map<String, dynamic> json) {
    return Server(
      serverId: json['server_id'],
      name: json['name'] ?? '',
      ip: json['ip'] ?? '',
      systemIp: json['system_ip'] ?? '',
      port: json['port'] ?? 0,
      protocol: json['protocol'] ?? '',
      status: json['status'] ?? 'Inactive',
      category: json['category'] ?? 'Uncategorized',
    );
  }
}
