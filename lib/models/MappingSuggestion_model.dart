class MappingSuggestion {
  final List<int> srcFieldIds;
  final List<int> destFieldIds;
  final List<String> srcNames;
  final List<String> destNames;
  final String transformType;
  final Map<String, dynamic> config;

  MappingSuggestion({
    required this.srcFieldIds,
    required this.destFieldIds,
    required this.srcNames,
    required this.destNames,
    required this.transformType,
    required this.config,
  });

  factory MappingSuggestion.fromJson(Map<String, dynamic> json) {
    return MappingSuggestion(
      srcFieldIds: List<int>.from(json['src_field_ids']),
      destFieldIds: List<int>.from(json['dest_field_ids']),
      srcNames: List<String>.from(json['src_names']),
      destNames: List<String>.from(json['dest_names']),
      transformType: json['transform_type'],
      config: json['config'] ?? {},
    );
  }
}