class MessageLogs {
  final int logId;
  final String dateTime;
  final String status;
  final String operationHeading;
  final String operationMessage;
  final String? scrMessage;
   final String? destMessage;

  MessageLogs({
    required this.logId,
    required this.dateTime,
    required this.status,
    required this.operationHeading,
    required this.operationMessage,
    this.scrMessage,
    this.destMessage,
  });

  factory MessageLogs.fromJson(Map<String, dynamic> json) {
    return MessageLogs(
      logId: json['log_id'],
      dateTime: json['datetime'],
      status: json['status'],
      operationHeading: json['operation_heading'],
      operationMessage: json['operation_message'],
      scrMessage: json['scr_message'],
      destMessage: json['dest_message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'log_id': logId,
      'datetime': dateTime,
      'status': status,
      'operation_heading': operationHeading,
      'operation_message': operationMessage,
      'scr_message': scrMessage,
      'dest_message': destMessage,
    };
  }
}
  