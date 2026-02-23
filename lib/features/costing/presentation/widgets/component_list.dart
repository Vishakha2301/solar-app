import 'package:flutter/material.dart';
import '../../../costing/domain/models/component_cost.dart';

class ComponentList extends StatelessWidget {
  final Map<String, ComponentCost> components;
  final void Function(String key) onEdit;

  /// Component differs from initial state
  final bool Function(String key) isModified;

  /// Mandatory component but not yet calculated
  final bool Function(String key) isMissing;

  const ComponentList({
    super.key,
    required this.components,
    required this.onEdit,
    required this.isModified,
    required this.isMissing,
  });

  @override
  Widget build(BuildContext context) {
    if (components.isEmpty) {
      return const Text(
        'No components added yet',
        style: TextStyle(color: Colors.grey),
      );
    }

    return Column(
      children: components.entries.map((entry) {
        final key = entry.key;
        final component = entry.value;

        final bool missing = isMissing(key);
        final bool modified = isModified(key);

        // --------------------------------------------
        // Visual state
        // --------------------------------------------
        Color backgroundColor = Colors.white;
        Color borderColor = Colors.transparent;
        IconData? statusIcon;
        Color? statusIconColor;

        if (missing) {
          backgroundColor = Colors.red.shade50;
          borderColor = Colors.red.shade400;
          statusIcon = Icons.error_outline;
          statusIconColor = Colors.red;
        } else if (modified) {
          backgroundColor = Colors.orange.shade50;
          borderColor = Colors.orange.shade400;
          statusIcon = Icons.edit;
          statusIconColor = Colors.orange;
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    component.name,
                    style: TextStyle(
                      fontWeight:
                          missing ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (statusIcon != null)
                  Icon(
                    statusIcon,
                    size: 18,
                    color: statusIconColor,
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Qty: ${component.quantity} | Rate: ₹${component.unitPrice}',
                ),
                if (missing)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Required component',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '₹ ${component.subTotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => onEdit(key),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}