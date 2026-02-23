import 'component_cost.dart';

class CostingResult {
  final Map<String, ComponentCost> components;

  final double systemSubTotal;
  final double contingency;
  final double cp1;
  final double cp2;
  final double amc;
  final double subsidyProcessingFee;

  final double grandTotal;

  final double projectCostAfterGst;

  final num perWpAfterGst;

  final num perWpBeforeGst;

  CostingResult({
    required this.components,
    required this.systemSubTotal,
    required this.contingency,
    required this.cp1,
    required this.cp2,
    required this.amc,
    required this.subsidyProcessingFee,
    required this.grandTotal, 
    required this.projectCostAfterGst, 
    required this.perWpAfterGst, 
    required this.perWpBeforeGst,
  });

  factory CostingResult.empty() {
    return CostingResult(
      components: {},
      systemSubTotal: 0,
      contingency: 0,
      cp1: 0,
      cp2: 0,
      amc: 0,
      subsidyProcessingFee: 0,
      grandTotal: 0,
      projectCostAfterGst: 0,
      perWpAfterGst: 0,
      perWpBeforeGst: 0
    );
  }
}
