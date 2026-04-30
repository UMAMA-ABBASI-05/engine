class EndpointField {
  final int endpointFieldId;
  final int endpointId;
  final String resource; // e.g. "Patient" or "PID"
  final String path; // e.g. "Patient-identifier[0].value"
  final String name; // e.g. "mpi", "fullname"

  EndpointField({
    required this.endpointFieldId,
    required this.endpointId,
    required this.resource,
    required this.path,
    required this.name,
  });

  factory EndpointField.fromJson(Map<String, dynamic> json) {
    return EndpointField(
      endpointFieldId: json['endpoint_field_id'] as int,
      endpointId: json['endpoint_id'] as int,
      resource: json['resource'] as String,
      path: json['path'] as String,
      name: json['name'] as String,
    );
  }
}
