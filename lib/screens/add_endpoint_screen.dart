import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../models/server_model.dart';

class AddEndpointScreen extends StatefulWidget {
  const AddEndpointScreen({Key? key}) : super(key: key);

  @override
  State<AddEndpointScreen> createState() => _AddEndpointScreenState();
}

class _AddEndpointScreenState extends State<AddEndpointScreen> {
  final ApiService _apiService = ApiService();

  List<Server> servers = [];
  Server? selectedServer;

  final TextEditingController urlController = TextEditingController();
  final TextEditingController sampleMsgController = TextEditingController();

  bool isLoadingServers = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fetchServers();
  }

  Future<void> fetchServers() async {
    try {
      final serverList = await _apiService.fetchAllServers();
      setState(() {
        servers = serverList;
        isLoadingServers = false;
      });
    } catch (e) {
      setState(() {
        isLoadingServers = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading servers: $e')));
    }
  }

  Future<void> addEndpoint() async {
    if (selectedServer == null ||
        urlController.text.isEmpty ||
        sampleMsgController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      dynamic sampleMsg;

      // ✅ Parse sample_msg based on protocol
      if (selectedServer!.protocol == "FHIR") {
        try {
          // Parse FHIR string to JSON object
          sampleMsg = json.decode(sampleMsgController.text);
          print('✅ FHIR message parsed successfully');
        } catch (e) {
          print('❌ JSON parse error: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Invalid FHIR JSON: $e"),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() => isSubmitting = false);
          return;
        }
      } else {
        // HL7: Keep as string with proper newlines
        // ✅ Replace escaped newlines with actual newlines
        sampleMsg = sampleMsgController.text
            .replaceAll('\\n', '\n')
            .replaceAll('\\\\n', '\n')
            .trim();

        print('✅ HL7 message ready (string format)');
        print('📍 HL7 message content:');
        print('---START---');
        print(sampleMsg);
        print('---END---');
        print('📍 Message lines: ${sampleMsg.split('\n').length}');
      }

      final endpointData = {
        "server_id": selectedServer!.serverId,
        "url": urlController.text.trim(),
        "server_protocol": selectedServer!.protocol,
        "sample_msg": sampleMsg, // ✅ JSON object for FHIR, string for HL7
      };

      print('📍 Sending endpoint data:');
      print('   server_id: ${endpointData["server_id"]}');
      print('   url: ${endpointData["url"]}');
      print('   server_protocol: ${endpointData["server_protocol"]}');
      print('   sample_msg type: ${sampleMsg.runtimeType}');

      final success = await Future.delayed(
        const Duration(milliseconds: 100),
        () => _apiService.addEndpoint(endpointData),
      );
      print('✅ API Response: $success');

      if (success && mounted) {
        print('✅ Endpoint API returned success');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Endpoint added successfully'),
            backgroundColor: Colors.green,
          ),
        );

        urlController.clear();
        sampleMsgController.clear();

        // ✅ Reset isSubmitting immediately
        if (mounted) {
          setState(() {
            isSubmitting = false;
          });
        }

        // ✅ WAIT BEFORE NAVIGATING - Backend is still processing fields!
        // Backend mein add_fhir_endpoint_fields() ya add_hl7_endpoint_fields()
        // chal raha hai jo field extraction kar raha hai
        print('⏳ Waiting 1.5 seconds before navigation...');
        await Future.delayed(const Duration(milliseconds: 1500));

        // ✅ Check mounted again before popping
        if (mounted && Navigator.canPop(context)) {
          print('✅ Navigation popping back...');
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print('❌ Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Add Endpoint",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: isLoadingServers
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// SERVER DROPDOWN
                    const Text(
                      "Server",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildServerDropdown(),

                    const SizedBox(height: 20),

                    /// URL
                    const Text(
                      "Endpoint URL",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInputField(urlController, "Enter endpoint URL"),

                    const SizedBox(height: 20),

                    /// SAMPLE MESSAGE INPUT
                    const Text(
                      "Sample Message",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: sampleMsgController,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: selectedServer?.protocol == "HL7"
                            ? "Paste HL7 message:\nMSH|^~\\&|EHR|LIS|...\nPID||23|Smith^John|..."
                            : "Paste FHIR JSON message...",
                        filled: true,
                        fillColor: const Color(0xffF1F3F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : addEndpoint,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff2F4F88),
                        ),
                        child: isSubmitting
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                            : const Text(
                                "Add Endpoint",
                                style: TextStyle(
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

  Widget _buildInputField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildServerDropdown() {
    return DropdownButtonFormField<Server>(
      value: selectedServer,
      hint: const Text("Select Server"),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: servers.map((server) {
        return DropdownMenuItem<Server>(
          value: server,
          child: Text("${server.name} (${server.protocol})"),
        );
      }).toList(),
      onChanged: (Server? value) {
        setState(() {
          selectedServer = value;
        });
      },
    );
  }

  @override
  void dispose() {
    urlController.dispose();
    sampleMsgController.dispose();
    super.dispose();
  }
}
