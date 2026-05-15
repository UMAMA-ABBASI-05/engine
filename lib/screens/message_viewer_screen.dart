import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MessageViewerScreen extends StatefulWidget {
  final Map<String, dynamic> log;
  const MessageViewerScreen({super.key, required this.log});

  @override
  State<MessageViewerScreen> createState() => _MessageViewerScreenState();
}

class _MessageViewerScreenState extends State<MessageViewerScreen> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _msgFuture; // ← Map

  @override
  void initState() {
    super.initState();
    final logId = widget.log['log_id'] ?? widget.log['id'];
    _msgFuture = _apiService.fetchLogMessage(logId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Message Viewer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A365D),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                // ← Map
                future: _msgFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1A365D),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final data = snapshot.data!;
                  final srcMsg = data['src_message']?.toString() ?? 'N/A';
                  final destMsg = data['dest_message']?.toString() ?? 'N/A';
                  final status = data['status'] ?? '';
                  final service = data['operation_heading'] ?? '';
                  final timestamp = data['datetime'] ?? '';

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service Info Card
                        // Container(
                        //   width: double.infinity,
                        //   padding: const EdgeInsets.all(14),
                        //   decoration: BoxDecoration(
                        //     color: Colors.white,
                        //     borderRadius: BorderRadius.circular(12),
                        //     border: Border.all(color: const Color(0xFFE8E8E8)),
                        //   ),
                        // child: Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Row(
                        //       children: [
                        //         Icon(
                        //           status == 'Success'
                        //               ? Icons.check_circle
                        //               : Icons.cancel,
                        //           color: status == 'Success'
                        //               ? Colors.green
                        //               : Colors.red,
                        //           size: 20,
                        //         ),
                        //         const SizedBox(width: 8),
                        //         Text(
                        //           service,
                        //           style: const TextStyle(
                        //             fontWeight: FontWeight.bold,
                        //             fontSize: 15,
                        //             color: Color(0xFF1A365D),
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //     const SizedBox(height: 6),
                        //     Text(
                        //       timestamp,
                        //       style: const TextStyle(
                        //         fontSize: 12,
                        //         color: Colors.grey,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        //),
                        const SizedBox(height: 24),

                        // Src Message
                        const Text(
                          'Src Message',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A365D),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE8E8E8)),
                          ),
                          child: Text(
                            srcMsg,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              fontFamily: 'monospace',
                              height: 1.6,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Dest Message
                        const Text(
                          'Dest Message',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A365D),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE8E8E8)),
                          ),
                          child: Text(
                            destMsg,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              fontFamily: 'monospace',
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
