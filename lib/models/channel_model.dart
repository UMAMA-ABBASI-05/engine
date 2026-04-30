class Channel {
  final int channelId; // ← int? se int (non-nullable)
  final String channelName;
  final String source;
  final String destination;

  Channel({
    required this.channelId,
    required this.channelName,
    required this.source,
    required this.destination,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      channelId: json['channel_id'] ?? json['id'] ?? 0,
      channelName: json['channel_name'] ?? json['name'] ?? '',
      source: json['source'] ?? '',
      destination: json['destination'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'channel_id': channelId,
      'channel_name': channelName,
      'source': source,
      'destination': destination,
    };
  }

  @override
  String toString() => 'Channel(id: $channelId, name: $channelName)';
}
