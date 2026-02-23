import 'calculator_fields.dart';
import 'component_type.dart';

/// The full set of inputs required to calculate a solar project quotation.
///
/// This is the domain's aggregate input — it is constructed by the mapper
/// from [QuotationFormState] and consumed by [calculateQuotation].
///
/// All fields are immutable. The [componentKeys] constant list defines
/// the canonical ordering used across the UI and calculations.
class QuotationInput {
  final double plantCapacity;
  final bool isSubsidyProject;

  // ── Core ──────────────────────────────────────────────────────────────────
  final SolarComponent solarPanel;
  final SolarComponent invertor;
  final SolarComponent mountingStructure;

  // ── BOS ───────────────────────────────────────────────────────────────────
  final SolarComponent dcdb;
  final SolarComponent acdb;

  // ── Cables ────────────────────────────────────────────────────────────────
  final SolarComponent acArmouredCable;
  final SolarComponent acFlexibleCable;
  final SolarComponent dcCable;
  final SolarComponent acEarthingCable;

  // ── Other materials & services ────────────────────────────────────────────
  final SolarComponent earthingMaterial;
  final SolarComponent la;
  final SolarComponent installation;
  final SolarComponent electricalsPlumbing;
  final SolarComponent civilWork;
  final SolarComponent transport;
  final SolarComponent netMetersAndFees;
  final SolarComponent netMeteringPayments;

  // ── Additional costs ──────────────────────────────────────────────────────
  final PercentageCost contingency;
  final PercentageCost cp1;
  final PercentageCost cp2;
  final PercentageCost amc;
  final FixedCost subsidyProcessingFee;

  const QuotationInput({
    required this.plantCapacity,
    required this.isSubsidyProject,
    required this.solarPanel,
    required this.invertor,
    required this.mountingStructure,
    required this.dcdb,
    required this.acdb,
    required this.acArmouredCable,
    required this.acFlexibleCable,
    required this.dcCable,
    required this.acEarthingCable,
    required this.earthingMaterial,
    required this.la,
    required this.installation,
    required this.electricalsPlumbing,
    required this.civilWork,
    required this.transport,
    required this.netMetersAndFees,
    required this.netMeteringPayments,
    required this.contingency,
    required this.cp1,
    required this.cp2,
    required this.amc,
    required this.subsidyProcessingFee,
  });

  /// Canonical ordered list of component keys.
  /// Used by the UI, mapper, and validator to ensure consistent ordering.
  static const List<String> componentKeys = [
    'solarPanel',
    'invertor',
    'mountingStructure',
    'dcdb',
    'acdb',
    'acArmouredCable',
    'acFlexibleCable',
    'dcCable',
    'acEarthingCable',
    'earthingMaterial',
    'la',
    'installation',
    'electricalsPlumbing',
    'civilWork',
    'transport',
    'netMetersAndFees',
    'netMeteringPayments',
  ];

  /// Returns the [SolarComponent] for a given key.
  /// Throws [ArgumentError] for unknown keys.
  SolarComponent componentFor(String key) {
    return switch (key) {
      'solarPanel'          => solarPanel,
      'invertor'            => invertor,
      'mountingStructure'   => mountingStructure,
      'dcdb'                => dcdb,
      'acdb'                => acdb,
      'acArmouredCable'     => acArmouredCable,
      'acFlexibleCable'     => acFlexibleCable,
      'dcCable'             => dcCable,
      'acEarthingCable'     => acEarthingCable,
      'earthingMaterial'    => earthingMaterial,
      'la'                  => la,
      'installation'        => installation,
      'electricalsPlumbing' => electricalsPlumbing,
      'civilWork'           => civilWork,
      'transport'           => transport,
      'netMetersAndFees'    => netMetersAndFees,
      'netMeteringPayments' => netMeteringPayments,
      _                     => throw ArgumentError('Unknown component key: $key'),
    };
  }
}

/// Default [ComponentType] for each component key.
/// Used by the mapper and the UI to know how to build/display each component.
const Map<String, ComponentType> componentTypeByKey = {
  'solarPanel'          : ComponentType.panelCapacityBased,
  'invertor'            : ComponentType.quantityBased,
  'mountingStructure'   : ComponentType.plantCapacityBased,
  'dcdb'                : ComponentType.quantityBased,
  'acdb'                : ComponentType.quantityBased,
  'acArmouredCable'     : ComponentType.quantityBased,
  'acFlexibleCable'     : ComponentType.quantityBased,
  'dcCable'             : ComponentType.quantityBased,
  'acEarthingCable'     : ComponentType.quantityBased,
  'earthingMaterial'    : ComponentType.quantityBased,
  'la'                  : ComponentType.quantityBased,
  'installation'        : ComponentType.plantCapacityBased,
  'electricalsPlumbing' : ComponentType.quantityBased,
  'civilWork'           : ComponentType.quantityBased,
  'transport'           : ComponentType.quantityBased,
  'netMetersAndFees'    : ComponentType.quantityBased,
  'netMeteringPayments' : ComponentType.quantityBased,
};

/// Human-readable display names for each component key.
/// Moved here from presentation so it is treated as domain knowledge.
const Map<String, String> componentDisplayNames = {
  'solarPanel'          : 'Solar Panel',
  'invertor'            : 'Inverter',
  'mountingStructure'   : 'Mounting Structure',
  'dcdb'                : 'DCDB',
  'acdb'                : 'ACDB',
  'acArmouredCable'     : 'AC Armoured Cable',
  'acFlexibleCable'     : 'AC Flexible Cable',
  'dcCable'             : 'DC Cable',
  'acEarthingCable'     : 'AC Earthing Cable',
  'earthingMaterial'    : 'Earthing Material',
  'la'                  : 'Lightning Arrester',
  'installation'        : 'Installation',
  'electricalsPlumbing' : 'Electricals & Plumbing',
  'civilWork'           : 'Civil Work',
  'transport'           : 'Transport',
  'netMetersAndFees'    : 'Net Metering Fees',
  'netMeteringPayments' : 'Net Metering Payments',
};
