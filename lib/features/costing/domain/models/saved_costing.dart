import 'costing_context.dart';
import 'costing_snapshot.dart';

class SavedCosting {
  final String id;
  final DateTime createdAt;
  final String? createdBy;
  final CostingContext context;
  final CostingSnapshot snapshot;

  const SavedCosting({
    required this.id,
    required this.createdAt,
    this.createdBy,
    required this.context,
    required this.snapshot,
  });

  Map<String, dynamic> toJson() => {
        'context': context.toJson(),
        'snapshot': snapshot.toJson(),
      };

  factory SavedCosting.fromJson(Map<String, dynamic> json) => SavedCosting(
        id: json['id'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        createdBy: json['createdBy'] as String?,
        context: CostingContext.fromJson(
            json['context'] as Map<String, dynamic>),
        snapshot: CostingSnapshot.fromJson(
            json['snapshot'] as Map<String, dynamic>),
      );
}