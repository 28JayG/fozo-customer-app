import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "https://api.getfozo.in/api/"; // Change this to your API base URL

  // GET Request
  static Future<Map<String, dynamic>> getRequest(String endpoint) async {
    try {
      print("Get URL");

      String encodedUrl = Uri.encodeFull('$baseUrl$endpoint');
      print(encodedUrl);

      final response = await http.get(Uri.parse(encodedUrl), headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      print('GET Request Error: $e');
      return {};
    }
  }

  // POST Request
  static Future<Map<String, dynamic>> postRequest(
      String endpoint, Map<String, dynamic> data) async {
    try {
      print("Post URL");
      String encodedUrl = Uri.encodeFull('$baseUrl$endpoint');
      print(encodedUrl);

      print(encodedUrl);
      final response = await http.post(
        Uri.parse(encodedUrl),
        headers: _headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      print('POST Request Error: $e');
      return {};
    }
  }

  // PUT Request
  static Future<Map<String, dynamic>> putRequest(
      String endpoint, Map<String, dynamic> data) async {
    try {
      String encodedUrl = Uri.encodeFull('$baseUrl$endpoint');

      final response = await http.put(
        Uri.parse(encodedUrl),
        headers: _headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      print('PUT Request Error: $e');
      return {};
    }
  }

  // DELETE Request
  static Future<Map<String, dynamic>> deleteRequest(String endpoint) async {
    try {
      String encodedUrl = Uri.encodeFull('$baseUrl$endpoint');

      final response =
          await http.delete(Uri.parse(encodedUrl), headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      print('DELETE Request Error: $e');
      return {};
    }
  }

  // Common Headers
  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': '*/*',
  };

  // Handle Response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      print('HTTP Error: ${response.statusCode} - ${response.body}');
      return {};
    }
  }
}
