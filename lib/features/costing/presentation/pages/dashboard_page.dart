import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/costing_store.dart';
import '../../domain/models/saved_costing.dart';
import '../../../../core/theme/app_colors.dart';
import 'costing_page.dart';
import 'view_costing_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final costings =
        context.watch<CostingStore>().costings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Costing Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Costing',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CostingPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: costings.isEmpty
          ? _emptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: costings.length,
              itemBuilder: (context, index) {
                final costing = costings[index];
                return _CostingCard(costing: costing);
              },
            ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Text(
        'No costings yet.\nTap + to add one.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}


//temparory then move to new file

class _CostingCard extends StatelessWidget {
  final SavedCosting costing;

  const _CostingCard({required this.costing});

  Future<bool> _confirmDelete(
    BuildContext context) async {
      return await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Delete Costing?'),
              content: const Text(
                'This action cannot be undone. Do you want to delete this costing?',
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () =>
                      Navigator.pop(context, true),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ) ??
          false;
    }

  @override
  Widget build(BuildContext context) {
    final ctx = costing.context;
    final snap = costing.snapshot;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewCostingPage(costing: costing),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${ctx.plantCapacity} kW | ${ctx.phaseType}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium,
                  ),
                  Row(
                    children: [
                      if (ctx.isSubsidyProject)
                        _badge('Subsidy Project'),

                      const SizedBox(width: 8),

                      // Duplicate
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        tooltip: 'Duplicate',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CostingPage(
                                existingCosting: costing,
                                isDuplicate: true,
                              ),
                            ),
                          );
                        },
                      ),

                      // Delete
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            size: 20, color: Colors.red),
                        tooltip: 'Delete',
                        onPressed: () async {
                          final confirm =
                              await _confirmDelete(context);

                          if (!context.mounted) return;

                          if (confirm) {
                            context
                                .read<CostingStore>()
                                .deleteCosting(costing.id);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Text(
                '${ctx.systemType} • ${ctx.roofType} • ${ctx.roofIdentifier.isEmpty ? 'Roof' : ctx.roofIdentifier}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall,
              ),

              const Divider(height: 24),

              // ================= COST =================
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Project Cost (After GST)'),
                  Text(
                    '₹ ${snap.projectCostAfterGst.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text('₹ / Wp'),
                  Text(
                    '₹ ${snap.perWpAfterGst.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                'Created on ${_formatDate(costing.createdAt)}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.orange,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
