import 'component_type.dart';

/// A serialisable snapshot of a single component's user-entered values.
///
/// This lives in the domain layer so that [CostingSnapshot] has no dependency
/// on the presentation layer (the old code imported [ComponentFormInput]
/// directly from `presentation/state/`).
///
/// All fields are immutable.
class ComponentInputSnapshot {
  final ComponentType type;
  final double quantity;
  final double unitPrice;
  final String unit;

  /// Watt-peak of a single panel. Only set for [ComponentType.panelCapacityBased].
  final double panelCapacityWp;

  /// Cable size string, e.g. '04 Sq 02C Cu'. Only set for cable components.
  final String? specification;

  const ComponentInputSnapshot({
    required this.type,
    required this.quantity,
    required this.unitPrice,
    required this.unit,
    this.panelCapacityWp = 0,
    this.specification,
  });
}
