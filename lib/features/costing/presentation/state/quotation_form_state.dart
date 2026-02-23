/// Flutter equivalent of calculator.initialState.ts
/// This is UI FORM STATE, not calculation result

// ignore_for_file: dangling_library_doc_comments

class ComponentFormInput {
  double quantity;
  double basePrice;
  double? capacity;        // numeric (solar, installation)
  String? specification;   // cable size (UI only)
  final String unit;

  ComponentFormInput({
    required this.quantity,
    required this.basePrice,
    this.capacity,
    this.specification,
    required this.unit,
  });

  ComponentFormInput copyWith({
    double? quantity,
    double? basePrice,
    double? capacity,
    String? specification,
  }) {
    return ComponentFormInput(
      quantity: quantity ?? this.quantity,
      basePrice: basePrice ?? this.basePrice,
      capacity: capacity ?? this.capacity,
      specification: specification ?? this.specification,
      unit: unit,
    );
  }
}

class PercentageFormInput {
  double percentage;

  PercentageFormInput({required this.percentage});

  PercentageFormInput copyWith({double? percentage}) {
    return PercentageFormInput(
      percentage: percentage ?? this.percentage,
    );
  }
}

class QuotationFormState {
  double plantCapacity;
  // 🔹 COSTING CONTEXT (NEW)
  String systemType;       // Rooftop / Ground
  String phaseType;        // 1PH / 3PH
  String roofType;         // RCC / Shed / Ground
  String roofIdentifier;   // Roof A / Block B
  bool isSubsidyProject;
  

  final Map<String, ComponentFormInput> components;

  PercentageFormInput contingency;
  PercentageFormInput cp1;
  PercentageFormInput cp2;
  PercentageFormInput amc;

  QuotationFormState({
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

  factory QuotationFormState.initial() {
    return QuotationFormState(
      plantCapacity: 0,
      // ✅ Defaults (safe)
      systemType: 'Rooftop',
      phaseType: '1PH',
      roofType: 'RCC',
      roofIdentifier: '',
      isSubsidyProject: false,
      components: {
        // ================= CORE =================
        'solarPanel': ComponentFormInput(
          quantity: 0,
          basePrice: 0,
          capacity: 0,
          unit: 'Wp',
        ),
        'invertor': ComponentFormInput(
          quantity: 1,
          basePrice: 0,
          unit: 'Nos',
        ),
        'mountingStructure': ComponentFormInput(
          quantity: 1,
          basePrice: 0,
          unit: 'Wp',
        ),

        // ================= BOS =================
        'dcdb': ComponentFormInput(
          quantity: 1,
          basePrice: 0,
          unit: 'Nos',
        ),
        'acdb': ComponentFormInput(
          quantity: 1,
          basePrice: 0,
          unit: 'Nos',
        ),

        // ================= CABLES (SPEC ONLY) =================
        'acArmouredCable': ComponentFormInput(
          quantity: 0,
          basePrice: 0,
          specification: '04 Sq 02C Cu',
          unit: 'Mtr',
        ),
        'acFlexibleCable': ComponentFormInput(
          quantity: 0,
          basePrice: 0,
          specification: '04 Sq 02C Cu',
          unit: 'Mtr',
        ),
        'dcCable': ComponentFormInput(
          quantity: 0,
          basePrice: 0,
          specification: '4 Sq',
          unit: 'Mtr',
        ),
        'acEarthingCable': ComponentFormInput(
          quantity: 0,
          basePrice: 0,
          specification: '16 Al',
          unit: 'Mtr',
        ),

        // ================= OTHER =================
        'earthingMaterial': ComponentFormInput(
          quantity: 3,
          basePrice: 0,
          unit: 'Nos',
        ),
        'la': ComponentFormInput(
          quantity: 1,
          basePrice: 0,
          unit: 'Nos',
        ),
        'installation': ComponentFormInput(
          quantity: 1,
          basePrice: 0,
          unit: 'Wp',
        ),
        'electricalsPlumbing': ComponentFormInput(
          quantity: 1,
          basePrice: 0,
          unit: 'Nos',
        ),
        'civilWork': ComponentFormInput(
          quantity: 6,
          basePrice: 0,
          unit: 'Nos',
        ),
        'transport': ComponentFormInput(
          quantity: 1,
          basePrice: 0,
          unit: 'Nos',
        ),
        'netMetersAndFees': ComponentFormInput(
          quantity: 1,
          basePrice: 0,
          unit: 'Nos',
        ),
        'netMeteringPayments': ComponentFormInput(
          quantity: 1,
          basePrice: 0,
          unit: 'Nos',
        ),
      },
      contingency: PercentageFormInput(percentage: 0),
      cp1: PercentageFormInput(percentage: 12.5),
      cp2: PercentageFormInput(percentage: 0),
      amc: PercentageFormInput(percentage: 0),
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
      plantCapacity: plantCapacity ?? this.plantCapacity,
      systemType: systemType ?? this.systemType,
      phaseType: phaseType ?? this.phaseType,
      roofType: roofType ?? this.roofType,
      roofIdentifier: roofIdentifier ?? this.roofIdentifier,
      isSubsidyProject: isSubsidyProject ?? this.isSubsidyProject,
      components: components ?? this.components,
      contingency: contingency ?? this.contingency,
      cp1: cp1 ?? this.cp1,
      cp2: cp2 ?? this.cp2,
      amc: amc ?? this.amc,
    );
  }
}