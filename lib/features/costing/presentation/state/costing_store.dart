import 'package:flutter/foundation.dart';
import '../../data/costing_repository.dart';
import '../../domain/models/saved_costing.dart';

enum CostingStatus { initial, loading, loaded, error }

class CostingStore extends ChangeNotifier {
  final CostingRepository _repository;

  CostingStore({CostingRepository? repository})
      : _repository = repository ?? CostingRepository();

  List<SavedCosting> _costings = [];
  CostingStatus _status = CostingStatus.initial;
  String? _errorMessage;

  List<SavedCosting> get costings => List.unmodifiable(_costings);
  CostingStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == CostingStatus.loading;

  Future<void> loadAll() async {
    _status = CostingStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _costings = await _repository.getAll();
      _status = CostingStatus.loaded;
    } on UnauthorizedException {
      _status = CostingStatus.error;
      _errorMessage = 'Session expired. Please login again.';
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _status = CostingStatus.error;
    }
    notifyListeners();
  }

  Future<void> addCosting(SavedCosting costing) async {
    try {
      final saved = await _repository.create(costing);
      _costings.insert(0, saved);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateCosting(String id, SavedCosting updated) async {
    try {
      final saved = await _repository.update(id, updated);
      final index = _costings.indexWhere((c) => c.id == id);
      if (index != -1) {
        _costings[index] = saved;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteCosting(String id) async {
    try {
      await _repository.delete(id);
      _costings.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  void clear() {
    _costings = [];
    _status = CostingStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }
}