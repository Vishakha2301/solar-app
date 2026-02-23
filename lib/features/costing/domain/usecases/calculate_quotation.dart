import '../models/quotation_input.dart';
import '../models/component_cost.dart';
import '../models/component_type.dart';
import '../models/costing_result.dart';
import '../validators/quotation_validator.dart';

// ── Domain constants ──────────────────────────────────────────────────────────

/// Blended effective GST rate across all component types (5% and 18%).
/// Approximately 8.9% when weighted by typical component cost distribution.
const double kEffectiveGstRate = 0.089;

/// Fixed subsidy processing fee in ₹ when [QuotationInput.isSubsidyProject] is true.
const double kSubsidyProcessingFeeAmount = 99.0;

// ── Utility ───────────────────────────────────────────────────────────────────

double _round2(double value) =>
    double.parse(value.toStringAsFixed(2));

double _pct(double base, double percent) => base * percent / 100;

// ── Use case ─────────────────────────────────────────────────────────────────

/// Calculates a full solar project quotation from [input].
///
/// Returns a [CostingResult] with all line-items populated.
/// If required components are incomplete ([isQuotationComplete] returns false),
/// the totals are zeroed but the partial [components] map is still returned
/// so the UI can show which items are missing.
CostingResult calculateQuotation(QuotationInput input) {
  final double plantCapacity = input.plantCapacity;

  final Map<String, ComponentCost> components = {};
  double systemSubTotal = 0;

  // ── Component calculation ─────────────────────────────────────────────────

  for (final key in QuotationInput.componentKeys) {
    final component = input.componentFor(key);
    final label = componentDisplayNames[key] ?? key;

    final q = component.quantity;
    final p = component.unitPrice;

    if (q <= 0 || p <= 0) continue;

    double baseCost;

    switch (component.type) {
      case ComponentType.quantityBased:
        baseCost = q * p;

      case ComponentType.plantCapacityBased:
        if (plantCapacity <= 0) continue;
        baseCost = plantCapacity * p * q;

      case ComponentType.panelCapacityBased:
        final panelWp = component.panelCapacityWp;
        if (panelWp <= 0) continue;
        baseCost = panelWp * p * q;
    }

    components[key] = ComponentCost(
      name: label,
      quantity: q,
      unitPrice: p,
      subTotal: _round2(baseCost),
    );

    systemSubTotal += baseCost;
  }

  // ── Stop here if the quotation is incomplete ──────────────────────────────

  if (!isQuotationComplete(input)) {
    return CostingResult(
      components: components,
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

  // ── Project-level additional costs ────────────────────────────────────────

  final double contingency = _pct(systemSubTotal, input.contingency.percentage);
  final double cp1         = _pct(systemSubTotal, input.cp1.percentage);
  final double cp2         = _pct(systemSubTotal, input.cp2.percentage);
  final double amc         = _pct(systemSubTotal, input.amc.percentage);

  // Subsidy processing fee: only non-zero when isSubsidyProject is true.
  // The fixed amount comes from the input (set by the mapper); default is 0.
  final double subsidyProcessingFee = input.subsidyProcessingFee.amount;

  final double grandTotal =
      systemSubTotal + contingency + cp1 + cp2 + amc + subsidyProcessingFee;

  final double projectCostAfterGst = grandTotal * (1 + kEffectiveGstRate);

  final double perWpBeforeGst =
      plantCapacity > 0 ? grandTotal / plantCapacity : 0;

  final double perWpAfterGst =
      plantCapacity > 0 ? projectCostAfterGst / plantCapacity : 0;

  return CostingResult(
    components: components,
    systemSubTotal:       _round2(systemSubTotal),
    contingency:          _round2(contingency),
    cp1:                  _round2(cp1),
    cp2:                  _round2(cp2),
    amc:                  _round2(amc),
    subsidyProcessingFee: _round2(subsidyProcessingFee), // ← bug fixed: was hardcoded 0
    grandTotal:           _round2(grandTotal),
    projectCostAfterGst:  _round2(projectCostAfterGst),
    perWpBeforeGst:       _round2(perWpBeforeGst),
    perWpAfterGst:        _round2(perWpAfterGst),
  );
}
