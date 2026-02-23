import 'costing_context.dart';
import 'costing_snapshot.dart';

class SavedCosting {
  final String id;
  final DateTime createdAt;

  final CostingContext context;
  final CostingSnapshot snapshot;

  const SavedCosting({
    required this.id,
    required this.createdAt,
    required this.context,
    required this.snapshot,
  });
}
