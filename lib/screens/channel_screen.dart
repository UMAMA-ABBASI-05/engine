import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'channel_details_screen.dart';
import 'add_channel_screen.dart';

class ChannelsScreen extends StatefulWidget {
  const ChannelsScreen({Key? key}) : super(key: key);

  @override
  State<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> allRoutes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllRoutes();
  }

  Future<void> fetchAllRoutes() async {
    try {
      final data = await _apiService.fetchAllRoutes();
      setState(() {
        allRoutes = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Channels",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A365D),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddChannelScreen(),
                        ),
                      ).then((_) => fetchAllRoutes());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A365D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Add Channels",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF1A365D)),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: allRoutes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final route = allRoutes[index];

                      // FIX: Aapke SQL table mein column 'name' hai
                      String channelNameFromDB =
                          route['channel_name']?.toString() ??
                          "Unnamed Channel";

                      return _ChannelCard(
                        channelName: channelNameFromDB,
                        sourceName: route['src_server']?['name'] ?? 'N/A',
                        destName: route['dest_server']?['name'] ?? 'N/A',
                        onView: () =>
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ChannelDetailsScreen(channel: route),
                              ),
                            ).then((deleted) {
                              if (deleted == true) fetchAllRoutes();
                            }),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  final String channelName;
  final String sourceName;
  final String destName;
  final VoidCallback onView;

  const _ChannelCard({
    required this.channelName,
    required this.sourceName,
    required this.destName,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  channelName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A365D),
                  ),
                ),
                const SizedBox(height: 6),
                _rowText("Source: ", sourceName),
                _rowText("Destination: ", destName),
              ],
            ),
          ),
          InkWell(
            onTap: onView,
            child: const Row(
              children: [
                Text(
                  "View",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1A365D),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Color(0xFF1A365D),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowText(String label, String value) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF1A365D),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
