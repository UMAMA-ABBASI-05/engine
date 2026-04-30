import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/server_model.dart';
import '../core/constants.dart';
import 'server_details_screen.dart';
import 'add_server_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Server>> _serversFuture;

  @override
  void initState() {
    super.initState();
    _serversFuture = _apiService.fetchAllServers();
  }

  void _refreshServers() {
    setState(() {
      _serversFuture = _apiService.fetchAllServers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // ── Title ───────────────────────────────────────────────
              const Text(
                "Dashboard",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A365D),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 24),

              // ── Stats Card ──────────────────────────────────────────
              _buildStatsCard(),
              const SizedBox(height: 32),

              // ── Servers Header ──────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Servers",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A365D),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final refresh = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddServerScreen(),
                        ),
                      );
                      if (refresh == true) _refreshServers();
                    },
                    icon: const Icon(Icons.add, size: 18, color: Colors.white),
                    label: const Text(
                      "Add Server",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A365D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Server Table ────────────────────────────────────────
              _buildServerTable(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3B6FF0).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _statText("Total Servers Connected: ", "4"),
          const Divider(height: 20, color: Color(0xFFEEEEEE)),
          _statText("Today's Message Received: ", "10"),
          const SizedBox(height: 8),
          _statText("Today's Message Sent: ", "10"),
          const SizedBox(height: 8),
          _statText("Today's Error: ", "0", isError: true),
        ],
      ),
    );
  }

  Widget _statText(String label, String value, {bool isError = false}) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 15,
          color: isError ? Colors.red : const Color(0xFF1A365D),
        ),
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildServerTable() {
    return FutureBuilder<List<Server>>(
      future: _serversFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF1A365D)),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error loading servers',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700])),
                const SizedBox(height: 8),
                Text(snapshot.error.toString(),
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey[600]),
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _refreshServers,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A365D)),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.dns_outlined, color: Colors.grey[400], size: 48),
                const SizedBox(height: 16),
                Text('No Servers Found',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700])),
                const SizedBox(height: 8),
                Text('Add your first server to get started',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          );
        }

        // ── Data Table ──────────────────────────────────────────────
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8E8E8)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor:
                  WidgetStateProperty.all(const Color(0xFFF8F8F8)),
              headingRowHeight: 50,
              dataRowHeight: 58,
              dividerThickness: 1,
              columns: const [
                DataColumn(
                  label: Text('Server Name',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF1A365D))),
                ),
                DataColumn(
                  label: Text('Protocol',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF1A365D))),
                ),
                DataColumn(
                  label: Text('status',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF1A365D))),
                ),
                DataColumn(
                  label: Text('View Details',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF1A365D))),
                ),
              ],
              rows: snapshot.data!
                  .map((server) => DataRow(cells: [
                        DataCell(Text(server.name,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500))),
                        DataCell(Text(server.protocol,
                            style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF1A365D),
                                fontWeight: FontWeight.w600))),
                        DataCell(Text(
                          server.status,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: server.status == "Active"
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        )),
                        DataCell(
                          InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) => ServerDetailsScreen(
                                    serverId: server.serverId),
                              ),
                            ),
                            child: const Text(
                              "View >",
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF1A365D),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ]))
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}