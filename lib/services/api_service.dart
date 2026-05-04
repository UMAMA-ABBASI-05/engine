import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/server_model.dart';
import '../models/endpoint_model.dart';
import '../models/channel_model.dart';
import '../models/endpoint_field_model.dart';
import '../core/constants.dart';

class ApiService {
  final String baseUrl = AppConstants.baseUrl;

  // ==================== SERVERS ====================

  Future<List<Server>> fetchAllServers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/server/all-servers'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Server.fromJson(item)).toList();
      } else {
        throw Exception('Servers load nahi ho sakay: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  Future<Server> fetchSpecificServer(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/server/specific-server/$id'),
      );
      if (response.statusCode == 200) {
        return Server.fromJson(json.decode(response.body));
      } else {
        throw Exception('Server ID $id nahi mil saka');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<bool> addServer(Map<String, dynamic> serverData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/server/add-server'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(serverData),
      );
      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<bool> deleteServer(int serverId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/server/delete-server/$serverId'),
    );
    return res.statusCode == 200;
  }

  Future<bool> updateServer(
    int serverId, {
    required String name,
    required String ip,
    required int port,
    required String protocol,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/server/update-server/$serverId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'ip': ip,
        'port': port,
        'protocol': protocol,
      }),
    );
    return res.statusCode == 200;
  }

  // ==================== ENDPOINTS ====================

  Future<List<Endpoint>> getEndpointsForServer(int serverId) async {
    try {
      final raw = await fetchServerEndpoints(serverId);
      return raw
          .map<Endpoint>((e) => Endpoint.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error converting endpoints: $e');
    }
  }

  Future<List<Endpoint>> fetchServerEndpointsTyped(int serverId) async {
    return getEndpointsForServer(serverId);
  }

  Future<List<dynamic>> fetchServerEndpoints(int serverId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/endpoint/server-endpoint/$serverId'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        throw Exception('Endpoints load nahi ho sakay');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<EndpointField>> fetchEndpointFieldsTyped(int endpointId) async {
    final raw = await fetchEndpointFields(endpointId);
    return raw
        .map<EndpointField>(
          (e) => EndpointField.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<dynamic>> fetchEndpointFields(int endpointId) async {
    try {
      // Ye endpoint route.py mein hai, endpoint.py mein nahi
      final response = await http.get(
        Uri.parse('$baseUrl/endpoint/endpoint_field_path/$endpointId'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Fields fetch karne mein masla hai');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<bool> addEndpoint(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/endpoint/add-endpoint'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );
      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Endpoint> fetchEndpointByIdTyped(int endpointId) async {
    final raw = await fetchEndpointById(endpointId);
    return Endpoint.fromJson(raw);
  }

  Future<dynamic> fetchEndpointById(int endpointId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/endpoint/$endpointId'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Endpoint not found');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ==================== ROUTES / CHANNELS ====================

  Future<List<dynamic>> fetchAllRoutes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/route/all-routes'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Routes load nahi ho sakay');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<bool> deleteRoute(int routeId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/route/delete-route/$routeId'),
    );
    return res.statusCode == 204;
  }

  Future<List<dynamic>> fetchMappingRules(int routeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/route/mapping_rules/$routeId'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Mapping rules nahi milien');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<EndpointField>> fetchEndpointFieldPathTyped(
    int endpointId,
  ) async {
    final raw = await fetchEndpointFieldPath(endpointId);
    return raw
        .map<EndpointField>(
          (e) => EndpointField.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<dynamic>> fetchEndpointFieldPath(int endpointId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/endpoint/endpoint_field_path/$endpointId'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Endpoint field path nahi mila');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> addRoute(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/route/add-route'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );
      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Route add nahi ho saka');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> getMappingSuggestion({
    required int srcServerId,
    required int destServerId,
    required List<int> srcFieldIds,
    required List<int> destFieldIds,
  }) async {
    // Build query string manually for FastAPI list params
    final srcParams = srcFieldIds.map((id) => 'src_field_ids=$id').join('&');
    final destParams = destFieldIds.map((id) => 'dest_field_ids=$id').join('&');
    final queryString = '$srcParams&$destParams';

    // Use same base URL pattern as your other API calls
    final url =
        '$baseUrl/route/mapping_suggestion'
        '/src_server_id/$srcServerId'
        '/dest_server_id/$destServerId'
        '?$queryString';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Suggestion failed: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<bool> addChannel(Map<String, dynamic> data) async {
    try {
      final response = await addRoute(data);
      return response['message'] != null || response.isNotEmpty;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<dynamic> fetchRouteById(int routeId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/route/$routeId'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Route not found');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ==================== LOGS ====================

  Future<List<dynamic>> fetchAllLogs() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/logs'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Logs load nahi ho sakay');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<dynamic>> fetchErrorLogs() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/logs/errors'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error logs load nahi ho sakay');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<dynamic>> fetchServerLogs(int serverId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/logs/server/$serverId'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Server logs load nahi ho sakay');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<dynamic>> fetchLogsByDate(String date) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/logs/date/$date'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Date logs load nahi ho sakay');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ==================== MESSAGES ====================

  Future<Map<String, dynamic>> getMessage({
    int? serverId,
    int? endpointId,
  }) async {
    try {
      String url = '$baseUrl/messages';
      if (serverId != null) url += '?server_id=$serverId';
      if (endpointId != null) {
        url += (serverId != null ? '&' : '?') + 'endpoint_id=$endpointId';
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Message load nahi ho saka');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<dynamic>> getMessageHistory({
    int? serverId,
    int? channelId,
    int limit = 50,
  }) async {
    try {
      String url = '$baseUrl/messages/history?limit=$limit';
      if (serverId != null) url += '&server_id=$serverId';
      if (channelId != null) url += '&channel_id=$channelId';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Message history load nahi ho saka');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
