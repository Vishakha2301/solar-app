import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/material_store.dart';
import '../../domain/models/material_item.dart';

class MaterialFormPage extends StatefulWidget {
  final MaterialItem? existingMaterial;

  const MaterialFormPage({super.key, this.existingMaterial});

  @override
  State<MaterialFormPage> createState() => _MaterialFormPageState();
}

class _MaterialFormPageState extends State<MaterialFormPage> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCategory;
  final _componentKeyController = TextEditingController();
  final _brandNameController = TextEditingController();
  final _modelNameController = TextEditingController();
  final _specificationController = TextEditingController();
  final _unitController = TextEditingController();
  final _warrantyController = TextEditingController();
  final _hsnCodeController = TextEditingController();
  bool _isSaving = false;

  bool get isEditing => widget.existingMaterial != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final m = widget.existingMaterial!;
      _selectedCategory = m.category.value;
      _componentKeyController.text = m.componentKey ?? '';
      _brandNameController.text = m.brandName;
      _modelNameController.text = m.modelName;
      _specificationController.text = m.specification ?? '';
      _unitController.text = m.unit ?? '';
      _warrantyController.text = m.warranty ?? '';
      _hsnCodeController.text = m.hsnCode ?? '';
    }
  }

  @override
  void dispose() {
    _componentKeyController.dispose();
    _brandNameController.dispose();
    _modelNameController.dispose();
    _specificationController.dispose();
    _unitController.dispose();
    _warrantyController.dispose();
    _hsnCodeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final request = {
      'category': _selectedCategory,
      'componentKey': _componentKeyController.text.trim().isEmpty
          ? null
          : _componentKeyController.text.trim(),
      'brandName': _brandNameController.text.trim(),
      'modelName': _modelNameController.text.trim(),
      'specification': _specificationController.text.trim().isEmpty
          ? null
          : _specificationController.text.trim(),
      'unit': _unitController.text.trim().isEmpty
          ? null
          : _unitController.text.trim(),
      'warranty': _warrantyController.text.trim().isEmpty
          ? null
          : _warrantyController.text.trim(),
      'hsnCode': _hsnCodeController.text.trim().isEmpty
          ? null
          : _hsnCodeController.text.trim(),
    };

    try {
      final store = context.read<MaterialStore>();
      if (isEditing) {
        await store.update(widget.existingMaterial!.id, request);
      } else {
        await store.create(request);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<MaterialStore>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Material' : 'Add Material'),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            onPressed: _isSaving ? null : _save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Category'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: store.categories
                    .map((cat) => DropdownMenuItem(
                          value: cat.value,
                          child: Text(cat.label),
                        ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedCategory = value),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _componentKeyController,
                decoration: const InputDecoration(
                  labelText: 'Component Key',
                  hintText: 'e.g. solarPanel, inverter, cable',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.key_outlined),
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle('Brand & Model'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _brandNameController,
                decoration: const InputDecoration(
                  labelText: 'Brand Name *',
                  hintText: 'e.g. Adani, Waaree, Growatt',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.branding_watermark_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _modelNameController,
                decoration: const InputDecoration(
                  labelText: 'Model Name *',
                  hintText: 'e.g. 545W Bifacial TOPCon',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.model_training_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _specificationController,
                decoration: const InputDecoration(
                  labelText: 'Specification',
                  hintText: 'e.g. Mono/Bifacial, 18 panels',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              _sectionTitle('Additional Details'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        hintText: 'e.g. Wp, Nos, Mtr',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _hsnCodeController,
                      decoration: const InputDecoration(
                        labelText: 'HSN Code',
                        hintText: 'e.g. 8541.40',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _warrantyController,
                decoration: const InputDecoration(
                  labelText: 'Warranty',
                  hintText: 'e.g. 10 years product, 25 years performance',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.verified_outlined),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}