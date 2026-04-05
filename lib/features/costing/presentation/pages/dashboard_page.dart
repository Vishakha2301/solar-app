import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/costing_store.dart';
import '../../domain/models/saved_costing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/presentation/state/auth_store.dart';
import 'costing_page.dart';
import 'view_costing_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CostingStore>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CostingStore>();

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
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Logout?'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await context.read<AuthStore>().logout();
                }
              },
            ),
          ],
        ),
      body: _buildBody(store),
    );
  }

  Widget _buildBody(CostingStore store) {
    if (store.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (store.status == CostingStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(store.errorMessage ?? 'Something went wrong'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<CostingStore>().loadAll(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (store.costings.isEmpty) {
      return const Center(
        child: Text(
          'No costings yet.\nTap + to add one.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: store.costings.length,
      itemBuilder: (context, index) {
        return _CostingCard(costing: store.costings[index]);
      },
    );
  }
}

class _CostingCard extends StatelessWidget {
  final SavedCosting costing;

  const _CostingCard({required this.costing});

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Costing?'),
            content: const Text(
              'This action cannot be undone. Do you want to delete this costing?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
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
      child: ListTile(
        title: Text(costing.context.roofIdentifier),
        subtitle: Text(
          '${costing.context.plantCapacity} kWp · ${costing.context.systemType}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      CostingPage(existingCosting: costing),
                ),
              );
            } else if (value == 'duplicate') {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CostingPage(
                    existingCosting: costing,
                    isDuplicate: true,
                  ),
                ),
              );
            } else if (value == 'delete') {
              final confirm = await _confirmDelete(context);
              if (confirm && context.mounted) {
                await context.read<CostingStore>().deleteCosting(costing.id);
              }
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewCostingPage(costing: costing),
          ),
        ),
      ),
    );
  }
}