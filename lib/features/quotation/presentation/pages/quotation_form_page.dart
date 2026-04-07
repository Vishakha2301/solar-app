import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/quotation_store.dart';
import '../../domain/models/quotation.dart';
import '../../../customer/domain/models/customer.dart';
import '../../../customer/domain/models/customer_site.dart';
import '../../../customer/presentation/state/customer_store.dart';
import '../../../costing/domain/models/saved_costing.dart';
import '../../../costing/presentation/state/costing_store.dart';
import '../../../material/domain/models/material_item.dart';
import '../../../material/presentation/state/material_store.dart';

class QuotationFormPage extends StatefulWidget {
  final Quotation? existingQuotation;

  const QuotationFormPage({super.key, this.existingQuotation});

  @override
  State<QuotationFormPage> createState() => _QuotationFormPageState();
}

class _QuotationFormPageState extends State<QuotationFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Step tracking
  int _currentStep = 0;

  // Step 1 — Customer
  Customer? _selectedCustomer;
  CustomerSite? _selectedSite;

  // Step 2 — Costing
  final List<_CostingSelection> _costingSelections = [];

  // Step 3 — Components
  String? _systemType;
  MaterialItem? _panelMaterial;
  MaterialItem? _inverterMaterial;
  MaterialItem? _cableMaterial;

  // Step 4 — Terms
  final _scopeController = TextEditingController();
  final _paymentTermsController = TextEditingController();
  final _termsController = TextEditingController();
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
    _selectedCustomer = q.customer;
    _selectedSite = q.customerSite;
    _systemType = q.systemType;
    _scopeController.text = q.scopeOfWork ?? '';
    _paymentTermsController.text = q.paymentTerms ?? '';
    _termsController.text = q.termsAndConditions ?? '';
    _notesController.text = q.notes ?? '';
    _validityController.text = q.validityDays.toString();
    _discountController.text = q.discount.toString();
    _financingAvailable = q.financingAvailable;
    _financingRateController.text = q.financingRate?.toString() ?? '';
    _costingSelections.addAll(q.costings.map((c) => _CostingSelection(
          costingId: c.costingId,
          roofLabel: c.roofLabel ?? '',
        )));
    _instalments.addAll(q.instalments.map((i) => _InstalmentRow(
          description: i.description,
          percentage: i.percentage.toString(),
        )));
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
    _scopeController.dispose();
    _paymentTermsController.dispose();
    _termsController.dispose();
    _notesController.dispose();
    _validityController.dispose();
    _discountController.dispose();
    _financingRateController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomer == null) {
      _showError('Please select a customer');
      return;
    }
    if (_costingSelections.isEmpty) {
      _showError('Please select at least one costing');
      return;
    }

    setState(() => _isSaving = true);

    // Build packages from selected materials
    final packages = <Map<String, dynamic>>[];
    final materials = <Map<String, dynamic>>[];
    if (_panelMaterial != null) {
      materials.add({
        'materialId': _panelMaterial!.id,
        'componentKey': 'solarPanel',
        'isRecommended': true,
      });
    }
    if (_inverterMaterial != null) {
      materials.add({
        'materialId': _inverterMaterial!.id,
        'componentKey': 'invertor',
        'isRecommended': true,
      });
    }
    if (_cableMaterial != null) {
      materials.add({
        'materialId': _cableMaterial!.id,
        'componentKey': 'dcCable',
        'isRecommended': true,
      });
    }
    if (materials.isNotEmpty) {
      packages.add({
        'packageName': 'Standard',
        'isRecommended': true,
        'materials': materials,
      });
    }

    final request = {
      'customerId': _selectedCustomer!.id,
      'customerSiteId': _selectedSite?.id,
      'systemType': _systemType,
      'validityDays': int.tryParse(_validityController.text) ?? 30,
      'discount': double.tryParse(_discountController.text) ?? 0,
      'scopeOfWork': _scopeController.text.trim().isEmpty
          ? null
          : _scopeController.text.trim(),
      'paymentTerms': _paymentTermsController.text.trim().isEmpty
          ? null
          : _paymentTermsController.text.trim(),
      'termsAndConditions': _termsController.text.trim().isEmpty
          ? null
          : _termsController.text.trim(),
      'notes': _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      'financingAvailable': _financingAvailable,
      'financingRate': _financingAvailable &&
              _financingRateController.text.isNotEmpty
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

    return Step(
      title: const Text('Customer'),
      subtitle: _selectedCustomer != null
          ? Text(_selectedCustomer!.displayName)
          : null,
      isActive: _currentStep >= 0,
      state: _selectedCustomer != null
          ? StepState.complete
          : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<Customer>(
            value: _selectedCustomer,
            decoration: const InputDecoration(
              labelText: 'Select Customer *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            items: customerStore.customers
                .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c.displayName),
                    ))
                .toList(),
            onChanged: (value) => setState(() {
              _selectedCustomer = value;
              _selectedSite = value?.sites.isNotEmpty == true
                  ? value!.sites.firstWhere(
                      (s) => s.isDefault,
                      orElse: () => value.sites.first,
                    )
                  : null;
            }),
            validator: (v) => v == null ? 'Required' : null,
          ),
          if (_selectedCustomer != null &&
              _selectedCustomer!.sites.isNotEmpty) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<CustomerSite>(
              value: _selectedSite,
              decoration: const InputDecoration(
                labelText: 'Installation Site',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              items: _selectedCustomer!.sites
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.siteLabel),
                      ))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _selectedSite = value),
            ),
          ],
        ],
      ),
    );
  }

  Step _buildCostingStep() {
    final costingStore = context.watch<CostingStore>();

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
                          '${c.context.roofIdentifier} — ${c.context.plantCapacity} kWp'),
                    ))
                .toList(),
            onChanged: (costing) {
              if (costing == null) return;
              if (_costingSelections
                  .any((c) => c.costingId == costing.id)) return;
              setState(() {
                _costingSelections.add(_CostingSelection(
                  costingId: costing.id,
                  roofLabel: costing.context.roofIdentifier,
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
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(selection.roofLabel.isEmpty
                    ? 'Costing ${index + 1}'
                    : selection.roofLabel),
                subtitle: Text(selection.costingId,
                    style: const TextStyle(fontSize: 11)),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                      color: Colors.red),
                  onPressed: () => setState(
                      () => _costingSelections.removeAt(index)),
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

    return Step(
      title: const Text('Components'),
      subtitle: const Text('Select brands (optional)'),
      isActive: _currentStep >= 2,
      state: StepState.indexed,
      content: Column(
        children: [
          DropdownButtonFormField<MaterialItem>(
            value: _panelMaterial,
            decoration: const InputDecoration(
              labelText: 'Solar Panel Brand',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.solar_power),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('— None —')),
              ...panels.map((m) => DropdownMenuItem(
                    value: m,
                    child: Text('${m.brandName} ${m.modelName}'),
                  )),
            ],
            onChanged: (v) => setState(() => _panelMaterial = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<MaterialItem>(
            value: _inverterMaterial,
            decoration: const InputDecoration(
              labelText: 'Inverter Brand',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.electric_bolt),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('— None —')),
              ...inverters.map((m) => DropdownMenuItem(
                    value: m,
                    child: Text('${m.brandName} ${m.modelName}'),
                  )),
            ],
            onChanged: (v) => setState(() => _inverterMaterial = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<MaterialItem>(
            value: _cableMaterial,
            decoration: const InputDecoration(
              labelText: 'Cable Brand',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.cable),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('— None —')),
              ...cables.map((m) => DropdownMenuItem(
                    value: m,
                    child: Text('${m.brandName} ${m.modelName}'),
                  )),
            ],
            onChanged: (v) => setState(() => _cableMaterial = v),
          ),
        ],
      ),
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
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _validityController,
                  decoration: const InputDecoration(
                    labelText: 'Validity (days)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _discountController,
                  decoration: const InputDecoration(
                    labelText: 'Discount (₹)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Financing Available'),
            value: _financingAvailable,
            onChanged: (v) => setState(() => _financingAvailable = v),
            contentPadding: EdgeInsets.zero,
          ),
          if (_financingAvailable) ...[
            TextFormField(
              controller: _financingRateController,
              decoration: const InputDecoration(
                labelText: 'Interest Rate (%)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
          ],
          TextFormField(
            controller: _scopeController,
            decoration: const InputDecoration(
              labelText: 'Scope of Work',
              hintText:
                  'e.g. System Design, Installation, Net Metering, 5 Years AMC',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _termsController,
            decoration: const InputDecoration(
              labelText: 'Terms & Conditions',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Payment Instalments',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              TextButton.icon(
                onPressed: () => setState(() =>
                    _instalments.add(_InstalmentRow())),
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
                  Expanded(
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

  _CostingSelection({required this.costingId, required this.roofLabel});
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
