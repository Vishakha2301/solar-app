import 'package:flutter/material.dart';
import '../../../costing/domain/models/component_cost.dart';
import '../state/quotation_form_state.dart';

/// Only the solar panel has an editable numeric panel capacity (Wp).
bool _isCapacityEditable(String key) => key == 'solarPanel';

/// Cable components have an editable specification string.
bool _isSpecificationEditable(String key) => const {
      'acArmouredCable',
      'acFlexibleCable',
      'dcCable',
      'acEarthingCable',
    }.contains(key);

class EditComponentSheet extends StatefulWidget {
  final String componentKey;
  final ComponentCost component;

  /// Current form input (already-edited values).
  final ComponentFormInput formInput;

  /// Initial/default form input (from QuotationFormState.initial).
  final ComponentFormInput initialFormInput;

  final void Function({
    required double quantity,
    required double unitPrice,
    double? panelCapacityWp,
    String? specification,
  }) onSave;

  const EditComponentSheet({
    super.key,
    required this.componentKey,
    required this.component,
    required this.formInput,
    required this.initialFormInput,
    required this.onSave,
  });

  @override
  State<EditComponentSheet> createState() => _EditComponentSheetState();
}

class _EditComponentSheetState extends State<EditComponentSheet> {
  late TextEditingController quantityController;
  late TextEditingController priceController;
  TextEditingController? capacityController;
  TextEditingController? specificationController;

  bool get showCapacity => _isCapacityEditable(widget.componentKey);
  bool get showSpecification => _isSpecificationEditable(widget.componentKey);

  @override
  void initState() {
    super.initState();

    quantityController = TextEditingController(
      text: widget.formInput.quantity.toString(),
    );
    priceController = TextEditingController(
      text: widget.formInput.unitPrice.toString(),  // ← was basePrice
    );

    if (showCapacity) {
      capacityController = TextEditingController(
        text: widget.formInput.panelCapacityWp > 0   // ← was capacity
            ? widget.formInput.panelCapacityWp.toString()
            : '',
      );
    }

    if (showSpecification) {
      specificationController = TextEditingController(
        text: widget.formInput.specification ?? '',
      );
    }
  }

  @override
  void dispose() {
    quantityController.dispose();
    priceController.dispose();
    capacityController?.dispose();
    specificationController?.dispose();
    super.dispose();
  }

  // ── Change detection ───────────────────────────────────────────────────────

  bool _hasChanges() {
    final qtyChanged =
        quantityController.text != widget.formInput.quantity.toString();
    final priceChanged =
        priceController.text != widget.formInput.unitPrice.toString();
    final capacityChanged = showCapacity
        ? capacityController!.text != widget.formInput.panelCapacityWp.toString()
        : false;
    final specChanged = showSpecification
        ? specificationController!.text != (widget.formInput.specification ?? '')
        : false;

    return qtyChanged || priceChanged || capacityChanged || specChanged;
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  Future<bool> _confirmDiscard() async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Discard Changes?'),
            content: const Text(
                'You have unsaved changes. Do you want to discard them?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _confirmReset() async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Reset Component?'),
            content: const Text(
                'This will revert values to default quotation settings. Continue?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Reset'),
              ),
            ],
          ),
        ) ??
        false;
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void _onSave() {
    final qty = double.tryParse(quantityController.text) ?? 0;
    final price = double.tryParse(priceController.text) ?? 0;

    widget.onSave(
      quantity: qty,
      unitPrice: price,
      panelCapacityWp: showCapacity        // ← was capacity
          ? double.tryParse(capacityController!.text)
          : null,
      specification:
          showSpecification ? specificationController!.text : null,
    );

    Navigator.pop(context);
  }

  Future<void> _onCancel() async {
    if (_hasChanges()) {
      final discard = await _confirmDiscard();
      if (!mounted) return;
      if (!discard) return;
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _onReset() async {
    final confirm = await _confirmReset();
    if (!mounted) return;
    if (!confirm) return;

    setState(() {
      quantityController.text = widget.initialFormInput.quantity.toString();
      priceController.text = widget.initialFormInput.unitPrice.toString();  // ← was basePrice

      if (capacityController != null) {
        capacityController!.text =
            widget.initialFormInput.panelCapacityWp > 0    // ← was capacity
                ? widget.initialFormInput.panelCapacityWp.toString()
                : '';
      }
      if (specificationController != null) {
        specificationController!.text =
            widget.initialFormInput.specification ?? '';
      }
    });
  }

  // ── UI ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _onCancel();
      },
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit ${widget.component.name}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),

              if (showCapacity) ...[
                TextField(
                  controller: capacityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Panel Capacity (Wp)',
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (showSpecification) ...[
                TextField(
                  controller: specificationController,
                  decoration: const InputDecoration(
                    labelText: 'Specification',
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Unit Price'),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _onCancel,
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _onReset,
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onSave,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
