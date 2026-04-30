import '../models/cross_result.dart';

class HistoryService {
  static final List<CrossResult> _history = [];
  
  static List<CrossResult> get history => List.unmodifiable(_history);
  
  static void add(CrossResult result) {
    _history.insert(0, result); // Новые — в начало
    if (_history.length > 20) {
      _history.removeLast(); // Храним только последние 20
    }
  }
  
  static void clear() => _history.clear();
}