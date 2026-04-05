import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';

import '../../domain/models/costing_context.dart';
import '../../domain/models/costing_snapshot.dart';
import '../../domain/models/saved_costing.dart';
import '../../domain/models/quotation_input.dart';
import '../state/costing_store.dart';
import '../state/quotation_form_state.dart';
import '../widgets/component_list.dart';
import '../../../costing/domain/models/component_cost.dart';
import '../../../costing/domain/models/costing_result.dart';
import '../sheets/edit_component_sheet.dart';
import '../mappers/form_to_input_mapper.dart';
import '../../domain/usecases/calculate_quotation.dart';

class CostingPage extends StatefulWidget {
  final SavedCosting? existingCosting;
  final bool isDuplicate;

  const CostingPage({
    super.key,
    this.existingCosting,
    this.isDuplicate = false,
  });

  @override
  State<CostingPage> createState() => _CostingPageState();
}

class _CostingPageState extends State<CostingPage> {
  final TextEditingController plantCapacityController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController roofIdentifierController = TextEditingController();

  QuotationFormState formState = QuotationFormState.initial();
  CostingResult costingResult = CostingResult.empty();

  // ── Derived state ──────────────────────────────────────────────────────────

  bool get isProjectCalculated => costingResult.grandTotal > 0;

  bool isComponentMissing(String key) {
    final c = costingResult.components[key];
    return c == null || c.subTotal <= 0;
  }

  bool isComponentModified(String key) {
    final current = formState.components[key];
    final initial = QuotationFormState.initial().components[key];
    if (current == null || initial == null) return false;

    return current.quantity != initial.quantity ||
        current.unitPrice != initial.unitPrice ||           // ← was basePrice
        current.panelCapacityWp != initial.panelCapacityWp || // ← was capacity
        current.specification != initial.specification;
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    if (widget.existingCosting != null) {
      final ctx = widget.existingCosting!.context;
      final snap = widget.existingCosting!.snapshot;

      // Restore full state from snapshot — convert ComponentInputSnapshot → ComponentFormInput
      formState = QuotationFormState.initial().copyWith(
        plantCapacity: ctx.plantCapacity,
        systemType: ctx.systemType,
        phaseType: ctx.phaseType,
        roofType: ctx.roofType,
        roofIdentifier: ctx.roofIdentifier,
        isSubsidyProject: ctx.isSubsidyProject,
        contingency: PercentageFormInput(percentage: snap.contingency),
        cp1: PercentageFormInput(percentage: snap.cp1),
        cp2: PercentageFormInput(percentage: snap.cp2),
        amc: PercentageFormInput(percentage: snap.amc),
        // ← fromSnapshot() converts domain ComponentInputSnapshot → UI ComponentFormInput
        components: snap.componentInputs.map(
          (key, snap) => MapEntry(key, ComponentFormInput.fromSnapshot(snap)),
        ),
      );
    }

    plantCapacityController.text = formState.plantCapacity.toString();
    roofIdentifierController.text = formState.roofIdentifier;

    if (widget.isDuplicate) {
      formState = formState.copyWith(
        roofIdentifier: '${formState.roofIdentifier} - Copy',
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recalculate();
    });
  }

  @override
  void dispose() {
    plantCapacityController.dispose();
    roofIdentifierController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Calculation pipeline ──────────────────────────────────────────────────

  void _recalculate({bool fromAdditionalCost = false}) {
    final input = mapFormStateToQuotationInput(formState);
    final result = calculateQuotation(input);

    final wasNotCalculated = costingResult.grandTotal == 0;
    final isNowCalculated = result.grandTotal > 0;

    setState(() {
      costingResult = result;
    });

    if ((wasNotCalculated && isNowCalculated) ||
        (fromAdditionalCost && isNowCalculated)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  // ── UI component map ──────────────────────────────────────────────────────

  Map<String, ComponentCost> get uiComponents {
    return formState.components.map((key, input) {
      final calculated = costingResult.components[key]?.subTotal ?? 0;
      final baseName = componentDisplayNames[key] ?? key;

      String displayName = baseName;

      if (key == 'solarPanel' && input.panelCapacityWp > 0) {  // ← was capacity
        displayName =
            '$baseName (${input.panelCapacityWp.toStringAsFixed(0)} Wp)';
      } else if (input.specification != null &&
          input.specification!.isNotEmpty) {
        displayName = '$baseName (${input.specification})';
      }

      return MapEntry(
        key,
        ComponentCost(
          name: displayName,
          quantity: input.quantity,
          unitPrice: input.unitPrice,    // ← was basePrice
          subTotal: calculated,
        ),
      );
    });
  }

  // ── Edit component ────────────────────────────────────────────────────────

  void onEditComponent(String key) {
    final input = formState.components[key];
    if (input == null) return;

    final uiComponent = uiComponents[key]!;
    final initialInput = QuotationFormState.initial().components[key]!;

    showGeneralDialog(
      context: context,
      barrierLabel: 'Edit Component',
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(curved),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.97, end: 1).animate(curved),
                child: SafeArea(
                  top: false,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 4,
                            width: 44,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          EditComponentSheet(
                            componentKey: key,
                            component: uiComponent,
                            formInput: input,
                            initialFormInput: initialInput,
                            onSave: ({
                              required double quantity,
                              required double unitPrice,
                              double? panelCapacityWp,  // ← was capacity
                              String? specification,
                            }) {
                              setState(() {
                                formState = formState.copyWith(
                                  components: {
                                    ...formState.components,
                                    key: input.copyWith(
                                      quantity: quantity,
                                      unitPrice: unitPrice,       // ← was basePrice
                                      panelCapacityWp: panelCapacityWp ?? // ← was capacity
                                          input.panelCapacityWp,
                                      specification:
                                          specification ?? input.specification,
                                    ),
                                  },
                                );
                              });
                              _recalculate();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Reset ─────────────────────────────────────────────────────────────────

  void _resetAll() {
    setState(() {
      formState = QuotationFormState.initial();
      costingResult = CostingResult.empty();
      plantCapacityController.text = '0';
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Costing Project'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
            onPressed: _resetAll,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: isProjectCalculated
                ? () async {
                    final saved = SavedCosting(
                      id: (widget.isDuplicate || widget.existingCosting == null)
                          ? ''
                          : widget.existingCosting!.id,
                      createdAt: DateTime.now(),
                      context: CostingContext(
                        plantCapacity: formState.plantCapacity,
                        systemType: formState.systemType,
                        phaseType: formState.phaseType,
                        roofType: formState.roofType,
                        roofIdentifier: formState.roofIdentifier,
                        isSubsidyProject: formState.isSubsidyProject,
                      ),
                      snapshot: CostingSnapshot(
                        systemSubTotal: costingResult.systemSubTotal,
                        subsidyProcessingFee: costingResult.subsidyProcessingFee,
                        contingency: costingResult.contingency,
                        cp1: costingResult.cp1,
                        cp2: costingResult.cp2,
                        amc: costingResult.amc,
                        grandTotal: costingResult.grandTotal,
                        projectCostAfterGst: costingResult.projectCostAfterGst,
                        perWpAfterGst: costingResult.perWpAfterGst,
                        components: costingResult.components,
                        componentInputs: formState.components.map(
                          (key, input) => MapEntry(key, input.toSnapshot()),
                        ),
                      ),
                    );

                    final store = context.read<CostingStore>();
                    try {
                      if (widget.isDuplicate || widget.existingCosting == null) {
                        await store.addCosting(saved);
                      } else {
                        await store.updateCosting(widget.existingCosting!.id, saved);
                      }
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Save failed: $e')),
                        );
                      }
                    }
                  }
                : null,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: 560,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Summary ──────────────────────────────────────────
                    if (isProjectCalculated) ...[
                      _buildSummary(),
                      const SizedBox(height: 24),
                    ],

                    // ── System details ───────────────────────────────────
                    Text('System Details',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      key: ValueKey(formState.systemType),
                      initialValue: formState.systemType,
                      decoration:
                          const InputDecoration(labelText: 'System Type'),
                      items: const [
                        DropdownMenuItem(
                            value: 'Rooftop', child: Text('Rooftop')),
                        DropdownMenuItem(
                            value: 'Ground',
                            child: Text('Ground Mounted')),
                      ],
                      onChanged: (v) => setState(
                          () => formState = formState.copyWith(systemType: v!)),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      key: ValueKey(formState.phaseType),
                      initialValue: formState.phaseType,
                      decoration:
                          const InputDecoration(labelText: 'Phase Type'),
                      items: const [
                        DropdownMenuItem(
                            value: '1PH', child: Text('1 Phase')),
                        DropdownMenuItem(
                            value: '3PH', child: Text('3 Phase')),
                      ],
                      onChanged: (v) => setState(
                          () => formState = formState.copyWith(phaseType: v!)),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      key: ValueKey(formState.roofType),
                      initialValue: formState.roofType,
                      decoration:
                          const InputDecoration(labelText: 'Roof Type'),
                      items: const [
                        DropdownMenuItem(
                            value: 'RCC', child: Text('RCC Roof')),
                        DropdownMenuItem(
                            value: 'Shed', child: Text('Shed')),
                        DropdownMenuItem(
                            value: 'Ground', child: Text('Ground')),
                      ],
                      onChanged: (v) => setState(
                          () => formState = formState.copyWith(roofType: v!)),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: roofIdentifierController,
                      decoration: const InputDecoration(
                          labelText: 'Roof Identifier'),
                      onChanged: (v) => setState(() =>
                          formState = formState.copyWith(roofIdentifier: v)),
                    ),
                    const SizedBox(height: 24),

                    // ── Plant capacity ───────────────────────────────────
                    Text('Plant Capacity',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    TextField(
                      controller: plantCapacityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Plant Capacity (Wp)',
                        prefixIcon: Icon(Icons.solar_power),
                      ),
                      onChanged: (v) {
                        setState(() => formState = formState.copyWith(
                              plantCapacity: double.tryParse(v) ?? 0,
                            ));
                        _recalculate();
                      },
                    ),
                    const SizedBox(height: 24),

                    // ── Project type ─────────────────────────────────────
                    Text('Project Type',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('Government Subsidy Project'),
                      subtitle: const Text(
                          'Includes subsidy processing & liaison charges'),
                      value: formState.isSubsidyProject,
                      onChanged: (val) {
                        setState(() => formState =
                            formState.copyWith(isSubsidyProject: val));
                        _recalculate(fromAdditionalCost: true);
                      },
                    ),
                    const SizedBox(height: 24),

                    // ── Components ───────────────────────────────────────
                    Text('System Components',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),

                    ComponentList(
                      components: uiComponents,
                      onEdit: onEditComponent,
                      isModified: isComponentModified,
                      isMissing: isComponentMissing,
                    ),

                    const SizedBox(height: 16),

                    _summaryRow(
                      'System Cost (Before Additional Costs)',
                      costingResult.systemSubTotal,
                      highlight: true,
                    ),
                    const SizedBox(height: 24),

                    // ── Additional costs ─────────────────────────────────
                    Text('Additional Costs',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),

                    _percentageField(
                      'Contingency (%)',
                      formState.contingency.percentage,
                      (v) {
                        setState(() => formState = formState.copyWith(
                              contingency: formState.contingency
                                  .copyWith(percentage: v),
                            ));
                        _recalculate(fromAdditionalCost: true);
                      },
                    ),
                    _percentageField(
                      'Channel Partner 1 (%)',
                      formState.cp1.percentage,
                      (v) {
                        setState(() => formState = formState.copyWith(
                              cp1: formState.cp1.copyWith(percentage: v),
                            ));
                        _recalculate(fromAdditionalCost: true);
                      },
                    ),
                    _percentageField(
                      'Channel Partner 2 (%)',
                      formState.cp2.percentage,
                      (v) {
                        setState(() => formState = formState.copyWith(
                              cp2: formState.cp2.copyWith(percentage: v),
                            ));
                        _recalculate(fromAdditionalCost: true);
                      },
                    ),
                    _percentageField(
                      'AMC (%)',
                      formState.amc.percentage,
                      (v) {
                        setState(() => formState = formState.copyWith(
                              amc: formState.amc.copyWith(percentage: v),
                            ));
                        _recalculate(fromAdditionalCost: true);
                      },
                    ),

                    if (!isProjectCalculated) ...[
                      const SizedBox(height: 16),
                      const Text(
                        '⚠ Complete all system components to calculate project cost',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Widget helpers ────────────────────────────────────────────────────────

  Widget _buildSummary() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen.withValues(alpha: 0.18),
            AppColors.primaryGreen.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _summaryRow('Project Cost (Before GST)', costingResult.grandTotal,
              highlight: true),
          _summaryRow('Project Cost (After GST)',
              costingResult.projectCostAfterGst,
              highlight: true),
          const Divider(),
          _summaryRow('₹ / Wp (Before GST)', costingResult.perWpBeforeGst),
          _summaryRow('₹ / Wp (After GST)', costingResult.perWpAfterGst),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight:
                      highlight ? FontWeight.w600 : FontWeight.normal)),
          Text(
            '₹ ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: highlight ? 18 : 14,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _percentageField(
    String label,
    double value,
    void Function(double) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
        controller: TextEditingController(text: value.toString()),
        onChanged: (v) => onChanged(double.tryParse(v) ?? 0),
      ),
    );
  }
}
