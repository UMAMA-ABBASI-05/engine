import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/server_model.dart';
import '../models/endpoint_model.dart';
import '../models/endpoint_field_model.dart';

class AddChannelScreen extends StatefulWidget {
  const AddChannelScreen({Key? key}) : super(key: key);

  @override
  State<AddChannelScreen> createState() => _AddChannelScreenState();
}

class _AddChannelScreenState extends State<AddChannelScreen> {
  final ApiService apiService = ApiService();
  final TextEditingController channelNameController = TextEditingController();

  List<Server> servers = [];
  Server? selectedSourceServer;
  Server? selectedDestinationServer;

  List<Endpoint> sourceEndpoints = [];
  Endpoint? selectedSourceEndpoint;

  List<Endpoint> destinationEndpoints = [];
  Endpoint? selectedDestinationEndpoint;

  Map<String, List<EndpointField>> sourceFieldsGrouped = {};
  Map<String, List<EndpointField>> destinationFieldsGrouped = {};

  Set<int> selectedSourceFieldIds = {};
  Set<int> selectedDestinationFieldIds = {};
  List<Map<String, dynamic>> finalMappings = [];

  final List<String> messageTypes = ["ADT", "ORM", "ORU", "DFT"];
  String? selectedMessageType;

  bool isLoading = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fetchServers();
  }

  // --- API Functions ---
  Future<void> fetchServers() async {
    try {
      servers = await apiService.fetchAllServers();
    } catch (e) {
      debugPrint("Error: $e");
    }
    setState(() => isLoading = false);
  }

  Future<void> fetchEndpoints(bool isSource) async {
    final serverId = isSource
        ? selectedSourceServer?.serverId
        : selectedDestinationServer?.serverId;
    if (serverId == null) return;
    try {
      final endpoints = await apiService.getEndpointsForServer(serverId);
      setState(() {
        if (isSource) {
          sourceEndpoints = endpoints;
          selectedSourceEndpoint = null;
          sourceFieldsGrouped = {};
        } else {
          destinationEndpoints = endpoints;
          selectedDestinationEndpoint = null;
          destinationFieldsGrouped = {};
        }
      });
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> fetchEndpointFields(bool isSource) async {
    final endpointId = isSource
        ? selectedSourceEndpoint?.endpointId
        : selectedDestinationEndpoint?.endpointId;
    if (endpointId == null) return;
    try {
      final raw = await apiService.fetchEndpointFields(endpointId);
      final fields = raw
          .map<EndpointField>(
            (e) => EndpointField.fromJson(e as Map<String, dynamic>),
          )
          .toList();
      final Map<String, List<EndpointField>> grouped = {};
      for (var field in fields) {
        grouped.putIfAbsent(field.resource, () => []).add(field);
      }
      setState(() {
        if (isSource) {
          sourceFieldsGrouped = grouped;
          selectedSourceFieldIds.clear();
        } else {
          destinationFieldsGrouped = grouped;
          selectedDestinationFieldIds.clear();
        }
      });
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  List<EndpointField> get _allSourceFields =>
      sourceFieldsGrouped.values.expand((list) => list).toList();
  List<EndpointField> get _allDestinationFields =>
      destinationFieldsGrouped.values.expand((list) => list).toList();

  // --- Mapping & Database Submit Logic ---
  Future<void> addMapping() async {
    if (selectedSourceFieldIds.isEmpty || selectedDestinationFieldIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select source and destination fields"),
        ),
      );
      return;
    }

    final srcNames = _allSourceFields
        .where((f) => selectedSourceFieldIds.contains(f.endpointFieldId))
        .map((f) => f.name)
        .join(" + ");
    final destNames = _allDestinationFields
        .where((f) => selectedDestinationFieldIds.contains(f.endpointFieldId))
        .map((f) => f.name)
        .join(" + ");

    String transformType = "copy";
    Map<String, dynamic> config = {};

    try {
      // Suggestion API call
      final suggestion = await apiService.getMappingSuggestion(
        srcServerId: selectedSourceServer!.serverId,
        destServerId: selectedDestinationServer!.serverId,
        srcFieldIds: selectedSourceFieldIds.toList(),
        destFieldIds: selectedDestinationFieldIds.toList(),
      );
      transformType = suggestion['transform_type'] ?? "copy";
      config = suggestion['config'] ?? {};
    } catch (e) {
      debugPrint("Suggestion API error, using default 'copy': $e");
      // Falls back to copy — mapping still gets added
    }

    setState(() {
      finalMappings.add({
        "display": "$srcNames → $destNames",
        "src_paths": selectedSourceFieldIds.toList(),
        "dest_paths": selectedDestinationFieldIds.toList(),
        "transform": transformType,
        "config": config,
      });
      selectedSourceFieldIds.clear();
      selectedDestinationFieldIds.clear();
    });
  }

  Future<void> submitChannel() async {
    if (channelNameController.text.isEmpty ||
        finalMappings.isEmpty ||
        selectedMessageType == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fill all details")));
      return;
    }

    setState(() => isSubmitting = true);

    // Logic matching route.py schema
    final payload = {
      "name": channelNameController.text,
      "src_server_id": selectedSourceServer!.serverId,
      "src_endpoint_id": selectedSourceEndpoint!.endpointId,
      "dest_server_id": selectedDestinationServer!.serverId,
      "dest_endpoint_id": selectedDestinationEndpoint!.endpointId,
      "msg_type": selectedMessageType,
      "rules": {
        "mappings": finalMappings
            .map(
              (m) => {
                "src_paths": m['src_paths'],
                "dest_paths": m['dest_paths'],
                "transform": m['transform'],
                "config": m['config'],
              },
            )
            .toList(),
      },
    };

    try {
      await apiService.addChannel(payload);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF1A365D)),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Add Channels",
                      
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A365D),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _label("Channel Name"),
                    _inputField(
                      TextField(
                        controller: channelNameController,
                        decoration: const InputDecoration(
                          hintText: "Enter Channel Name",
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    _label("Source Server"),
                    _dropdown(
                      DropdownButton<Server>(
                        isExpanded: true,
                        value: selectedSourceServer,
                        hint: const Text("Select Source server"),
                        items: servers
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(s.name),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() => selectedSourceServer = val);
                          fetchEndpoints(true);
                        },
                      ),
                    ),

                    _label("Source endpoint"),
                    _dropdown(
                      DropdownButton<Endpoint>(
                        isExpanded: true,
                        value: selectedSourceEndpoint,
                        hint: const Text("Select Source endpoint"),
                        items: sourceEndpoints
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.url),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() => selectedSourceEndpoint = val);
                          fetchEndpointFields(true);
                        },
                      ),
                    ),

                    _label("Destination server"),
                    _dropdown(
                      DropdownButton<Server>(
                        isExpanded: true,
                        value: selectedDestinationServer,
                        hint: const Text("Select Destination Server"),
                        items: servers
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(s.name),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() => selectedDestinationServer = val);
                          fetchEndpoints(false);
                        },
                      ),
                    ),

                    _label("Destination endpoint"),
                    _dropdown(
                      DropdownButton<Endpoint>(
                        isExpanded: true,
                        value: selectedDestinationEndpoint,
                        hint: const Text("Select Destination endpoint"),
                        items: destinationEndpoints
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.url),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() => selectedDestinationEndpoint = val);
                          fetchEndpointFields(false);
                        },
                      ),
                    ),

                    const SizedBox(height: 28),

                    // --- Mapping Table ---
                    Container(
                      height: 350,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              "Mapping",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A365D),
                              ),
                            ),
                          ),
                          Container(
                            color: const Color(0xFFF5F5F5),
                            child: const Row(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Text(
                                        "Source",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Text(
                                        "Destination",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildChecklist(
                                    sourceFieldsGrouped,
                                    selectedSourceFieldIds,
                                  ),
                                ),
                                const VerticalDivider(width: 1),
                                Expanded(
                                  child: _buildChecklist(
                                    destinationFieldsGrouped,
                                    selectedDestinationFieldIds,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async => await addMapping(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A365D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Add Mapping",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                    ...finalMappings.map(
                      (m) => ListTile(
                        title: Text(
                          m['display'],
                          style: const TextStyle(fontSize: 13),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                          onPressed: () =>
                              setState(() => finalMappings.remove(m)),
                        ),
                      ),
                    ),

                    _label("Message Type"),
                    _dropdown(
                      DropdownButton<String>(
                        isExpanded: true,
                        value: selectedMessageType,
                        hint: const Text("Select Message Type"),
                        items: messageTypes
                            .map(
                              (m) => DropdownMenuItem(value: m, child: Text(m)),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => selectedMessageType = val),
                      ),
                    ),

                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : submitChannel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A365D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isSubmitting
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Add Channels",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6),
    child: Text(
      t,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A2E),
      ),
    ),
  );
  Widget _inputField(Widget c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFE0E0E0)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: c,
  );
  Widget _dropdown(Widget c) =>
      _inputField(DropdownButtonHideUnderline(child: c));

  Widget _buildChecklist(
    Map<String, List<EndpointField>> grouped,
    Set<int> selectionSet,
  ) {
    if (grouped.isEmpty)
      return const Center(
        child: Text(
          "No fields",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      );
    return ListView(
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFFEEF2F7),
              padding: const EdgeInsets.all(6),
              child: Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A365D),
                ),
              ),
            ),
            ...entry.value.map((f) {
              final bool isChecked = selectionSet.contains(f.endpointFieldId);
              return CheckboxListTile(
                title: Text(
                  f.name,
                  style: TextStyle(
                    fontSize: 12,
                    decoration: isChecked
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                value: isChecked,
                dense: true,
                onChanged: (val) => setState(
                  () => val!
                      ? selectionSet.add(f.endpointFieldId)
                      : selectionSet.remove(f.endpointFieldId),
                ),
              );
            }),
          ],
        );
      }).toList(),
    );
  }
}
