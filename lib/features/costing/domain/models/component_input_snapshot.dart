import 'component_type.dart';

class ComponentInputSnapshot {
  final ComponentType type;
  final double quantity;
  final double unitPrice;
  final String unit;
  final double panelCapacityWp;
  final String? specification;

  const ComponentInputSnapshot({
    required this.type,
    required this.quantity,
    required this.unitPrice,
    required this.unit,
    this.panelCapacityWp = 0,
    this.specification,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'unit': unit,
        'panelCapacityWp': panelCapacityWp,
        if (specification != null) 'specification': specification,
      };

  factory ComponentInputSnapshot.fromJson(Map<String, dynamic> json) =>
      ComponentInputSnapshot(
        type: ComponentType.values.byName(json['type'] as String),
        quantity: (json['quantity'] as num).toDouble(),
        unitPrice: (json['unitPrice'] as num).toDouble(),
        unit: json['unit'] as String? ?? '',
        panelCapacityWp: (json['panelCapacityWp'] as num?)?.toDouble() ?? 0,
        specification: json['specification'] as String?,
      );
}