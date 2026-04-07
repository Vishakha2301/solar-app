import 'package:flutter/foundation.dart';
import '../../data/material_repository.dart';
import '../../domain/models/material_item.dart';

enum MaterialStatus { initial, loading, loaded, error }

class MaterialStore extends ChangeNotifier {
  final MaterialRepository _repository;

  MaterialStore({MaterialRepository? repository})
      : _repository = repository ?? MaterialRepository();

  List<MaterialItem> _materials = [];
  List<MaterialCategoryInfo> _categories = [];
  MaterialStatus _status = MaterialStatus.initial;
  String? _errorMessage;
  String? _selectedCategory;

  List<MaterialItem> get materials => List.unmodifiable(_materials);
  List<MaterialCategoryInfo> get categories => List.unmodifiable(_categories);
  MaterialStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == MaterialStatus.loading;
  String? get selectedCategory => _selectedCategory;

  Future<void> loadAll() async {
    _status = MaterialStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _materials = await _repository.getAll();
      if (_categories.isEmpty) {
        _categories = await _repository.getCategories();
      }
      _status = MaterialStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _status = MaterialStatus.error;
    }
    notifyListeners();
  }

  Future<void> filterByCategory(String? category) async {
    _selectedCategory = category;
    if (category == null) {
      return loadAll();
    }

    _status = MaterialStatus.loading;
    notifyListeners();

    try {
      _materials = await _repository.getByCategory(category);
      _status = MaterialStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _status = MaterialStatus.error;
    }
    notifyListeners();
  }

  Future<void> search(String brandName) async {
    if (brandName.trim().isEmpty) {
      return loadAll();
    }

    _status = MaterialStatus.loading;
    notifyListeners();

    try {
      _materials = await _repository.search(brandName);
      _status = MaterialStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _status = MaterialStatus.error;
    }
    notifyListeners();
  }

  Future<MaterialItem> create(Map<String, dynamic> request) async {
    final material = await _repository.create(request);
    _materials.insert(0, material);
    notifyListeners();
    return material;
  }

  Future<MaterialItem> update(String id, Map<String, dynamic> request) async {
    final updated = await _repository.update(id, request);
    final index = _materials.indexWhere((m) => m.id == id);
    if (index != -1) {
      _materials[index] = updated;
      notifyListeners();
    }
    return updated;
  }

  Future<void> deactivate(String id) async {
    await _repository.deactivate(id);
    _materials.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  void clear() {
    _materials = [];
    _categories = [];
    _status = MaterialStatus.initial;
    _errorMessage = null;
    _selectedCategory = null;
    notifyListeners();
  }
}