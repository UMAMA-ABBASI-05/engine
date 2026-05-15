import 'package:engine/screens/message_viewer_screen.dart';
import 'package:engine/services/api_service.dart';
import 'package:flutter/material.dart';

class MessageLogsScreen extends StatefulWidget {
  @override
  _MessageLogsScreen createState() => _MessageLogsScreen();
}

class _MessageLogsScreen extends State<MessageLogsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _logsFuture = _apiService.fetchAllLogs();
  }

  void _refreshLogs() {
    setState(() {
      _logsFuture = _apiService.fetchAllLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: const Color(0xFFF5F5F5),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: const Text(
                'Message Logs',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A365D),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _logsFuture,
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
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No logs found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  final logs = snapshot.data!;
                  return RefreshIndicator(
                    onRefresh: () async => _refreshLogs(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        final bool isSuccess = log['status'] == 'Success';
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MessageViewerScreen(log: log),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE8E8E8),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSuccess ? Icons.check_circle : Icons.cancel,
                                  color: isSuccess ? Colors.green : Colors.red,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        log['operation_heading'] ?? 'N/A',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color(0xFF1A365D),
                                        ),
                                      ),
                                      Text(
                                        log['operation_message'] ?? 'N/A',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Color(0xFF1A365D),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      const SizedBox(height: 3),
                                      Text(
                                        log['status'] ?? '',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isSuccess
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        log['datetime'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
