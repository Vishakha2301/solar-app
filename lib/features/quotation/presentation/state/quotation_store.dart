import 'package:flutter/foundation.dart';
import '../../data/quotation_repository.dart';
import '../../domain/models/quotation.dart';

enum QuotationStoreStatus { initial, loading, loaded, error }

class QuotationStore extends ChangeNotifier {
  final QuotationRepository _repository;

  QuotationStore({QuotationRepository? repository})
      : _repository = repository ?? QuotationRepository();

  List<Quotation> _quotations = [];
  QuotationStoreStatus _status = QuotationStoreStatus.initial;
  String? _errorMessage;
  QuotationStatus? _selectedStatus;

  List<Quotation> get quotations => List.unmodifiable(_quotations);
  QuotationStoreStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == QuotationStoreStatus.loading;
  QuotationStatus? get selectedStatus => _selectedStatus;

  Future<void> loadAll() async {
    _status = QuotationStoreStatus.loading;
    _errorMessage = null;
    _selectedStatus = null;
    notifyListeners();

    try {
      _quotations = await _repository.getAll();
      _status = QuotationStoreStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _status = QuotationStoreStatus.error;
    }
    notifyListeners();
  }

  Future<void> filterByStatus(QuotationStatus? status) async {
    _selectedStatus = status;
    if (status == null) return loadAll();

    _status = QuotationStoreStatus.loading;
    notifyListeners();

    try {
      _quotations = await _repository.getByStatus(status.name);
      _status = QuotationStoreStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _status = QuotationStoreStatus.error;
    }
    notifyListeners();
  }

  Future<Quotation> create(Map<String, dynamic> request) async {
    final quotation = await _repository.create(request);
    _quotations.insert(0, quotation);
    notifyListeners();
    return quotation;
  }

  Future<Quotation> update(String id, Map<String, dynamic> request) async {
    final updated = await _repository.update(id, request);
    final index = _quotations.indexWhere((q) => q.id == id);
    if (index != -1) {
      _quotations[index] = updated;
      notifyListeners();
    }
    return updated;
  }

  Future<Quotation> submit(String id) async {
    final updated = await _repository.submit(id);
    _updateInList(updated);
    return updated;
  }

  Future<Quotation> approve(String id, String? approvalNotes) async {
    final updated = await _repository.approve(id, approvalNotes);
    _updateInList(updated);
    return updated;
  }

  Future<Quotation> reject(String id, String rejectionReason) async {
    final updated = await _repository.reject(id, rejectionReason);
    _updateInList(updated);
    return updated;
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    _quotations.removeWhere((q) => q.id == id);
    notifyListeners();
  }

  void _updateInList(Quotation updated) {
    final index = _quotations.indexWhere((q) => q.id == updated.id);
    if (index != -1) {
      _quotations[index] = updated;
      notifyListeners();
    }
  }

  void clear() {
    _quotations = [];
    _status = QuotationStoreStatus.initial;
    _errorMessage = null;
    _selectedStatus = null;
    notifyListeners();
  }
}