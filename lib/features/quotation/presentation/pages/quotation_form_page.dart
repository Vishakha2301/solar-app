import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/quotation_store.dart';
import '../../domain/models/quotation.dart';
import '../../../customer/domain/models/customer.dart';
import '../../../customer/presentation/state/customer_store.dart';
import '../../../customer/presentation/pages/customer_form_page.dart';
import '../../../costing/domain/models/saved_costing.dart';
import '../../../costing/presentation/state/costing_store.dart';
import '../../../material/domain/models/material_item.dart';
import '../../../material/presentation/state/material_store.dart';
import '../../../material/presentation/pages/material_form_page.dart';

class QuotationFormPage extends StatefulWidget {
  final Quotation? existingQuotation;

  const QuotationFormPage({super.key, this.existingQuotation});

  @override
  State<QuotationFormPage> createState() => _QuotationFormPageState();
}

class _QuotationFormPageState extends State<QuotationFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  int _currentStep = 0;

  // Step 1 — Customer — stored as IDs only
  String? _selectedCustomerId;
  String? _selectedSiteId;

  // Step 2 — Costing
  final List<_CostingSelection> _costingSelections = [];

  // Step 3 — Components — stored as IDs only
  String? _systemType;
  String? _panelMaterialId;
  String? _inverterMaterialId;
  String? _cableMaterialId;

  // Step 4 — Terms
  final _notesController = TextEditingController();
  final _validityController = TextEditingController(text: '30');
  final _discountController = TextEditingController(text: '0');
  bool _financingAvailable = false;
  final _financingRateController = TextEditingController();
  final List<_InstalmentRow> _instalments = [];

  bool get isEditing => widget.existingQuotation != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerStore>().loadAll();
      context.read<CostingStore>().loadAll();
      context.read<MaterialStore>().loadAll();
    });

    if (isEditing) {
      _populateFromExisting();
    } else {
      _addDefaultInstalments();
    }
  }

  void _populateFromExisting() {
    final q = widget.existingQuotation!;
    _selectedCustomerId = q.customer.id;
    _selectedSiteId = q.customerSite?.id;
    _systemType = q.systemType;
    _notesController.text = q.notes ?? '';
    _validityController.text = q.validityDays.toString();
    _discountController.text = q.discount.toString();
    _financingAvailable = q.financingAvailable;
    _financingRateController.text = q.financingRate?.toString() ?? '';

    _costingSelections.addAll(q.costings.map((c) => _CostingSelection(
      costingId: c.costingId,
      roofLabel: c.roofLabel ?? '',
      displayLabel: '',
      isSubsidyProject: false, // resolved later from costing store
      subsidyAmount: c.subsidyAmount.toStringAsFixed(0),
    )));

    _instalments.addAll(q.instalments.map((i) => _InstalmentRow(
          description: i.description,
          percentage: i.percentage.toString(),
        )));

    for (final pkg in q.packages) {
      for (final m in pkg.materials) {
        if (m.componentKey == 'solarPanel') {
          _panelMaterialId = m.material.id;
        } else if (m.componentKey == 'invertor') {
          _inverterMaterialId = m.material.id;
        } else if (m.componentKey == 'dcCable') {
          _cableMaterialId = m.material.id;
        }
      }
    }
  }

  void _addDefaultInstalments() {
    _instalments.addAll([
      _InstalmentRow(description: 'Advance', percentage: '10'),
      _InstalmentRow(description: 'Procurement', percentage: '60'),
      _InstalmentRow(description: 'On Installation', percentage: '10'),
      _InstalmentRow(description: 'Net Metering', percentage: '20'),
    ]);
  }

  @override
  void dispose() {
    _notesController.dispose();
    _validityController.dispose();
    _discountController.dispose();
    _financingRateController.dispose();
    super.dispose();
  }

  Customer? _resolveCustomer(List<Customer> customers) =>
      customers.where((c) => c.id == _selectedCustomerId).firstOrNull;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomerId == null) {
      _showError('Please select a customer');
      return;
    }
    if (_costingSelections.isEmpty) {
      _showError('Please select at least one costing');
      return;
    }

    setState(() => _isSaving = true);

    final materials = <Map<String, dynamic>>[];
    if (_panelMaterialId != null) {
      materials.add({
        'materialId': _panelMaterialId,
        'componentKey': 'solarPanel',
        'isRecommended': true,
      });
    }
    if (_inverterMaterialId != null) {
      materials.add({
        'materialId': _inverterMaterialId,
        'componentKey': 'invertor',
        'isRecommended': true,
      });
    }
    if (_cableMaterialId != null) {
      materials.add({
        'materialId': _cableMaterialId,
        'componentKey': 'dcCable',
        'isRecommended': true,
      });
    }

    final packages = <Map<String, dynamic>>[];
    if (materials.isNotEmpty) {
      packages.add({
        'packageName': 'Standard',
        'isRecommended': true,
        'materials': materials,
      });
    }

    final request = {
      'customerId': _selectedCustomerId,
      'customerSiteId': _selectedSiteId,
      'systemType': _systemType,
      'validityDays': int.tryParse(_validityController.text) ?? 30,
      'discount': double.tryParse(_discountController.text) ?? 0,
      'notes': _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      'financingAvailable': _financingAvailable,
      'financingRate':
          _financingAvailable && _financingRateController.text.isNotEmpty
              ? double.tryParse(_financingRateController.text)
              : null,
      'costings': _costingSelections
          .map((c) => {
                'costingId': c.costingId,
                'roofLabel': c.roofLabel.isEmpty ? null : c.roofLabel,
              })
          .toList(),
      'instalments': _instalments
          .asMap()
          .entries
          .map((e) => {
                'instalmentNo': e.key + 1,
                'description': e.value.descriptionController.text.trim(),
                'percentage':
                    double.tryParse(e.value.percentageController.text) ?? 0,
              })
          .toList(),
      'packages': packages,
    };

    try {
      final store = context.read<QuotationStore>();
      if (isEditing) {
        await store.update(widget.existingQuotation!.id, request);
      } else {
        await store.create(request);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) _showError('Save failed: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Quotation' : 'New Quotation'),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save, color: Colors.white),
            label: const Text('Save',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepTapped: (step) => setState(() => _currentStep = step),
          onStepContinue: () {
            if (_currentStep < 3) {
              setState(() => _currentStep++);
            } else {
              _save();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) setState(() => _currentStep--);
          },
          steps: [
            _buildCustomerStep(),
            _buildCostingStep(),
            _buildComponentsStep(),
            _buildTermsStep(),
          ],
        ),
      ),
    );
  }

  Step _buildCustomerStep() {
    final customerStore = context.watch<CustomerStore>();
    final resolvedCustomer = _resolveCustomer(customerStore.customers);

    return Step(
      title: const Text('Customer'),
      subtitle: resolvedCustomer != null
          ? Text(resolvedCustomer.displayName)
          : null,
      isActive: _currentStep >= 0,
      state: resolvedCustomer != null
          ? StepState.complete
          : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: customerStore.customers
                          .any((c) => c.id == _selectedCustomerId)
                      ? _selectedCustomerId
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Select Customer *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  items: customerStore.customers
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.displayName),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() {
                    _selectedCustomerId = value;
                    final customer = customerStore.customers
                        .where((c) => c.id == value)
                        .firstOrNull;
                    _selectedSiteId =
                        customer?.sites.isNotEmpty == true
                            ? (customer!.sites
                                    .where((s) => s.isDefault)
                                    .firstOrNull
                                    ?.id ??
                                customer.sites.first.id)
                            : null;
                  }),
                  validator: (v) => v == null ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Add New Customer',
                icon: const Icon(Icons.person_add_outlined),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context)
                      .primaryColor
                      .withValues(alpha: 0.1),
                ),
                onPressed: () async {
                  final customerStore = context.read<CustomerStore>();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CustomerFormPage()),
                  );
                  if (mounted) {
                    await customerStore.loadAll();
                  }
                },
              ),
            ],
          ),
          if (resolvedCustomer != null &&
              resolvedCustomer.sites.isNotEmpty) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: resolvedCustomer.sites
                      .any((s) => s.id == _selectedSiteId)
                  ? _selectedSiteId
                  : null,
              decoration: const InputDecoration(
                labelText: 'Installation Site',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              items: resolvedCustomer.sites
                  .map((s) => DropdownMenuItem(
                        value: s.id,
                        child: Text(s.siteLabel),
                      ))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _selectedSiteId = value),
            ),
          ],
        ],
      ),
    );
  }

  Step _buildCostingStep() {
    final costingStore = context.watch<CostingStore>();

    // Resolve display labels and subsidy flag from loaded costings
    for (final selection in _costingSelections) {
      final match = costingStore.costings
          .where((c) => c.id == selection.costingId)
          .firstOrNull;
      if (match != null) {
        if (selection.displayLabel.isEmpty) {
          selection.displayLabel =
              '${match.context.roofIdentifier} — '
              '${match.context.plantCapacity} kWp — '
              '₹${match.snapshot.grandTotal.toStringAsFixed(0)}';
        }
        // Update subsidy flag from loaded costing
        if (match.context.isSubsidyProject != selection.isSubsidyProject) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() {});
          });
        }
      }
    }

    return Step(
      title: const Text('Costing'),
      subtitle: _costingSelections.isNotEmpty
          ? Text('${_costingSelections.length} selected')
          : null,
      isActive: _currentStep >= 1,
      state: _costingSelections.isNotEmpty
          ? StepState.complete
          : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<SavedCosting>(
            decoration: const InputDecoration(
              labelText: 'Add Costing *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calculate_outlined),
            ),
            items: costingStore.costings
                .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(
                        '${c.context.roofIdentifier} — '
                        '${c.context.plantCapacity} kWp — '
                        '₹${c.snapshot.grandTotal.toStringAsFixed(0)}'
                        '${c.context.isSubsidyProject ? ' 🏛 Subsidy' : ''}',
                      ),
                    ))
                .toList(),
            onChanged: (costing) {
              if (costing == null) return;
              if (_costingSelections
                  .any((c) => c.costingId == costing.id)) {
                return;
              }
              setState(() {
                _costingSelections.add(_CostingSelection(
                  costingId: costing.id,
                  roofLabel: costing.context.roofIdentifier,
                  displayLabel:
                      '${costing.context.roofIdentifier} — '
                      '${costing.context.plantCapacity} kWp — '
                      '₹${costing.snapshot.grandTotal.toStringAsFixed(0)}',
                  isSubsidyProject: costing.context.isSubsidyProject,
                ));
                _systemType ??=
                    '${costing.context.systemType} ${costing.context.plantCapacity}KW';
              });
            },
          ),
          const SizedBox(height: 12),
          ..._costingSelections.asMap().entries.map((entry) {
            final index = entry.key;
            final selection = entry.value;

            // Resolve isSubsidyProject from loaded costings
            final match = costingStore.costings
                .where((c) => c.id == selection.costingId)
                .firstOrNull;
            final isSubsidy = match?.context.isSubsidyProject ?? selection.isSubsidyProject;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calculate_outlined,
                            color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selection.displayLabel.isNotEmpty
                                ? selection.displayLabel
                                : selection.roofLabel.isNotEmpty
                                    ? selection.roofLabel
                                    : 'Costing ${index + 1}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        if (isSubsidy)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.blue.shade200),
                            ),
                            child: const Text(
                              'Subsidy',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.blue),
                            ),
                          ),
                        IconButton(
                          icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.red),
                          onPressed: () => setState(
                              () => _costingSelections.removeAt(index)),
                        ),
                      ],
                    ),
                    if (isSubsidy) ...[
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: selection.subsidyController,
                        decoration: const InputDecoration(
                          labelText: 'Subsidy Amount',
                          hintText: 'e.g. 78000',
                          border: OutlineInputBorder(),
                          prefixText: '₹ ',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _systemType,
            decoration: const InputDecoration(
              labelText: 'System Type',
              hintText: 'e.g. ONGRID 5KW',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => _systemType = v,
          ),
        ],
      ),
    );
  }
  
  Step _buildComponentsStep() {
    final materialStore = context.watch<MaterialStore>();

    final panels = materialStore.materials
        .where((m) => m.category.value == 'PANEL')
        .toList();
    final inverters = materialStore.materials
        .where((m) => m.category.value == 'INVERTER')
        .toList();
    final cables = materialStore.materials
        .where((m) => m.category.value == 'CABLE')
        .toList();

    final panelValue =
        panels.where((m) => m.id == _panelMaterialId).firstOrNull;
    final inverterValue =
        inverters.where((m) => m.id == _inverterMaterialId).firstOrNull;
    final cableValue =
        cables.where((m) => m.id == _cableMaterialId).firstOrNull;

    return Step(
      title: const Text('Components'),
      subtitle: const Text('Select brands (optional)'),
      isActive: _currentStep >= 2,
      state: StepState.indexed,
      content: Column(
        children: [
          _materialDropdown(
            label: 'Solar Panel Brand',
            icon: Icons.solar_power,
            items: panels,
            value: panelValue,
            onChanged: (v) =>
                setState(() => _panelMaterialId = v?.id),
            onAdd: () async {
              final materialStore = context.read<MaterialStore>();
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const MaterialFormPage()),
              );
              if (mounted) {
                await materialStore.loadAll();
              }
            },
          ),
          const SizedBox(height: 12),
          _materialDropdown(
            label: 'Inverter Brand',
            icon: Icons.electric_bolt,
            items: inverters,
            value: inverterValue,
            onChanged: (v) =>
                setState(() => _inverterMaterialId = v?.id),
            onAdd: () async {
              final materialStore = context.read<MaterialStore>();
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const MaterialFormPage()),
              );
              if (mounted) {
                await materialStore.loadAll();
              }
            },
          ),
          const SizedBox(height: 12),
          _materialDropdown(
            label: 'Cable Brand',
            icon: Icons.cable,
            items: cables,
            value: cableValue,
            onChanged: (v) =>
                setState(() => _cableMaterialId = v?.id),
            onAdd: () async {
              final materialStore = context.read<MaterialStore>();
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const MaterialFormPage()),
              );
              if (mounted) {
                await materialStore.loadAll();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _materialDropdown({
    required String label,
    required IconData icon,
    required List<MaterialItem> items,
    required MaterialItem? value,
    required ValueChanged<MaterialItem?> onChanged,
    required VoidCallback onAdd,
  }) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<MaterialItem>(
            value: value,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              prefixIcon: Icon(icon),
            ),
            items: [
              const DropdownMenuItem(
                  value: null, child: Text('— None —')),
              ...items.map((m) => DropdownMenuItem(
                    value: m,
                    child: Text('${m.brandName} ${m.modelName}'),
                  )),
            ],
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'Add New Material',
          icon: const Icon(Icons.add_circle_outline),
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context)
                .primaryColor
                .withValues(alpha: 0.1),
          ),
          onPressed: onAdd,
        ),
      ],
    );
  }

  Step _buildTermsStep() {
    return Step(
      title: const Text('Terms & Payment'),
      isActive: _currentStep >= 3,
      state: StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _validityController,
                    decoration: const InputDecoration(
                      labelText: 'Validity',
                      border: OutlineInputBorder(),
                      suffixText: 'days',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _discountController,
                    decoration: const InputDecoration(
                      labelText: 'Discount',
                      border: OutlineInputBorder(),
                      prefixText: '₹ ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Financing Available'),
            value: _financingAvailable,
            onChanged: (v) =>
                setState(() => _financingAvailable = v),
            contentPadding: EdgeInsets.zero,
          ),
          if (_financingAvailable) ...[
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: TextFormField(
                controller: _financingRateController,
                decoration: const InputDecoration(
                  labelText: 'Interest Rate',
                  border: OutlineInputBorder(),
                  suffixText: '%',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 12),
          ],
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes',
              hintText: 'Any additional notes for this quotation',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Payment Instalments',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15),
              ),
              TextButton.icon(
                onPressed: () => setState(
                    () => _instalments.add(_InstalmentRow())),
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._instalments.asMap().entries.map((entry) {
            final index = entry.key;
            final row = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: row.descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: TextFormField(
                      controller: row.percentageController,
                      decoration: const InputDecoration(
                        labelText: '%',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.red),
                    onPressed: _instalments.length > 1
                        ? () => setState(
                            () => _instalments.removeAt(index))
                        : null,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CostingSelection {
  final String costingId;
  final String roofLabel;
  String displayLabel;
  final bool isSubsidyProject;
  final TextEditingController subsidyController;

  _CostingSelection({
    required this.costingId,
    required this.roofLabel,
    this.displayLabel = '',
    this.isSubsidyProject = false,
    String subsidyAmount = '0',
  }) : subsidyController = TextEditingController(text: subsidyAmount);
}

class _InstalmentRow {
  final TextEditingController descriptionController;
  final TextEditingController percentageController;

  _InstalmentRow({String description = '', String percentage = ''})
      : descriptionController =
            TextEditingController(text: description),
        percentageController =
            TextEditingController(text: percentage);
}
