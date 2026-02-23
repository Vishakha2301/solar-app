import '../../domain/models/quotation_input.dart';
import '../../domain/models/calculator_fields.dart';
import '../../domain/models/component_type.dart';
import '../../domain/usecases/calculate_quotation.dart' show kSubsidyProcessingFeeAmount;
import '../state/quotation_form_state.dart';

/// Maps the UI [QuotationFormState] to the domain [QuotationInput].
///
/// This is the only place in the app that knows how to translate
/// user-entered form data into the structure expected by [calculateQuotation].
QuotationInput mapFormStateToQuotationInput(QuotationFormState formState) {
  final c = formState.components;

  return QuotationInput(
    plantCapacity: formState.plantCapacity,
    isSubsidyProject: formState.isSubsidyProject,

    solarPanel:          _toSolarComponent(c['solarPanel']!,          gstRate: '5'),
    invertor:            _toSolarComponent(c['invertor']!,            gstRate: '5'),
    mountingStructure:   _toSolarComponent(c['mountingStructure']!,   gstRate: '18'),
    dcdb:                _toSolarComponent(c['dcdb']!,                gstRate: '18'),
    acdb:                _toSolarComponent(c['acdb']!,                gstRate: '18'),
    acArmouredCable:     _toSolarComponent(c['acArmouredCable']!,     gstRate: '18'),
    acFlexibleCable:     _toSolarComponent(c['acFlexibleCable']!,     gstRate: '18'),
    dcCable:             _toSolarComponent(c['dcCable']!,             gstRate: '18'),
    acEarthingCable:     _toSolarComponent(c['acEarthingCable']!,     gstRate: '18'),
    earthingMaterial:    _toSolarComponent(c['earthingMaterial']!,    gstRate: '18'),
    la:                  _toSolarComponent(c['la']!,                  gstRate: '18'),
    installation:        _toSolarComponent(c['installation']!,        gstRate: '18'),
    electricalsPlumbing: _toSolarComponent(c['electricalsPlumbing']!, gstRate: '18'),
    civilWork:           _toSolarComponent(c['civilWork']!,           gstRate: '18'),
    transport:           _toSolarComponent(c['transport']!,           gstRate: '18'),
    netMetersAndFees:    _toSolarComponent(c['netMetersAndFees']!,    gstRate: '18'),
    netMeteringPayments: _toSolarComponent(c['netMeteringPayments']!, gstRate: '18'),

    contingency: PercentageCost(percentage: formState.contingency.percentage),
    cp1:         PercentageCost(percentage: formState.cp1.percentage),
    cp2:         PercentageCost(percentage: formState.cp2.percentage),
    amc:         PercentageCost(percentage: formState.amc.percentage),

    // Subsidy processing fee: ₹99 when subsidy project, otherwise ₹0.
    subsidyProcessingFee: FixedCost(
      amount: formState.isSubsidyProject ? kSubsidyProcessingFeeAmount : 0,
    ),
  );
}

/// Converts a [ComponentFormInput] to a domain [SolarComponent].
///
/// The [ComponentType] is carried on the form input itself, so no conditional
/// logic is needed here — the calculator's switch statement handles dispatch.
SolarComponent _toSolarComponent(
  ComponentFormInput input, {
  required String gstRate,
}) {
  return SolarComponent(
    type:           input.type,
    quantity:       input.quantity,
    unitPrice:      input.unitPrice,
    gstRate:        gstRate,
    unit:           input.unit,
    panelCapacityWp: input.panelCapacityWp,
    specification:  input.specification,
  );
}
