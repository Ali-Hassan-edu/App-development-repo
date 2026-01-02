// lib/ui/screens/customers/customers_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/customers/customer_models.dart';
import '../../../state/customers/customer_provider.dart';

class CustomersScreen extends StatefulWidget {
  final VoidCallback onMenuTap;
  const CustomersScreen({super.key, required this.onMenuTap});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openCustomerSheet({Customer? editing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (_) => _CustomerSheet(editing: editing),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CustomerProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgGradient = isDark
        ? const LinearGradient(
      colors: [Color(0xFF0F1320), Color(0xFF121A31), Color(0xFF0F1320)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    )
        : const LinearGradient(
      colors: [Color(0xFFF4F7FF), Color(0xFFFFF6F9), Color(0xFFF6FFFB)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final titleColor = isDark ? Colors.white : Colors.black87;
    final results = prov.search(_search.text);

    return Stack(
      children: [
        Container(decoration: BoxDecoration(gradient: bgGradient)),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Row(
                children: [
                  IconButton(icon: Icon(Icons.menu, color: titleColor), onPressed: widget.onMenuTap),
                  const SizedBox(width: 8),
                  Icon(Icons.people_alt_outlined, color: titleColor),
                  const SizedBox(width: 8),
                  Text(
                    'Customers',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: titleColor),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search by name or phone',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF161E35) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: prov.loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (prov.error != null)
                    _errorBox(prov.error!)
                  else if (results.isEmpty)
                    _emptyState(isDark, onAdd: () => _openCustomerSheet())
                  else
                    ...results.map(
                          (c) => _customerTile(
                        isDark: isDark,
                        customer: c,
                        onEdit: () => _openCustomerSheet(editing: c),
                        onDelete: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Delete Customer'),
                              content: Text('Delete "${c.name}"?'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel')),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (ok != true) return;
                          final err = await context.read<CustomerProvider>().deleteCustomer(c.id);
                          if (!context.mounted) return;
                          if (err != null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                          }
                        },
                      ),
                    ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: () => _openCustomerSheet(),
            icon: const Icon(Icons.person_add_alt_1, size: 26),
            label: const Text('Add Customer', style: TextStyle(fontWeight: FontWeight.w900)),
            backgroundColor: const Color(0xFF3CC5FF),
          ),
        ),
      ],
    );
  }

  Widget _customerTile({
    required bool isDark,
    required Customer customer,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    final card = isDark ? const Color(0xFF161E35) : Colors.white;
    final border = isDark ? Colors.white12 : Colors.black12;
    final text = isDark ? Colors.white : Colors.black87;
    final sub = isDark ? Colors.white70 : Colors.black54;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF3CC5FF).withOpacity(0.18),
            child: Text(
              customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
              style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF3CC5FF)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.name, style: TextStyle(color: text, fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 3),
                Text(customer.phone, style: TextStyle(color: sub, fontWeight: FontWeight.w700)),
                if ((customer.address ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(customer.address!, style: TextStyle(color: sub, fontWeight: FontWeight.w700)),
                ]
              ],
            ),
          ),
          IconButton(onPressed: onEdit, icon: Icon(Icons.edit, color: text)),
          IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline, color: Colors.redAccent)),
        ],
      ),
    );
  }

  Widget _emptyState(bool isDark, {required VoidCallback onAdd}) {
    final card = isDark ? const Color(0xFF161E35) : Colors.white.withOpacity(0.75);
    final text = isDark ? Colors.white : Colors.black87;
    final sub = isDark ? Colors.white70 : Colors.black54;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Column(
        children: [
          Icon(Icons.people_alt_outlined, size: 54, color: text),
          const SizedBox(height: 10),
          Text('No customers yet', style: TextStyle(color: text, fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            'Add your first customer for fast billing.',
            textAlign: TextAlign.center,
            style: TextStyle(color: sub, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add Customer', style: TextStyle(fontWeight: FontWeight.w900)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3CC5FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _errorBox(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEAEA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}

class _CustomerSheet extends StatefulWidget {
  final Customer? editing;
  const _CustomerSheet({this.editing});

  @override
  State<_CustomerSheet> createState() => _CustomerSheetState();
}

class _CustomerSheetState extends State<_CustomerSheet> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.editing;
    if (c != null) {
      _name.text = c.name;
      _phone.text = c.phone;
      _address.text = c.address ?? '';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final phone = _phone.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter customer name')));
      return;
    }
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter customer phone')));
      return;
    }

    setState(() => _saving = true);

    String? err;
    final prov = context.read<CustomerProvider>();

    if (widget.editing == null) {
      err = await prov.addCustomer(name: name, phone: phone, address: _address.text.trim());
    } else {
      final old = widget.editing!;
      err = await prov.updateCustomer(
        old.copyWith(
          name: name,
          phone: phone,
          address: _address.text.trim().isEmpty ? null : _address.text.trim(),
        ),
      );
    }

    setState(() => _saving = false);

    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sheetColor = isDark ? const Color(0xFF121A31) : Colors.white;
    final border = isDark ? Colors.white12 : Colors.black12;
    final text = isDark ? Colors.white : Colors.black87;
    final fill = isDark ? const Color(0xFF161E35) : const Color(0xFFF6F7FB);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: sheetColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 10))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(colors: [Color(0xFF6D5DF6), Color(0xFF3CC5FF)]),
                      ),
                      child: Icon(widget.editing == null ? Icons.person_add_alt_1 : Icons.edit, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.editing == null ? 'Add Customer' : 'Edit Customer',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: text),
                      ),
                    ),
                    IconButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: text),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _name,
                  decoration: InputDecoration(
                    labelText: 'Customer Name',
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true,
                    fillColor: fill,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    filled: true,
                    fillColor: fill,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _address,
                  decoration: InputDecoration(
                    labelText: 'Address (optional)',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    filled: true,
                    fillColor: fill,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3CC5FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                        : const Icon(Icons.check),
                    label: Text(
                      _saving ? 'Saving...' : (widget.editing == null ? 'Add Customer' : 'Update Customer'),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
