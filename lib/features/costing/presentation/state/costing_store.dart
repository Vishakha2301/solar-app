import 'package:flutter/foundation.dart';
import '../../domain/models/saved_costing.dart';

class CostingStore extends ChangeNotifier {
  final List<SavedCosting> _costings = [];

  List<SavedCosting> get costings =>
      List.unmodifiable(_costings);

  void addCosting(SavedCosting costing) {
    _costings.add(costing);
    notifyListeners();
  }

  void updateCosting(String id, SavedCosting updated) {
    final index =
        _costings.indexWhere((c) => c.id == id);

    if (index != -1) {
      _costings[index] = updated;
      notifyListeners();
    }
  }

  void deleteCosting(String id) {
    _costings.removeWhere((c) => c.id == id);
    notifyListeners();
  }


  void clear() {
    _costings.clear();
    notifyListeners();
  }
}
