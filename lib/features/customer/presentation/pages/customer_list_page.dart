import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/customer_store.dart';
import '../../domain/models/customer.dart';
import 'customer_form_page.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerStore>().loadAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CustomerStore>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Customer',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CustomerFormPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<CustomerStore>().loadAll();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                context.read<CustomerStore>().search(value);
              },
            ),
          ),
          Expanded(child: _buildBody(store)),
        ],
      ),
    );
  }

  Widget _buildBody(CustomerStore store) {
    if (store.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (store.status == CustomerStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(store.errorMessage ?? 'Something went wrong'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<CustomerStore>().loadAll(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (store.customers.isEmpty) {
      return const Center(
        child: Text(
          'No customers yet.\nTap + to add one.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: store.customers.length,
      itemBuilder: (context, index) {
        return _CustomerCard(customer: store.customers[index]);
      },
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final Customer customer;

  const _CustomerCard({required this.customer});

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Customer?'),
            content: const Text(
              'This will deactivate the customer. Are you sure?',
            ),
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
          backgroundColor: _typeColor(customer.customerType),
          child: Text(
            customer.name[0].toUpperCase(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(customer.displayName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(customer.phone),
            if (customer.city != null)
              Text(customer.city!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      CustomerFormPage(existingCustomer: customer),
                ),
              );
            } else if (value == 'delete') {
              final confirm = await _confirmDelete(context);
              if (confirm && context.mounted) {
                await context
                    .read<CustomerStore>()
                    .deactivate(customer.id);
              }
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Color _typeColor(CustomerType type) {
    return switch (type) {
      CustomerType.INDIVIDUAL => Colors.blue,
      CustomerType.COMPANY => Colors.orange,
      CustomerType.SOCIETY => Colors.green,
    };
  }
}