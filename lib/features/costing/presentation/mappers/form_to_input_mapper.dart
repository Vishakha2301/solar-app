import '../../domain/models/quotation_input.dart';
import '../../domain/models/calculator_fields.dart';
import '../state/quotation_form_state.dart';

QuotationInput mapFormStateToQuotationInput(
  QuotationFormState formState,
) {
  final c = formState.components;

  return QuotationInput(
    // =====================================================
    // PROJECT LEVEL
    // =====================================================
    plantCapacity: formState.plantCapacity.toString(),
    isSubsidyProject: formState.isSubsidyProject,

    // =====================================================
    // CORE COMPONENTS
    // =====================================================
    solarPanel: _capacityComponent(
      capacity: c['solarPanel']!.capacity,
      input: c['solarPanel']!,
      gstRate: '5',
    ),

    invertor: _qtyComponent(
      input: c['invertor']!,
      gstRate: '5',
    ),

    mountingStructure: _plantCapacityComponent(
      plantCapacity: formState.plantCapacity,
      input: c['mountingStructure']!,
      gstRate: '18',
    ),

    // =====================================================
    // BOS
    // =====================================================
    dcdb: _qtyComponent(
      input: c['dcdb']!,
      gstRate: '18',
    ),

    acdb: _qtyComponent(
      input: c['acdb']!,
      gstRate: '18',
    ),

    // =====================================================
    // CABLES (CAPACITY EDITABLE)
    // =====================================================
    acArmouredCable: _capacityComponent(
      capacity: c['acArmouredCable']!.capacity,
      input: c['acArmouredCable']!,
      gstRate: '18',
    ),

    acFlexibleCable: _capacityComponent(
      capacity: c['acFlexibleCable']!.capacity,
      input: c['acFlexibleCable']!,
      gstRate: '18',
    ),

    dcCable: _capacityComponent(
      capacity: c['dcCable']!.capacity,
      input: c['dcCable']!,
      gstRate: '18',
    ),

    acEarthingCable: _capacityComponent(
      capacity: c['acEarthingCable']!.capacity,
      input: c['acEarthingCable']!,
      gstRate: '18',
    ),

    // =====================================================
    // OTHER MATERIALS & SERVICES
    // =====================================================
    earthingMaterial: _qtyComponent(
      input: c['earthingMaterial']!,
      gstRate: '18',
    ),

    la: _qtyComponent(
      input: c['la']!,
      gstRate: '18',
    ),

    installation: _plantCapacityComponent(
      plantCapacity: formState.plantCapacity,
      input: c['installation']!,
      gstRate: '18',
    ),

    electricalsPlumbing: _qtyComponent(
      input: c['electricalsPlumbing']!,
      gstRate: '18',
    ),

    civilWork: _qtyComponent(
      input: c['civilWork']!,
      gstRate: '18',
    ),

    transport: _qtyComponent(
      input: c['transport']!,
      gstRate: '18',
    ),

    netMetersAndFees: _qtyComponent(
      input: c['netMetersAndFees']!,
      gstRate: '18',
    ),

    netMeteringPayments: _qtyComponent(
      input: c['netMeteringPayments']!,
      gstRate: '18',
    ),

    // =====================================================
    // PERCENTAGES
    // =====================================================
    contingency: PercentageBasedComponent(
      percentage: formState.contingency.percentage.toString(),
    ),

    cp1: PercentageBasedComponent(
      percentage: formState.cp1.percentage.toString(),
    ),

    cp2: PercentageBasedComponent(
      percentage: formState.cp2.percentage.toString(),
    ),

    amc: PercentageBasedComponent(
      percentage: formState.amc.percentage.toString(),
    ),

   // =====================================================
// FIXED
// =====================================================
subsidyProcessingFee: formState.isSubsidyProject
    ? FixedAmountComponent(
        amount: '99',
      )
    : FixedAmountComponent(
        amount: '0',
      ),
  );
}

// =====================================================
// HELPERS
// =====================================================

CapacityBasedComponent _qtyComponent({
  required ComponentFormInput input,
  required String gstRate,
}) {
  return CapacityBasedComponent(
    capacity: '0',
    basePrice: input.basePrice.toString(),
    quantity: input.quantity.toString(),
    gstRate: gstRate,
    unit: input.unit,
  );
}

CapacityBasedComponent _capacityComponent({
  required double? capacity,
  required ComponentFormInput input,
  required String gstRate,
}) {
  return CapacityBasedComponent(
    capacity: (capacity ?? 0).toString(),
    basePrice: input.basePrice.toString(),
    quantity: input.quantity.toString(),
    gstRate: gstRate,
    unit: input.unit,
  );
}

CapacityBasedComponent _plantCapacityComponent({
  required double plantCapacity,
  required ComponentFormInput input,
  required String gstRate,
}) {
  return CapacityBasedComponent(
    capacity: plantCapacity.toString(),
    basePrice: input.basePrice.toString(),
    quantity: input.quantity.toString(),
    gstRate: gstRate,
    unit: input.unit,
  );
}
