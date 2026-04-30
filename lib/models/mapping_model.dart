class MappingRule {
  final int mappingRuleId;
  final String transformType; // copy, split, concat, etc.
  final Map<String, dynamic> config;
  final Map<String, dynamic> srcField;
  final dynamic destField; // dynamic rakha hai kyunki split mein list aati hai

  MappingRule({
    required this.mappingRuleId,
    required this.transformType,
    required this.config,
    required this.srcField,
    required this.destField,
  });

  factory MappingRule.fromJson(Map<String, dynamic> json) {
    return MappingRule(
      mappingRuleId: json['mapping_rule_id'],
      transformType: json['transform_type'],
      config: json['config'] ?? {},
      srcField: json['src_field'],
      destField: json['dest_field'],
    );
  }
}
