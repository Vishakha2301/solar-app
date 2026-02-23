import '../models/quotation_input.dart';
import '../models/component_type.dart';

/// Returns true if [input] has enough valid data for a full project calculation.
///
/// Rules:
/// - Plant capacity must be > 0
/// - All system components must have quantity > 0 AND unitPrice > 0
///   (for panel-capacity components, panelCapacityWp must also be > 0)
/// - Percentage costs must be >= 0 (they are optional, 0 is valid)
bool isQuotationComplete(QuotationInput input) {
  if (input.plantCapacity <= 0) return false;

  for (final key in QuotationInput.componentKeys) {
    final c = input.componentFor(key);

    if (c.quantity <= 0 || c.unitPrice <= 0) return false;

    if (c.type == ComponentType.panelCapacityBased && c.panelCapacityWp <= 0) {
      return false;
    }
  }

  // Percentage costs are optional (0 is fine) but must not be negative.
  if (input.contingency.percentage < 0) return false;
  if (input.cp1.percentage < 0) return false;
  if (input.cp2.percentage < 0) return false;
  if (input.amc.percentage < 0) return false;

  return true;
}
