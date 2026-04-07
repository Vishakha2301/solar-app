import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/customer_store.dart';
import '../../domain/models/customer.dart';
import '../../domain/models/customer_site.dart';

class CustomerFormPage extends StatefulWidget {
  final Customer? existingCustomer;

  const CustomerFormPage({super.key, this.existingCustomer});

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();

  CustomerType _customerType = CustomerType.INDIVIDUAL;
  final _nameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _gstController = TextEditingController();

  final List<_SiteFormData> _sites = [];
  bool _isSaving = false;

  bool get isEditing => widget.existingCustomer != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final c = widget.existingCustomer!;
      _customerType = c.customerType;
      _nameController.text = c.name;
      _companyNameController.text = c.companyName ?? '';
      _phoneController.text = c.phone;
      _emailController.text = c.email ?? '';
      _addressController.text = c.address ?? '';
      _cityController.text = c.city ?? '';
      _stateController.text = c.state ?? '';
      _pincodeController.text = c.pincode ?? '';
      _gstController.text = c.gstNumber ?? '';
      _sites.addAll(c.sites.map((s) => _SiteFormData.fromSite(s)));
    } else {
      _sites.add(_SiteFormData());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final request = {
      'customerType': _customerType.name,
      'name': _nameController.text.trim(),
      'companyName': _companyNameController.text.trim().isEmpty
          ? null
          : _companyNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      'address': _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      'city': _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      'state': _stateController.text.trim().isEmpty
          ? null
          : _stateController.text.trim(),
      'pincode': _pincodeController.text.trim().isEmpty
          ? null
          : _pincodeController.text.trim(),
      'gstNumber': _gstController.text.trim().isEmpty
          ? null
          : _gstController.text.trim(),
      'sites': _sites
          .where((s) => s.siteLabelController.text.trim().isNotEmpty)
          .map((s) => s.toJson())
          .toList(),
    };

    try {
      final store = context.read<CustomerStore>();
      if (isEditing) {
        await store.update(widget.existingCustomer!.id, request);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Customer' : 'Add Customer'),
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
              _sectionTitle('Customer Type'),
              const SizedBox(height: 8),
              SegmentedButton<CustomerType>(
                segments: const [
                  ButtonSegment(
                    value: CustomerType.INDIVIDUAL,
                    label: Text('Individual'),
                    icon: Icon(Icons.person),
                  ),
                  ButtonSegment(
                    value: CustomerType.COMPANY,
                    label: Text('Company'),
                    icon: Icon(Icons.business),
                  ),
                  ButtonSegment(
                    value: CustomerType.SOCIETY,
                    label: Text('Society'),
                    icon: Icon(Icons.apartment),
                  ),
                ],
                selected: {_customerType},
                onSelectionChanged: (value) =>
                    setState(() => _customerType = value.first),
              ),
              const SizedBox(height: 24),
              _sectionTitle('Basic Information'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              if (_customerType != CustomerType.INDIVIDUAL) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _companyNameController,
                  decoration: InputDecoration(
                    labelText: _customerType == CustomerType.COMPANY
                        ? 'Company Name'
                        : 'Society Name',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.business_outlined),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _gstController,
                decoration: const InputDecoration(
                  labelText: 'GST Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.receipt_outlined),
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle('Address'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Street Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(
                        labelText: 'State',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 120,
                    child: TextFormField(
                      controller: _pincodeController,
                      decoration: const InputDecoration(
                        labelText: 'Pincode',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionTitle('Installation Sites'),
                  TextButton.icon(
                    onPressed: () =>
                        setState(() => _sites.add(_SiteFormData())),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Site'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._sites.asMap().entries.map((entry) {
                final index = entry.key;
                final site = entry.value;
                return _SiteFormCard(
                  index: index,
                  site: site,
                  onRemove: _sites.length > 1
                      ? () => setState(() => _sites.removeAt(index))
                      : null,
                  onSetDefault: () {
                    setState(() {
                      for (var s in _sites) {
                        s.isDefault = false;
                      }
                      site.isDefault = true;
                    });
                  },
                );
              }),
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

class _SiteFormData {
  final TextEditingController siteLabelController;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController pincodeController;
  bool isDefault;

  _SiteFormData({
    String siteLabel = '',
    String address = '',
    String city = '',
    String state = '',
    String pincode = '',
    this.isDefault = false,
  })  : siteLabelController = TextEditingController(text: siteLabel),
        addressController = TextEditingController(text: address),
        cityController = TextEditingController(text: city),
        stateController = TextEditingController(text: state),
        pincodeController = TextEditingController(text: pincode);

  factory _SiteFormData.fromSite(CustomerSite site) => _SiteFormData(
        siteLabel: site.siteLabel,
        address: site.address ?? '',
        city: site.city ?? '',
        state: site.state ?? '',
        pincode: site.pincode ?? '',
        isDefault: site.isDefault,
      );

  Map<String, dynamic> toJson() => {
        'siteLabel': siteLabelController.text.trim(),
        'address': addressController.text.trim().isEmpty
            ? null
            : addressController.text.trim(),
        'city': cityController.text.trim().isEmpty
            ? null
            : cityController.text.trim(),
        'state': stateController.text.trim().isEmpty
            ? null
            : stateController.text.trim(),
        'pincode': pincodeController.text.trim().isEmpty
            ? null
            : pincodeController.text.trim(),
        'isDefault': isDefault,
      };
}

class _SiteFormCard extends StatelessWidget {
  final int index;
  final _SiteFormData site;
  final VoidCallback? onRemove;
  final VoidCallback onSetDefault;

  const _SiteFormCard({
    required this.index,
    required this.site,
    required this.onRemove,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Site ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    if (site.isDefault)
                      const Chip(
                        label: Text('Default',
                            style: TextStyle(fontSize: 12)),
                        backgroundColor: Colors.green,
                        labelStyle: TextStyle(color: Colors.white),
                        padding: EdgeInsets.zero,
                      )
                    else
                      TextButton(
                        onPressed: onSetDefault,
                        child: const Text('Set Default'),
                      ),
                    if (onRemove != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red),
                        onPressed: onRemove,
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: site.siteLabelController,
              decoration: const InputDecoration(
                labelText: 'Site Label *',
                hintText: 'e.g. Main Roof, Factory Block A',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: site.addressController,
              decoration: const InputDecoration(
                labelText: 'Site Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: site.cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: site.stateController,
                    decoration: const InputDecoration(
                      labelText: 'State',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 110,
                  child: TextFormField(
                    controller: site.pincodeController,
                    decoration: const InputDecoration(
                      labelText: 'Pincode',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}