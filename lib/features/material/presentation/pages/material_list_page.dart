import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/material_store.dart';
import '../../domain/models/material_item.dart';
import 'material_form_page.dart';

class MaterialListPage extends StatefulWidget {
  const MaterialListPage({super.key});

  @override
  State<MaterialListPage> createState() => _MaterialListPageState();
}

class _MaterialListPageState extends State<MaterialListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaterialStore>().loadAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<MaterialStore>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materials'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Material',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MaterialFormPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by brand name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<MaterialStore>().loadAll();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) =>
                  context.read<MaterialStore>().search(value),
            ),
          ),
          if (store.categories.isNotEmpty)
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
                      selected: store.selectedCategory == null,
                      onSelected: (_) =>
                          context.read<MaterialStore>().filterByCategory(null),
                    ),
                  ),
                  ...store.categories.map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat.label),
                          selected: store.selectedCategory == cat.value,
                          onSelected: (_) => context
                              .read<MaterialStore>()
                              .filterByCategory(cat.value),
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

  Widget _buildBody(MaterialStore store) {
    if (store.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (store.status == MaterialStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(store.errorMessage ?? 'Something went wrong'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<MaterialStore>().loadAll(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (store.materials.isEmpty) {
      return const Center(
        child: Text(
          'No materials yet.\nTap + to add one.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: store.materials.length,
      itemBuilder: (context, index) {
        return _MaterialCard(material: store.materials[index]);
      },
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final MaterialItem material;

  const _MaterialCard({required this.material});

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Material?'),
            content: const Text(
                'This will deactivate the material. Are you sure?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red),
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
        leading: CircleAvatar(
          backgroundColor: _categoryColor(material.category.value),
          child: Text(
            material.category.label[0],
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          '${material.brandName} — ${material.modelName}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(material.category.label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            if (material.specification != null)
              Text(
                material.specification!,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (material.warranty != null)
              Text(
                'Warranty: ${material.warranty}',
                style:
                    const TextStyle(fontSize: 12, color: Colors.green),
              ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      MaterialFormPage(existingMaterial: material),
                ),
              );
            } else if (value == 'delete') {
              final confirm = await _confirmDelete(context);
              if (confirm && context.mounted) {
                await context
                    .read<MaterialStore>()
                    .deactivate(material.id);
              }
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }

  Color _categoryColor(String category) {
    return switch (category) {
      'PANEL' => Colors.orange,
      'INVERTER' => Colors.blue,
      'CABLE' => Colors.purple,
      'STRUCTURE' => Colors.brown,
      'ELECTRICAL' => Colors.teal,
      _ => Colors.grey,
    };
  }
}