import 'package:flutter/foundation.dart';
import '../../data/customer_repository.dart';
import '../../domain/models/customer.dart';

enum CustomerStatus { initial, loading, loaded, error }

class CustomerStore extends ChangeNotifier {
  final CustomerRepository _repository;

  CustomerStore({CustomerRepository? repository})
      : _repository = repository ?? CustomerRepository();

  List<Customer> _customers = [];
  CustomerStatus _status = CustomerStatus.initial;
  String? _errorMessage;

  List<Customer> get customers => List.unmodifiable(_customers);
  CustomerStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == CustomerStatus.loading;

  Future<void> loadAll() async {
    _status = CustomerStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _customers = await _repository.getAll();
      _status = CustomerStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _status = CustomerStatus.error;
    }
    notifyListeners();
  }

  Future<void> search(String name) async {
    if (name.trim().isEmpty) {
      return loadAll();
    }
    _status = CustomerStatus.loading;
    notifyListeners();

    try {
      _customers = await _repository.search(name);
      _status = CustomerStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _status = CustomerStatus.error;
    }
    notifyListeners();
  }

  Future<Customer> create(Map<String, dynamic> request) async {
    final customer = await _repository.create(request);
    _customers.insert(0, customer);
    notifyListeners();
    return customer;
  }

  Future<Customer> update(String id, Map<String, dynamic> request) async {
    final updated = await _repository.update(id, request);
    final index = _customers.indexWhere((c) => c.id == id);
    if (index != -1) {
      _customers[index] = updated;
      notifyListeners();
    }
    return updated;
  }

  Future<void> deactivate(String id) async {
    await _repository.deactivate(id);
    _customers.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  void clear() {
    _customers = [];
    _status = CustomerStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }
}