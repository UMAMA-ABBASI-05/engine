import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChannelDetailsScreen extends StatefulWidget {
  final dynamic channel;
  const ChannelDetailsScreen({Key? key, required this.channel})
    : super(key: key);

  @override
  State<ChannelDetailsScreen> createState() => _ChannelDetailsScreenState();
}

class _ChannelDetailsScreenState extends State<ChannelDetailsScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> mappingRules = [];
  bool isLoadingMapping = true;

  @override
  void initState() {
    super.initState();
    fetchMappingRules();
  }

  Widget _buildMappingTile(dynamic rule) {
    try {
      String srcName;
      if (rule['src_field'] is List) {
        srcName = (rule['src_field'] as List)
            .map((f) => f['name'] ?? f['path'] ?? '')
            .join(' + ');
      } else if (rule['src_field'] is Map) {
        srcName =
            rule['src_field']?['name'] ?? rule['src_field']?['path'] ?? '?';
      } else {
        srcName = rule['src_field']?.toString() ?? '?';
      }

      String destName;
      if (rule['dest_field'] is List) {
        destName = (rule['dest_field'] as List)
            .map((f) => f['name'] ?? f['path'] ?? '')
            .join(' + ');
      } else if (rule['dest_field'] is Map) {
        destName =
            rule['dest_field']?['name'] ?? rule['dest_field']?['path'] ?? '?';
      } else {
        destName = rule['dest_field']?.toString() ?? '?';
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                srcName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A365D),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
            ),
            Expanded(
              child: Text(
                destName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A365D),
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          'Rule load failed: $e',
          style: const TextStyle(fontSize: 12, color: Colors.red),
        ),
      );
    }
  }

  Future<void> fetchMappingRules() async {
    try {
      // Aapke DB screenshot ke mutabiq ID key 'route_id' hai
      final id = widget.channel['route_id'] ?? widget.channel['id'];
      if (id != null) {
        final data = await _apiService.fetchMappingRules(id);
        debugPrint("Rules data: ${data.toString()}");
        setState(() {
          mappingRules = data;
          isLoadingMapping = false;
        });
      } else {
        setState(() => isLoadingMapping = false);
      }
    } catch (e) {
      setState(() => isLoadingMapping = false);
      debugPrint("Mapping Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // FIX: Using 'name' from DB instead of hardcoded strings
    final String displayName =
        widget.channel['channel_name']?.toString() ?? "Unknown";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Channel Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailField('Channel Name', displayName),
            _buildDetailField(
              'Source Server',
              widget.channel['src_server']?['name'] ?? 'N/A',
            ),
            _buildDetailField(
              'Source Endpoint',
              widget.channel['src_endpoint']?['url'] ?? 'N/A',
            ),
            _buildDetailField(
              'Destination Server',
              widget.channel['dest_server']?['name'] ?? 'N/A',
            ),
            _buildDetailField(
              'Destination Endpoint',
              widget.channel['dest_endpoint']?['url'] ?? 'N/A',
            ),
            _buildDetailField('Msg Type', widget.channel['msg_type'] ?? 'N/A'),
            const SizedBox(height: 25),
            const Center(
              child: Text(
                'Mapping',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A365D),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Mapping Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: isLoadingMapping
                  ? const Center(child: CircularProgressIndicator())
                  : mappingRules.isEmpty
                  ? const Text(
                      'No mappings configured',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: mappingRules.map<Widget>((rule) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: _buildMappingTile(rule),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 30),
            _buildDeleteButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () async {
          // Confirm dialog
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Delete Route'),
              content: const Text(
                'Are you sure you want to delete this route and all its mapping rules?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Color.fromARGB(255, 2, 39, 70)),
                  ),
                ),
              ],
            ),
          );

          if (confirm != true) return;

          final routeId = widget.channel['route_id'] ?? widget.channel['id'];
          if (routeId == null) return;

          try {
            final ok = await _apiService.deleteRoute(routeId);
            if (!mounted) return;
            if (ok) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Route deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context, true); // Previous screen ko refresh signal
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to delete route'),
                  backgroundColor: Color.fromARGB(255, 2, 41, 73),
                ),
              );
            }
          } catch (e) {
            if (mounted)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                  backgroundColor: const Color.fromARGB(255, 2, 42, 75),
                ),
              );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 3, 40, 71),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: const Text(
          'Delete',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
