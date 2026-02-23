import '../../presentation/state/quotation_form_state.dart';
import 'component_cost.dart';

class CostingSnapshot {
  final double systemSubTotal;
  final double subsidyProcessingFee;
  final double contingency;
  final double cp1;
  final double cp2;
  final double amc;
  final double grandTotal;
  final double projectCostAfterGst;
  final double perWpAfterGst;

  final Map<String, ComponentCost> components;
  final Map<String, ComponentFormInput> componentInputs;

  const CostingSnapshot({
    required this.systemSubTotal,
    required this.subsidyProcessingFee,
    required this.contingency,
    required this.cp1,
    required this.cp2,
    required this.amc,
    required this.grandTotal,
    required this.projectCostAfterGst,
    required this.perWpAfterGst,
    required this.components,
    required this.componentInputs,
  });
}
