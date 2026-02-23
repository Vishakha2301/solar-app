import 'component_cost.dart';

/// The fully-calculated output of [calculateQuotation].
///
/// All monetary values are in Indian Rupees (₹).
/// All fields are immutable doubles for type consistency.
class CostingResult {
  final Map<String, ComponentCost> components;

  final double systemSubTotal;

  // ── Additional cost line-items ─────────────────────────────────────────────
  final double contingency;
  final double cp1;
  final double cp2;
  final double amc;
  final double subsidyProcessingFee;

  // ── Project totals ─────────────────────────────────────────────────────────
  /// Grand total before GST = systemSubTotal + all additional costs.
  final double grandTotal;

  /// Grand total after applying the blended effective GST rate.
  final double projectCostAfterGst;

  /// Cost per Watt-peak before GST.
  final double perWpBeforeGst;

  /// Cost per Watt-peak after GST.
  final double perWpAfterGst;

  const CostingResult({
    required this.components,
    required this.systemSubTotal,
    required this.contingency,
    required this.cp1,
    required this.cp2,
    required this.amc,
    required this.subsidyProcessingFee,
    required this.grandTotal,
    required this.projectCostAfterGst,
    required this.perWpBeforeGst,
    required this.perWpAfterGst,
  });

  /// Returns an empty (zero-value) result used as the initial UI state
  /// before any calculation has been performed.
  factory CostingResult.empty() {
    return const CostingResult(
      components: {},
      systemSubTotal: 0,
      contingency: 0,
      cp1: 0,
      cp2: 0,
      amc: 0,
      subsidyProcessingFee: 0,
      grandTotal: 0,
      projectCostAfterGst: 0,
      perWpBeforeGst: 0,
      perWpAfterGst: 0,
    );
  }

  bool get isCalculated => grandTotal > 0;
}
