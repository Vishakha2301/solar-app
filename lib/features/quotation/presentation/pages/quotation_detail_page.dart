import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/quotation_store.dart';
import '../../domain/models/quotation.dart';
import 'quotation_form_page.dart';

class QuotationDetailPage extends StatelessWidget {
  final Quotation quotation;

  const QuotationDetailPage({super.key, required this.quotation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(quotation.quotationNumber),
        actions: [
          if (quotation.status == QuotationStatus.DRAFT ||
              quotation.status == QuotationStatus.REJECTED)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      QuotationFormPage(existingQuotation: quotation),
                ),
              ),
            ),
          if (quotation.status == QuotationStatus.SUBMITTED)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'approve') {
                  await _showApproveDialog(context);
                } else if (value == 'reject') {
                  await _showRejectDialog(context);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'approve', child: Text('Approve')),
                PopupMenuItem(value: 'reject', child: Text('Reject')),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statusBanner(quotation),
            const SizedBox(height: 16),
            _sectionCard(
              title: 'Customer',
              children: [
                _infoRow('Name', quotation.customer.displayName),
                _infoRow('Phone', quotation.customer.phone),
                if (quotation.customer.email != null)
                  _infoRow('Email', quotation.customer.email!),
                if (quotation.customerSite != null)
                  _infoRow('Site', quotation.customerSite!.siteLabel),
              ],
            ),
            const SizedBox(height: 12),
            _sectionCard(
              title: 'Quotation Details',
              children: [
                _infoRow('Quotation No', quotation.quotationNumber),
                _infoRow('System Type', quotation.systemType ?? '-'),
                _infoRow('Validity', '${quotation.validityDays} days'),
                _infoRow('Created',
                    _formatDate(quotation.createdAt)),
                if (quotation.submittedAt != null)
                  _infoRow('Submitted',
                      _formatDate(quotation.submittedAt!)),
                if (quotation.approvedRejectedAt != null)
                  _infoRow(
                    quotation.status == QuotationStatus.APPROVED
                        ? 'Approved'
                        : 'Rejected',
                    _formatDate(quotation.approvedRejectedAt!),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (quotation.costings.isNotEmpty)
              _sectionCard(
                title: 'Costings',
                children: quotation.costings
                    .map((c) => _infoRow(
                          c.roofLabel ?? 'Roof',
                          c.costingId,
                        ))
                    .toList(),
              ),
            const SizedBox(height: 12),
            if (quotation.instalments.isNotEmpty)
              _sectionCard(
                title: 'Payment Instalments',
                children: quotation.instalments
                    .map((inst) => _infoRow(
                          '${inst.instalmentNo}. ${inst.description}',
                          '${inst.percentage}%',
                        ))
                    .toList(),
              ),
            const SizedBox(height: 12),
            if (quotation.packages.isNotEmpty)
              ...quotation.packages.map((pkg) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _sectionCard(
                      title:
                          'Package — ${pkg.packageName}${pkg.isRecommended ? ' ★' : ''}',
                      children: pkg.materials
                          .map((m) => _infoRow(
                                m.componentKey,
                                '${m.material.brandName} ${m.material.modelName}',
                              ))
                          .toList(),
                    ),
                  )),
            if (quotation.scopeOfWork != null) ...[
              const SizedBox(height: 12),
              _sectionCard(
                title: 'Scope of Work',
                children: [
                  Text(quotation.scopeOfWork!,
                      style: const TextStyle(fontSize: 14))
                ],
              ),
            ],
            if (quotation.termsAndConditions != null) ...[
              const SizedBox(height: 12),
              _sectionCard(
                title: 'Terms & Conditions',
                children: [
                  Text(quotation.termsAndConditions!,
                      style: const TextStyle(fontSize: 14))
                ],
              ),
            ],
            if (quotation.rejectionReason != null) ...[
              const SizedBox(height: 12),
              _sectionCard(
                title: 'Rejection Reason',
                children: [
                  Text(quotation.rejectionReason!,
                      style: const TextStyle(
                          fontSize: 14, color: Colors.red))
                ],
              ),
            ],
            if (quotation.approvalNotes != null) ...[
              const SizedBox(height: 12),
              _sectionCard(
                title: 'Approval Notes',
                children: [
                  Text(quotation.approvalNotes!,
                      style: const TextStyle(
                          fontSize: 14, color: Colors.green))
                ],
              ),
            ],
            const SizedBox(height: 32),
            if (quotation.status == QuotationStatus.DRAFT ||
                quotation.status == QuotationStatus.REJECTED)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text('Submit for Approval'),
                  onPressed: () async {
                    await context
                        .read<QuotationStore>()
                        .submit(quotation.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusBanner(Quotation quotation) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: quotation.statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: quotation.statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(_statusIcon(quotation.status),
              color: quotation.statusColor),
          const SizedBox(width: 8),
          Text(
            quotation.statusLabel,
            style: TextStyle(
              color: quotation.statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(QuotationStatus status) => switch (status) {
        QuotationStatus.DRAFT => Icons.edit_note,
        QuotationStatus.SUBMITTED => Icons.pending,
        QuotationStatus.APPROVED => Icons.check_circle,
        QuotationStatus.REJECTED => Icons.cancel,
        QuotationStatus.REVISED => Icons.refresh,
      };

  Widget _sectionCard(
      {required String title, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _showApproveDialog(BuildContext context) async {
    final notesController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Approve Quotation'),
        content: TextField(
          controller: notesController,
          decoration: const InputDecoration(
            labelText: 'Approval Notes (optional)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await context.read<QuotationStore>().approve(
            quotation.id,
            notesController.text.trim().isEmpty
                ? null
                : notesController.text.trim(),
          );
      if (context.mounted) Navigator.pop(context);
    }
  }

  Future<void> _showRejectDialog(BuildContext context) async {
    final reasonController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reject Quotation'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Rejection Reason *',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      if (reasonController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Rejection reason is required')),
        );
        return;
      }
      await context
          .read<QuotationStore>()
          .reject(quotation.id, reasonController.text.trim());
      if (context.mounted) Navigator.pop(context);
    }
  }
}