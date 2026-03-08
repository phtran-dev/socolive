import 'package:flutter/foundation.dart';
import '../models/match.dart';
import '../models/stream.dart';
import '../services/api_service.dart';

class MatchController extends ChangeNotifier {
  final ApiService _api;

  List<Match> _matches = [];
  bool _isLoading = false;
  String? _error;
  DateTime _selectedDate = DateTime.now();

  // Cache for room details
  final Map<String, RoomDetail> _roomCache = {};

  MatchController({ApiService? api}) : _api = api ?? ApiService();

  List<Match> get matches => _matches;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;

  Future<void> loadMatches([DateTime? date]) async {
    _isLoading = true;
    _error = null;
    _selectedDate = date ?? DateTime.now();
    notifyListeners();

    try {
      _matches = await _api.getMatches(_selectedDate);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _matches = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<RoomDetail?> getRoomDetail(String roomId) async {
    // Check cache first
    if (_roomCache.containsKey(roomId)) {
      return _roomCache[roomId];
    }

    try {
      final detail = await _api.getRoomDetail(roomId);
      _roomCache[roomId] = detail;
      return detail;
    } catch (e) {
      debugPrint('Error loading room $roomId: $e');
      return null;
    }
  }

  void previousDay() {
    loadMatches(_selectedDate.subtract(const Duration(days: 1)));
  }

  void nextDay() {
    loadMatches(_selectedDate.add(const Duration(days: 1)));
  }

  void today() {
    loadMatches(DateTime.now());
  }
}
