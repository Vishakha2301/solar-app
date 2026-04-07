import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/quotation_store.dart';
import '../../domain/models/quotation.dart';
import 'quotation_form_page.dart';
import 'quotation_detail_page.dart';

class QuotationListPage extends StatefulWidget {
  const QuotationListPage({super.key});

  @override
  State<QuotationListPage> createState() => _QuotationListPageState();
}

class _QuotationListPageState extends State<QuotationListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuotationStore>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<QuotationStore>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Quotation',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const QuotationFormPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: store.selectedStatus == null,
                    onSelected: (_) =>
                        context.read<QuotationStore>().filterByStatus(null),
                  ),
                ),
                ...QuotationStatus.values.map((status) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(_statusLabel(status)),
                        selected: store.selectedStatus == status,
                        selectedColor: _statusColor(status).withOpacity(0.2),
                        onSelected: (_) => context
                            .read<QuotationStore>()
                            .filterByStatus(status),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildBody(store)),
        ],
      ),
    );
  }

  Widget _buildBody(QuotationStore store) {
    if (store.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (store.status == QuotationStoreStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(store.errorMessage ?? 'Something went wrong'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<QuotationStore>().loadAll(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (store.quotations.isEmpty) {
      return const Center(
        child: Text(
          'No quotations yet.\nTap + to create one.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: store.quotations.length,
      itemBuilder: (context, index) {
        return _QuotationCard(quotation: store.quotations[index]);
      },
    );
  }

  String _statusLabel(QuotationStatus status) => switch (status) {
        QuotationStatus.DRAFT => 'Draft',
        QuotationStatus.SUBMITTED => 'Submitted',
        QuotationStatus.APPROVED => 'Approved',
        QuotationStatus.REJECTED => 'Rejected',
        QuotationStatus.REVISED => 'Revised',
      };

  Color _statusColor(QuotationStatus status) => switch (status) {
        QuotationStatus.DRAFT => Colors.grey,
        QuotationStatus.SUBMITTED => Colors.blue,
        QuotationStatus.APPROVED => Colors.green,
        QuotationStatus.REJECTED => Colors.red,
        QuotationStatus.REVISED => Colors.orange,
      };
}

class _QuotationCard extends StatelessWidget {
  final Quotation quotation;

  const _QuotationCard({required this.quotation});

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Quotation?'),
            content: const Text(
                'This action cannot be undone. Are you sure?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuotationDetailPage(quotation: quotation),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    quotation.quotationNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: quotation.statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: quotation.statusColor.withOpacity(0.4)),
                        ),
                        child: Text(
                          quotation.statusLabel,
                          style: TextStyle(
                            color: quotation.statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => QuotationFormPage(
                                    existingQuotation: quotation),
                              ),
                            );
                          } else if (value == 'submit') {
                            await context
                                .read<QuotationStore>()
                                .submit(quotation.id);
                          } else if (value == 'delete') {
                            final confirm = await _confirmDelete(context);
                            if (confirm && context.mounted) {
                              await context
                                  .read<QuotationStore>()
                                  .delete(quotation.id);
                            }
                          }
                        },
                        itemBuilder: (_) => [
                          if (quotation.status == QuotationStatus.DRAFT ||
                              quotation.status == QuotationStatus.REJECTED)
                            const PopupMenuItem(
                                value: 'edit', child: Text('Edit')),
                          if (quotation.status == QuotationStatus.DRAFT ||
                              quotation.status == QuotationStatus.REJECTED)
                            const PopupMenuItem(
                                value: 'submit', child: Text('Submit')),
                          if (quotation.status == QuotationStatus.DRAFT)
                            const PopupMenuItem(
                                value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                quotation.customer.displayName,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (quotation.systemType != null) ...[
                    const Icon(Icons.solar_power,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      quotation.systemType!,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                  ],
                  const Icon(Icons.calendar_today,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(quotation.createdAt),
                    style:
                        const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
              if (quotation.rejectionReason != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 14, color: Colors.red),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          quotation.rejectionReason!,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.red),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}