import '../models/quotation_input.dart';
import '../models/component_cost.dart';
import '../models/costing_result.dart';
import '../validators/quotation_validator.dart';

class CalculatorUtils {
  static double parse(String value) {
    return double.tryParse(value) ?? 0;
  }

  static double round2(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  static double percentage(double base, String percent) {
    final p = parse(percent);
    return base * p / 100;
  }
}

CostingResult calculateQuotation(QuotationInput input) {
  final double plantCapacity =
      CalculatorUtils.parse(input.plantCapacity);

  final Map<String, ComponentCost> components = {};
  double systemSubTotal = 0;

  // =========================================================
  // HELPERS
  // =========================================================
  void addQtyComponent({
    required String key,
    required String label,
    required String qty,
    required String price,
  }) {
    final q = CalculatorUtils.parse(qty);
    final p = CalculatorUtils.parse(price);

    if (q > 0 && p > 0) {
      final baseCost = q * p;

      components[key] = ComponentCost(
        name: label,
        quantity: q,
        unitPrice: p,
        subTotal: CalculatorUtils.round2(baseCost),
      );

      systemSubTotal += baseCost;
    }
  }

  void addCapacityComponent({
    required String key,
    required String label,
    required String qty,
    required String price,
  }) {
    final q = CalculatorUtils.parse(qty);
    final p = CalculatorUtils.parse(price);

    if (plantCapacity > 0 && q > 0 && p > 0) {
      final baseCost = plantCapacity * p * q;

      components[key] = ComponentCost(
        name: label,
        quantity: q,
        unitPrice: p,
        subTotal: CalculatorUtils.round2(baseCost),
      );

      systemSubTotal += baseCost;
    }
  }

  // =========================================================
  // COMPONENT CALCULATIONS (ALWAYS)
  // =========================================================

  // Solar Panel
  final panelCapacity =
      CalculatorUtils.parse(input.solarPanel.capacity);
  final panelQty =
      CalculatorUtils.parse(input.solarPanel.quantity);
  final panelPrice =
      CalculatorUtils.parse(input.solarPanel.basePrice);

  if (panelCapacity > 0 && panelQty > 0 && panelPrice > 0) {
    final baseCost =
        panelCapacity * panelPrice * panelQty;

    components['solarPanel'] = ComponentCost(
      name: 'Solar Panel',
      quantity: panelQty,
      unitPrice: panelPrice,
      subTotal: CalculatorUtils.round2(baseCost),
    );

    systemSubTotal += baseCost;
  }

  addQtyComponent(
    key: 'invertor',
    label: 'Inverter',
    qty: input.invertor.quantity,
    price: input.invertor.basePrice,
  );

  addCapacityComponent(
    key: 'mountingStructure',
    label: 'Mounting Structure',
    qty: input.mountingStructure.quantity,
    price: input.mountingStructure.basePrice,
  );

  addQtyComponent(
    key: 'dcdb',
    label: 'DCDB',
    qty: input.dcdb.quantity,
    price: input.dcdb.basePrice,
  );

  addQtyComponent(
    key: 'acdb',
    label: 'ACDB',
    qty: input.acdb.quantity,
    price: input.acdb.basePrice,
  );

  addQtyComponent(
    key: 'acArmouredCable',
    label: 'AC Armoured Cable',
    qty: input.acArmouredCable.quantity,
    price: input.acArmouredCable.basePrice,
  );

  addQtyComponent(
    key: 'acFlexibleCable',
    label: 'AC Flexible Cable',
    qty: input.acFlexibleCable.quantity,
    price: input.acFlexibleCable.basePrice,
  );

  addQtyComponent(
    key: 'dcCable',
    label: 'DC Cable',
    qty: input.dcCable.quantity,
    price: input.dcCable.basePrice,
  );

  addQtyComponent(
    key: 'acEarthingCable',
    label: 'AC Earthing Cable',
    qty: input.acEarthingCable.quantity,
    price: input.acEarthingCable.basePrice,
  );

  addQtyComponent(
    key: 'earthingMaterial',
    label: 'Earthing Material',
    qty: input.earthingMaterial.quantity,
    price: input.earthingMaterial.basePrice,
  );

  addQtyComponent(
    key: 'la',
    label: 'Lightning Arrester',
    qty: input.la.quantity,
    price: input.la.basePrice,
  );

  addQtyComponent(
    key: 'electricalsPlumbing',
    label: 'Electricals & Plumbing',
    qty: input.electricalsPlumbing.quantity,
    price: input.electricalsPlumbing.basePrice,
  );

  addQtyComponent(
    key: 'civilWork',
    label: 'Civil Work',
    qty: input.civilWork.quantity,
    price: input.civilWork.basePrice,
  );

  addQtyComponent(
    key: 'transport',
    label: 'Transport',
    qty: input.transport.quantity,
    price: input.transport.basePrice,
  );

  addQtyComponent(
    key: 'netMetersAndFees',
    label: 'Net Metering Fees',
    qty: input.netMetersAndFees.quantity,
    price: input.netMetersAndFees.basePrice,
  );

  addQtyComponent(
    key: 'netMeteringPayments',
    label: 'Net Metering Payments',
    qty: input.netMeteringPayments.quantity,
    price: input.netMeteringPayments.basePrice,
  );

  addCapacityComponent(
    key: 'installation',
    label: 'Installation',
    qty: input.installation.quantity,
    price: input.installation.basePrice,
  );

  // =========================================================
  // ❌ STOP HERE IF SYSTEM NOT COMPLETE
  // =========================================================
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

  // =========================================================
  // PROJECT-LEVEL CALCULATION
  // =========================================================
  final contingency =
      CalculatorUtils.percentage(systemSubTotal, input.contingency.percentage);
  final cp1 =
      CalculatorUtils.percentage(systemSubTotal, input.cp1.percentage);
  final cp2 =
      CalculatorUtils.percentage(systemSubTotal, input.cp2.percentage);
  final amc =
      CalculatorUtils.percentage(systemSubTotal, input.amc.percentage);
  
  final double subsidyProcessingFee =
    CalculatorUtils.parse(input.subsidyProcessingFee.amount);

  final double grandTotal =
      systemSubTotal + contingency + cp1 + cp2 + amc + subsidyProcessingFee;

  const double effectiveGstRate = 0.089;

  final double projectCostAfterGst =
      grandTotal * (1 + effectiveGstRate);

  final double perWpBeforeGst =
      plantCapacity > 0 ? grandTotal / plantCapacity : 0;

  final double perWpAfterGst =
      plantCapacity > 0 ? projectCostAfterGst / plantCapacity : 0;

  return CostingResult(
    components: components,
    systemSubTotal: CalculatorUtils.round2(systemSubTotal),
    contingency: CalculatorUtils.round2(contingency),
    cp1: CalculatorUtils.round2(cp1),
    cp2: CalculatorUtils.round2(cp2),
    amc: CalculatorUtils.round2(amc),
    subsidyProcessingFee: 0,
    grandTotal: CalculatorUtils.round2(grandTotal),
    projectCostAfterGst: CalculatorUtils.round2(projectCostAfterGst),
    perWpBeforeGst: CalculatorUtils.round2(perWpBeforeGst),
    perWpAfterGst: CalculatorUtils.round2(perWpAfterGst),
  );
}