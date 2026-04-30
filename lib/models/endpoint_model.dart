class Endpoint {
  final int? endpointId;
  final int serverId;
  final String url;
  final String? resource;
  final String? path;
  final String? name;

  Endpoint({
    this.endpointId,
    required this.serverId,
    required this.url,
    this.resource,
    this.path,
    this.name,
  });

  factory Endpoint.fromJson(Map<String, dynamic> json) {
    return Endpoint(
      endpointId: json['endpoint_id'],
      serverId: json['server_id'],
      url: json['url'],
      resource: json['resource'],
      path: json['path'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'server_id': serverId,
      'url': url,
      'resource': resource,
      'path': path,
      'name': name,
    };
  }
}
