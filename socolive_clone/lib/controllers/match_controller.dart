import 'package:flutter/foundation.dart';
import '../models/match.dart';
import '../models/stream.dart';
import '../services/api_service.dart';

class MatchController extends ChangeNotifier {
  final ApiService _api;

  List<Match> _allMatches = [];
  bool _isLoading = false;
  String? _error;
  DateTime _selectedDate = DateTime.now();

  // Filtering
  int _selectedCategoryId = 0; // 0 = All
  MatchFilter _selectedFilter = MatchFilter.all;

  // Cache for room details
  final Map<String, RoomDetail> _roomCache = {};

  MatchController({ApiService? api}) : _api = api ?? ApiService();

  List<Match> get allMatches => _allMatches;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;
  int get selectedCategoryId => _selectedCategoryId;
  MatchFilter get selectedFilter => _selectedFilter;

  // Get filtered matches
  List<Match> get matches {
    List<Match> filtered = _allMatches;

    // Filter by category (if not "All")
    if (_selectedCategoryId > 0) {
      filtered = filtered.where((m) => m.categoryId == _selectedCategoryId).toList();
    }

    // Filter by match status
    switch (_selectedFilter) {
      case MatchFilter.all:
        // No additional filtering
        break;
      case MatchFilter.live:
        filtered = filtered.where((m) => m.isLive).toList();
        break;
      case MatchFilter.hot:
        filtered = filtered.where((m) => m.isHot).toList();
        break;
      case MatchFilter.today:
        final today = DateTime.now();
        filtered = filtered.where((m) {
          final matchDate = DateTime.fromMillisecondsSinceEpoch(m.matchTime);
          return matchDate.year == today.year &&
              matchDate.month == today.month &&
              matchDate.day == today.day;
        }).toList();
        break;
      case MatchFilter.tomorrow:
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        filtered = filtered.where((m) {
          final matchDate = DateTime.fromMillisecondsSinceEpoch(m.matchTime);
          return matchDate.year == tomorrow.year &&
              matchDate.month == tomorrow.month &&
              matchDate.day == tomorrow.day;
        }).toList();
        break;
    }

    return filtered;
  }

  // Get unique categories from matches
  List<SportCategory> get availableCategories {
    final categoryIds = _allMatches.map((m) => m.categoryId).toSet();
    return SportCategory.defaultCategories.where((c) =>
      c.id == 0 || categoryIds.contains(c.id)
    ).toList();
  }

  void setCategory(int categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setFilter(MatchFilter filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  Future<void> loadMatches([DateTime? date]) async {
    _isLoading = true;
    _error = null;
    _selectedDate = date ?? DateTime.now();
    notifyListeners();

    try {
      debugPrint('Loading matches for ${_selectedDate.toIso8601String()}');
      _allMatches = await _api.getMatches(_selectedDate);
      debugPrint('Loaded ${_allMatches.length} matches');
      _error = null;
    } catch (e, stackTrace) {
      debugPrint('Error loading matches: $e');
      debugPrint('Stack trace: $stackTrace');
      _error = e.toString();
      _allMatches = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<RoomDetail?> getRoomDetail(String roomId) async {
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
