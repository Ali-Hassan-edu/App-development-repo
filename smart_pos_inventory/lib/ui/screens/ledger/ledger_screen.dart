import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/customers/customer_provider.dart';
import '../../../state/ledger/ledger_provider.dart';

class LedgerScreen extends StatefulWidget {
  final VoidCallback onMenuTap;

  /// ✅ If provided, screen will open directly for this customer.
  final String? initialCustomerId;

  const LedgerScreen({
    super.key,
    required this.onMenuTap,
    this.initialCustomerId,
  });

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  String? _selectedCustomerId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final custProv = context.read<CustomerProvider>();
      if (custProv.customers.isEmpty) {
        await custProv.load();
      }
      if (!mounted) return;

      // ✅ Prefer explicit customer if passed
      final preferred = widget.initialCustomerId;

      if (preferred != null && custProv.getById(preferred) != null) {
        await _selectCustomer(preferred);
        return;
      }

      // Fallback: first customer
      if (custProv.customers.isNotEmpty) {
        await _selectCustomer(custProv.customers.first.id);
      }
    });
  }

  Future<void> _selectCustomer(String customerId) async {
    setState(() => _selectedCustomerId = customerId);
    await context.read<LedgerProvider>().openCustomer(customerId);
  }

  String _money(double v) => v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final custProv = context.watch<CustomerProvider>();
    final ledger = context.watch<LedgerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ledger',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: widget.onMenuTap,
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: ledger.loading ? null : () => context.read<LedgerProvider>().refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          _topCard(context, custProv, ledger),
          const SizedBox(height: 8),
          Expanded(child: _body(context, ledger)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (_selectedCustomerId == null) ? null : () => _openAddEntrySheet(context),
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Entry',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _topCard(BuildContext context, CustomerProvider custProv, LedgerProvider ledger) {
    final customers = custProv.customers;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Customer',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCustomerId,
              isExpanded: true,
              items: customers
                  .map(
                    (c) => DropdownMenuItem(
                  value: c.id,
                  child: Text('${c.name} • ${c.phone}'),
                ),
              )
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                _selectCustomer(v);
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Outstanding:',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(width: 10),
                Text(
                  '₹ ${_money(ledger.outstanding)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: ledger.outstanding >= 0 ? Colors.redAccent : Colors.green,
                  ),
                ),
                const Spacer(),
                if (ledger.loading)
                  const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, LedgerProvider ledger) {
    if (ledger.error != null) {
      return Center(child: Text('Error: ${ledger.error}'));
    }

    if (ledger.activeCustomerId == null) {
      return const Center(child: Text('Select a customer to view ledger.'));
    }

    if (!ledger.loading && ledger.items.isEmpty) {
      return const Center(child: Text('No ledger entries yet.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 90),
      itemCount: ledger.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final e = ledger.items[i];

        final isDebit = e.type == 'debit';
        final label = e.type.toUpperCase();
        final sign = isDebit ? '+' : '-';
        final amountText = '$sign ₹ ${_money(e.amount)}';

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
          ),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isDebit ? Colors.red.withOpacity(0.12) : Colors.green.withOpacity(0.12),
                ),
                child: Icon(
                  isDebit ? Icons.call_made : Icons.call_received,
                  color: isDebit ? Colors.redAccent : Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(
                      e.note?.trim().isNotEmpty == true ? e.note! : '—',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateTime.fromMillisecondsSinceEpoch(e.createdAt).toString(),
                      style: const TextStyle(color: Colors.black45, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amountText,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: isDebit ? Colors.redAccent : Colors.green,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    onPressed: () => context.read<LedgerProvider>().delete(e.id),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _openAddEntrySheet(BuildContext context) {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String type = 'debit';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 14,
            right: 14,
            top: 14,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 14,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Ledger Entry',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(value: 'debit', child: Text('Debit (Customer owes)')),
                  DropdownMenuItem(value: 'credit', child: Text('Credit (You owe)')),
                  DropdownMenuItem(value: 'payment', child: Text('Payment received')),
                ],
                onChanged: (v) => type = v ?? 'debit',
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final amt = double.tryParse(amountCtrl.text.trim()) ?? 0;

                    final err = await context.read<LedgerProvider>().add(
                      type: type,
                      amount: amt,
                      note: noteCtrl.text.trim(),
                    );

                    if (!ctx.mounted) return;

                    if (err != null) {
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(err)));
                      return;
                    }

                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ledger entry added')),
                    );
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
