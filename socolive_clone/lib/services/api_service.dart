import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/match.dart';
import '../models/stream.dart';

class ApiService {
  static const String baseUrl = 'https://json.vnres.co';

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Strip JSONP callback wrapper
  Map<String, dynamic> _parseJsonp(String response) {
    // Handle: callback_name({...})
    final match = RegExp(r'^\w+\((.*)\)$', dotAll: true).firstMatch(response);
    final jsonStr = match != null ? match.group(1)! : response;
    return json.decode(jsonStr);
  }

  /// Get matches for a specific date
  Future<List<Match>> getMatches(DateTime date) async {
    final dateStr = '${date.year}${_pad(date.month)}${_pad(date.day)}';
    final url = Uri.parse('$baseUrl/match/matches_$dateStr.json');

    try {
      final response = await _client.get(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to load matches: ${response.statusCode}');
      }

      final data = _parseJsonp(response.body);

      if (data['code'] != 200) {
        throw Exception('API error: ${data['msg']}');
      }

      final List<dynamic> matchesJson = data['data'] ?? [];
      return matchesJson.map((json) => Match.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get stream details for a room
  Future<RoomDetail> getRoomDetail(String roomId) async {
    final url = Uri.parse('$baseUrl/room/$roomId/detail.json');

    try {
      final response = await _client.get(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to load room: ${response.statusCode}');
      }

      final data = _parseJsonp(response.body);

      if (data['code'] != 200) {
        throw Exception('API error: ${data['msg']}');
      }

      return RoomDetail.fromJson(data['data']);
    } catch (e) {
      rethrow;
    }
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  void dispose() {
    _client.close();
  }
}
