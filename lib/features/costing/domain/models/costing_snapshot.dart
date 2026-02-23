import 'component_cost.dart';
import 'component_input_snapshot.dart';

/// A point-in-time snapshot of a completed costing calculation.
///
/// Stored as part of [SavedCosting]. Contains both the calculated outputs
/// (for display) and the original user inputs (for restore/edit).
///
/// All fields are immutable doubles — no [num] types.
class CostingSnapshot {
  // ── Calculated outputs ────────────────────────────────────────────────────
  final double systemSubTotal;
  final double subsidyProcessingFee;
  final double contingency;
  final double cp1;
  final double cp2;
  final double amc;
  final double grandTotal;
  final double projectCostAfterGst;
  final double perWpAfterGst;

  /// Calculated cost per component, keyed by component key.
  final Map<String, ComponentCost> components;

  // ── User inputs (for restore on edit) ────────────────────────────────────
  /// The form values the user entered, keyed by component key.
  /// Uses [ComponentInputSnapshot] — a pure domain type with no UI dependency.
  final Map<String, ComponentInputSnapshot> componentInputs;

  const CostingSnapshot({
    required this.systemSubTotal,
    required this.subsidyProcessingFee,
    required this.contingency,
    required this.cp1,
    required this.cp2,
    required this.amc,
    required this.grandTotal,
    required this.projectCostAfterGst,
    required this.perWpAfterGst,
    required this.components,
    required this.componentInputs,
  });
}
