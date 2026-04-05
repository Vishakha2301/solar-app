class CostingContext {
  final double plantCapacity;
  final String systemType;
  final String phaseType;
  final String roofType;
  final String roofIdentifier;
  final bool isSubsidyProject;

  const CostingContext({
    required this.plantCapacity,
    required this.systemType,
    required this.phaseType,
    required this.roofType,
    required this.roofIdentifier,
    required this.isSubsidyProject,
  });

  Map<String, dynamic> toJson() => {
        'plantCapacity': plantCapacity,
        'systemType': systemType,
        'phaseType': phaseType,
        'roofType': roofType,
        'roofIdentifier': roofIdentifier,
        'isSubsidyProject': isSubsidyProject,
      };

  factory CostingContext.fromJson(Map<String, dynamic> json) => CostingContext(
        plantCapacity: (json['plantCapacity'] as num).toDouble(),
        systemType: json['systemType'] as String,
        phaseType: json['phaseType'] as String,
        roofType: json['roofType'] as String,
        roofIdentifier: json['roofIdentifier'] as String,
        isSubsidyProject: json['isSubsidyProject'] as bool,
      );
}