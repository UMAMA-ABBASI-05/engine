import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/server_model.dart';

class ServerDetailsScreen extends StatefulWidget {
  final int serverId;
  const ServerDetailsScreen({required this.serverId, super.key});

  @override
  State<ServerDetailsScreen> createState() => _ServerDetailsScreenState();
}

class _ServerDetailsScreenState extends State<ServerDetailsScreen> {
  final ApiService _apiService = ApiService();
  late Future<Server> _serverFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _serverFuture = _apiService.fetchSpecificServer(widget.serverId);
    });
  }

  Future<void> _showEditDialog(Server server) async {
    final nameCtrl = TextEditingController(text: server.name);
    final ipCtrl = TextEditingController(text: server.ip);
    final portCtrl = TextEditingController(text: server.port.toString());
    String protocol = server.protocol;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            'Edit Server',
            style: TextStyle(
              color: Color(0xFF1A365D),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(nameCtrl, 'Server Name'),
                const SizedBox(height: 10),
                _dialogField(ipCtrl, 'IP Address'),
                const SizedBox(height: 10),
                _dialogField(
                  portCtrl,
                  'Port',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: protocol,
                  decoration: InputDecoration(
                    labelText: 'Protocol',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  items: ['FHIR', 'HL7']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => protocol = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A365D),
              ),
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final ok = await _apiService.updateServer(
                    widget.serverId,
                    name: nameCtrl.text.trim(),
                    ip: ipCtrl.text.trim(),
                    port: int.tryParse(portCtrl.text) ?? server.port,
                    protocol: protocol,
                  );
                  if (!mounted) return;
                  if (ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Server updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _load();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Update failed'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.red,
                      ),
                    );
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteServer() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Server'),
        content: const Text(
          'Are you sure? This may also delete associated endpoints and routes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final ok = await _apiService.deleteServer(widget.serverId);
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Server deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delete failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: FutureBuilder<Server>(
          future: _serverFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF1A365D)),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(
                child: Text("Server details load nahi ho sakien"),
              );
            }

            final server = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 22.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Server Details",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A365D),
                            ),
                          ),
                          const SizedBox(height: 28),
                          _infoField("Server Name", server.name),
                          _infoField("Protocol", server.protocol),
                          _buildLabel("Status"),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: server.status == "Active"
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: server.status == "Active"
                                    ? Colors.green.shade200
                                    : Colors.red.shade200,
                              ),
                            ),
                            child: Text(
                              server.status,
                              style: TextStyle(
                                color: server.status == "Active"
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _infoField("IP", server.ip),
                          _infoField("Port", server.port.toString()),
                          _infoField("Category", server.category),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Buttons — always at bottom
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showEditDialog(server),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A365D),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Edit",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _deleteServer,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFFCCCCCC),
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Delete",
                            style: TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _dialogField(
    TextEditingController ctrl,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Color(0xFF1A1A2E),
        ),
      ),
    );
  }

  Widget _infoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 15, color: Color(0xFF333333)),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}
