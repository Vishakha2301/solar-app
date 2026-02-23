import '../models/quotation_input.dart';

bool isQuotationComplete(QuotationInput input) {
  // ---- Plant capacity ----
  final plantCapacity =
      double.tryParse(input.plantCapacity) ?? 0;

  if (plantCapacity <= 0) {
    return false;
  }

  bool isValidComponent(String qty, String price) {
    final q = double.tryParse(qty) ?? 0;
    final p = double.tryParse(price) ?? 0;
    return q > 0 && p > 0;
  }

  // ---- ALL SYSTEM COMPONENTS MUST BE VALID ----
  final List<bool> checks = [
    // Core
    isValidComponent(input.solarPanel.quantity, input.solarPanel.basePrice),
    isValidComponent(input.invertor.quantity, input.invertor.basePrice),
    isValidComponent(input.mountingStructure.quantity, input.mountingStructure.basePrice),
    isValidComponent(input.installation.quantity, input.installation.basePrice),

    // BOS
    isValidComponent(input.dcdb.quantity, input.dcdb.basePrice),
    isValidComponent(input.acdb.quantity, input.acdb.basePrice),

    // Cables
    isValidComponent(input.acArmouredCable.quantity, input.acArmouredCable.basePrice),
    isValidComponent(input.acFlexibleCable.quantity, input.acFlexibleCable.basePrice),
    isValidComponent(input.dcCable.quantity, input.dcCable.basePrice),
    isValidComponent(input.acEarthingCable.quantity, input.acEarthingCable.basePrice),

    // Others
    isValidComponent(input.earthingMaterial.quantity, input.earthingMaterial.basePrice),
    isValidComponent(input.la.quantity, input.la.basePrice),
    isValidComponent(input.electricalsPlumbing.quantity, input.electricalsPlumbing.basePrice),
    isValidComponent(input.civilWork.quantity, input.civilWork.basePrice),
    isValidComponent(input.transport.quantity, input.transport.basePrice),
    isValidComponent(input.netMetersAndFees.quantity, input.netMetersAndFees.basePrice),
    isValidComponent(input.netMeteringPayments.quantity, input.netMeteringPayments.basePrice),
  ];

  if (checks.any((isValid) => !isValid)) {
    return false;
  }

  // ---- Percentage-based checks (NOT mandatory) ----
  final cp1 =
      double.tryParse(input.cp1.percentage) ?? 0;
  if (cp1 < 0) return false;

  final contingency =
      double.tryParse(input.contingency.percentage) ?? 0;
  if (contingency < 0) return false;

  final amc =
      double.tryParse(input.amc.percentage) ?? 0;
  if (amc < 0) return false;

  return true;
}
