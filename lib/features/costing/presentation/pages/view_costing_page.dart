import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/saved_costing.dart';
import 'costing_page.dart';

class ViewCostingPage extends StatelessWidget {
  final SavedCosting costing;

  const ViewCostingPage({super.key, required this.costing});

  @override
  Widget build(BuildContext context) {
    final ctx = costing.context;
    final snap = costing.snapshot;

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Costing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CostingPage(
                    existingCosting: costing,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= CONTEXT =================
            _sectionTitle(context, 'System Details'),
            _infoRow('System Type', ctx.systemType),
            _infoRow('Phase Type', ctx.phaseType),
            _infoRow('Roof Type', ctx.roofType),
            _infoRow(
              'Roof Identifier',
              ctx.roofIdentifier.isEmpty
                  ? '-'
                  : ctx.roofIdentifier,
            ),
            _infoRow(
              'Subsidy Project',
              ctx.isSubsidyProject ? 'Yes' : 'No',
            ),

            const SizedBox(height: 24),

            // ================= SUMMARY =================
            _sectionTitle(context, 'Cost Summary'),
            _amountRow(
              'System Subtotal',
              snap.systemSubTotal,
            ),
            _amountRow(
              'Subsidy Processing Fee',
              snap.subsidyProcessingFee,
            ),
            _amountRow(
              'Contingency',
              snap.contingency,
            ),
            _amountRow(
              'Channel Partner 1',
              snap.cp1,
            ),
            _amountRow(
              'Channel Partner 2',
              snap.cp2,
            ),
            _amountRow(
              'AMC',
              snap.amc,
            ),

            const Divider(height: 32),

            _amountRow(
              'Project Cost (After GST)',
              snap.projectCostAfterGst,
              highlight: true,
            ),
            _amountRow(
              '₹ / Wp',
              snap.perWpAfterGst,
            ),

            const SizedBox(height: 24),

            // ================= COMPONENTS =================
            _sectionTitle(context, 'Components'),
            ...snap.components.entries.map((e) {
              final c = e.value;
              return ListTile(
                dense: true,
                title: Text(c.name),
                trailing: Text(
                  '₹ ${c.subTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ================= HELPERS =================

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _amountRow(
    String label,
    double value, {
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight:
                  highlight ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            '₹ ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: highlight
                  ? AppColors.primaryGreen
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
