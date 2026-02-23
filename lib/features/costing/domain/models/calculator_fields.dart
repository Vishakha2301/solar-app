import 'component_type.dart';

/// A single line-item component in a solar system quotation.
///
/// All fields are immutable. Use [copyWith] to derive modified instances.
class SolarComponent {
  final ComponentType type;

  /// How many units (panels, metres of cable, etc.)
  final double quantity;

  /// Price per unit (₹/Wp, ₹/Nos, ₹/Mtr, …)
  final double unitPrice;

  /// GST rate as a percentage string, e.g. '5' or '18'.
  final String gstRate;

  /// Display unit label shown in the UI (Wp, Nos, Mtr, …)
  final String unit;

  /// Watt-peak rating of a single solar panel.
  /// Only meaningful when [type] == [ComponentType.panelCapacityBased].
  final double panelCapacityWp;

  /// Human-readable cable specification shown in the UI, e.g. '04 Sq 02C Cu'.
  /// Only meaningful for cable components.
  final String? specification;

  const SolarComponent({
    required this.type,
    required this.quantity,
    required this.unitPrice,
    required this.gstRate,
    required this.unit,
    this.panelCapacityWp = 0,
    this.specification,
  });

  SolarComponent copyWith({
    ComponentType? type,
    double? quantity,
    double? unitPrice,
    String? gstRate,
    String? unit,
    double? panelCapacityWp,
    String? specification,
  }) {
    return SolarComponent(
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      gstRate: gstRate ?? this.gstRate,
      unit: unit ?? this.unit,
      panelCapacityWp: panelCapacityWp ?? this.panelCapacityWp,
      specification: specification ?? this.specification,
    );
  }
}

/// An additional cost expressed as a percentage of the system sub-total.
class PercentageCost {
  final double percentage;

  const PercentageCost({required this.percentage});

  PercentageCost copyWith({double? percentage}) =>
      PercentageCost(percentage: percentage ?? this.percentage);
}

/// An additional cost expressed as a fixed rupee amount.
class FixedCost {
  final double amount;

  const FixedCost({required this.amount});

  FixedCost copyWith({double? amount}) =>
      FixedCost(amount: amount ?? this.amount);
}
