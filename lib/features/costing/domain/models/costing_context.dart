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
}
