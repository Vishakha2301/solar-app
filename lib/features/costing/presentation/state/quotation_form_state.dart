import '../../domain/models/component_input_snapshot.dart';
import '../../domain/models/component_type.dart';

/// UI-layer form state for a single component field group.
///
/// Immutable — use [copyWith] to produce modified instances.
class ComponentFormInput {
  final ComponentType type;
  final double quantity;
  final double unitPrice;
  final String unit;

  /// Watt-peak of a single panel. Only used for [ComponentType.panelCapacityBased].
  final double panelCapacityWp;

  /// Cable specification string, e.g. '04 Sq 02C Cu'. Only used for cables.
  final String? specification;

  const ComponentFormInput({
    required this.type,
    required this.quantity,
    required this.unitPrice,
    required this.unit,
    this.panelCapacityWp = 0,
    this.specification,
  });

  ComponentFormInput copyWith({
    double? quantity,
    double? unitPrice,
    double? panelCapacityWp,
    String? specification,
  }) {
    return ComponentFormInput(
      type: type,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      unit: unit,
      panelCapacityWp: panelCapacityWp ?? this.panelCapacityWp,
      specification: specification ?? this.specification,
    );
  }

  /// Converts to the domain snapshot type for persistence.
  ComponentInputSnapshot toSnapshot() => ComponentInputSnapshot(
        type: type,
        quantity: quantity,
        unitPrice: unitPrice,
        unit: unit,
        panelCapacityWp: panelCapacityWp,
        specification: specification,
      );

  /// Restores a [ComponentFormInput] from a persisted domain snapshot.
  factory ComponentFormInput.fromSnapshot(ComponentInputSnapshot snap) =>
      ComponentFormInput(
        type: snap.type,
        quantity: snap.quantity,
        unitPrice: snap.unitPrice,
        unit: snap.unit,
        panelCapacityWp: snap.panelCapacityWp,
        specification: snap.specification,
      );
}

/// UI-layer state for a percentage-based additional cost field.
class PercentageFormInput {
  final double percentage;

  const PercentageFormInput({required this.percentage});

  PercentageFormInput copyWith({double? percentage}) =>
      PercentageFormInput(percentage: percentage ?? this.percentage);
}

/// The complete mutable UI form state for the costing page.
///
/// Immutable — all mutations produce a new instance via [copyWith].
class QuotationFormState {
  final double plantCapacity;

  // ── Costing context ────────────────────────────────────────────────────────
  final String systemType;      // 'Rooftop' | 'Ground'
  final String phaseType;       // '1PH' | '3PH'
  final String roofType;        // 'RCC' | 'Shed' | 'Ground'
  final String roofIdentifier;
  final bool isSubsidyProject;

  // ── Components ─────────────────────────────────────────────────────────────
  final Map<String, ComponentFormInput> components;

  // ── Additional costs ───────────────────────────────────────────────────────
  final PercentageFormInput contingency;
  final PercentageFormInput cp1;
  final PercentageFormInput cp2;
  final PercentageFormInput amc;

  const QuotationFormState({
    required this.plantCapacity,
    required this.systemType,
    required this.phaseType,
    required this.roofType,
    required this.roofIdentifier,
    required this.isSubsidyProject,
    required this.components,
    required this.contingency,
    required this.cp1,
    required this.cp2,
    required this.amc,
  });

  /// Default blank state used when creating a new costing project.
  ///
  /// Default quantities and specifications match real-world solar project norms.
  /// This is the single source of truth for defaults — the old
  /// `initial_calculator_state.dart` (which duplicated these as [QuotationInput])
  /// has been deleted.
  factory QuotationFormState.initial() {
    return const QuotationFormState(
      plantCapacity: 0,
      systemType: 'Rooftop',
      phaseType: '1PH',
      roofType: 'RCC',
      roofIdentifier: '',
      isSubsidyProject: false,
      contingency: PercentageFormInput(percentage: 0),
      cp1:         PercentageFormInput(percentage: 12.5),
      cp2:         PercentageFormInput(percentage: 0),
      amc:         PercentageFormInput(percentage: 0),
      components: {
        // ── Core ──────────────────────────────────────────────────────────
        'solarPanel': ComponentFormInput(
          type: ComponentType.panelCapacityBased,
          quantity: 0,
          unitPrice: 0,
          panelCapacityWp: 0,
          unit: 'Wp',
        ),
        'invertor': ComponentFormInput(
          type: ComponentType.quantityBased,
          quantity: 1,
          unitPrice: 0,
          unit: 'Nos',
        ),
        'mountingStructure': ComponentFormInput(
          type: ComponentType.plantCapacityBased,
          quantity: 1,
          unitPrice: 0,
          unit: 'Wp',
        ),

        // ── BOS ───────────────────────────────────────────────────────────
        'dcdb': ComponentFormInput(
          type: ComponentType.quantityBased,
          quantity: 1,
          unitPrice: 0,
          unit: 'Nos',
        ),
        'acdb': ComponentFormInput(
          type: ComponentType.quantityBased,
          quantity: 1,
          unitPrice: 0,
          unit: 'Nos',
        ),

        // ── Cables ────────────────────────────────────────────────────────
        'acArmouredCable': ComponentFormInput(
          type: ComponentType.quantityBased,
          quantity: 0,
          unitPrice: 0,
          specification: '04 Sq 02C Cu',
          unit: 'Mtr',
        ),
        'acFlexibleCable': ComponentFormInput(
          type: ComponentType.quantityBased,
          quantity: 0,
          unitPrice: 0,
          specification: '04 Sq 02C Cu',
          unit: 'Mtr',
        ),
        'dcCable': ComponentFormInput(
          type: ComponentType.quantityBased,
          quantity: 0,
          unitPrice: 0,
          specification: '4 Sq',
          unit: 'Mtr',
        ),
        'acEarthingCable': ComponentFormInput(
          type: ComponentType.quantityBased,
          quantity: 0,
          unitPrice: 0,
          specification: '16 Al',
          unit: 'Mtr',
        ),

        // ── Other ─────────────────────────────────────────────────────────
        'earthingMaterial': ComponentFormInput(
          type: ComponentType.quantityBased,
          quantity: 3,
          unitPrice: 0,
          unit: 'Nos',
        ),
        'la': ComponentFormInput(
          type: ComponentType.quantityBased,
          quantity: 1,
          unitPrice: 0,
          unit: 'Nos',
        ),
        'installation': ComponentFormInput(
          type: ComponentType.plantCapacityBased,
          quantity: 1,
          unitPrice: 0,
          unit: 'Wp',
        ),
        'electricalsPlumbing': ComponentFormInput(
          type: ComponentType.quantityBased,
          quantity: 1,
          unitPrice: 0,
          unit: 'Nos',
        ),
        'civilWork': ComponentFormInput(
          type: ComponentType.quantityBased,
          quantity: 6,
          unitPrice: 0,
          unit: 'Nos',
        ),
        'transport': ComponentFormInput(
          type: ComponentType.quantityBased,
          quantity: 1,
          unitPrice: 0,
          unit: 'Nos',
        ),
        'netMetersAndFees': ComponentFormInput(
          type: ComponentType.quantityBased,
          quantity: 1,
          unitPrice: 0,
          unit: 'Nos',
        ),
        'netMeteringPayments': ComponentFormInput(
          type: ComponentType.quantityBased,
          quantity: 1,
          unitPrice: 0,
          unit: 'Nos',
        ),
      },
    );
  }

  QuotationFormState copyWith({
    double? plantCapacity,
    String? systemType,
    String? phaseType,
    String? roofType,
    String? roofIdentifier,
    bool? isSubsidyProject,
    Map<String, ComponentFormInput>? components,
    PercentageFormInput? contingency,
    PercentageFormInput? cp1,
    PercentageFormInput? cp2,
    PercentageFormInput? amc,
  }) {
    return QuotationFormState(
      plantCapacity:   plantCapacity   ?? this.plantCapacity,
      systemType:      systemType      ?? this.systemType,
      phaseType:       phaseType       ?? this.phaseType,
      roofType:        roofType        ?? this.roofType,
      roofIdentifier:  roofIdentifier  ?? this.roofIdentifier,
      isSubsidyProject: isSubsidyProject ?? this.isSubsidyProject,
      components:      components      ?? this.components,
      contingency:     contingency     ?? this.contingency,
      cp1:             cp1             ?? this.cp1,
      cp2:             cp2             ?? this.cp2,
      amc:             amc             ?? this.amc,
    );
  }
}
