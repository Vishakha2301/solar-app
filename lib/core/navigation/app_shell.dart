import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/presentation/state/auth_store.dart';
import '../../../features/costing/presentation/pages/dashboard_page.dart';
import '../../../features/customer/presentation/pages/customer_list_page.dart';
import '../../../features/material/presentation/pages/material_list_page.dart';
import '../../../features/quotation/presentation/pages/quotation_list_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.calculate_outlined, activeIcon: Icons.calculate, label: 'Costing'),
    _NavItem(icon: Icons.people_outline, activeIcon: Icons.people, label: 'Customers'),
    _NavItem(icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2, label: 'Materials'),
    _NavItem(icon: Icons.description_outlined, activeIcon: Icons.description, label: 'Quotations'),
  ];

  final List<Widget> _pages = const [
    DashboardPage(),
    CustomerListPage(),
    MaterialListPage(),
		QuotationListPage(),
    Scaffold(body: Center(child: Text('Quotations — coming soon'))),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;

    return isWide ? _buildWideLayout() : _buildNarrowLayout();
  }

  Widget _buildWideLayout() {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            minExtendedWidth: 220,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) =>
                setState(() => _selectedIndex = index),
            leading: _sidebarHeader(),
            trailing: _sidebarFooter(),
            destinations: _navItems
                .map((item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.activeIcon),
                      label: Text(item.label),
                    ))
                .toList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout() {
    return Scaffold(
      drawer: NavigationDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          Navigator.pop(context);
        },
        children: [
          _drawerHeader(),
          ..._navItems.map((item) => NavigationDrawerDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.activeIcon),
                label: Text(item.label),
              )),
          const Divider(),
          _drawerLogout(),
        ],
      ),
      appBar: AppBar(
        title: Text(_navItems[_selectedIndex].label),
      ),
      body: _pages[_selectedIndex],
    );
  }

  Widget _sidebarHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      child: Column(
        children: [
          const Icon(Icons.solar_power, size: 40, color: Colors.orange),
          const SizedBox(height: 8),
          const Text(
            'Solar ERP',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            context.watch<AuthStore>().username ?? '',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          const Divider(),
        ],
      ),
    );
  }

  Widget _sidebarFooter() {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: SizedBox(
            width: 220,
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout',
                  style: TextStyle(color: Colors.red)),
              onTap: _confirmLogout,
            ),
          ),
        ),
      ),
    );
  }

  Widget _drawerHeader() {
    return UserAccountsDrawerHeader(
      accountName: Text(
        context.watch<AuthStore>().username ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      accountEmail: const Text('Solar ERP'),
      currentAccountPicture: const CircleAvatar(
        child: Icon(Icons.solar_power, size: 32, color: Colors.orange),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _drawerLogout() {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text('Logout', style: TextStyle(color: Colors.red)),
      onTap: _confirmLogout,
    );
  }

  Future<void> _confirmLogout() async {
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
    if (confirm == true && mounted) {
      await context.read<AuthStore>().logout();
    }
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}