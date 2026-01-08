import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/theme/theme_provider.dart';
import '../../widgets/back_to_dashboard.dart';

class TaxScreen extends StatefulWidget {
  final VoidCallback onMenuTap; // keep for compatibility with your sidebar
  const TaxScreen({super.key, required this.onMenuTap});

  @override
  State<TaxScreen> createState() => _TaxScreenState();
}

class _TaxScreenState extends State<TaxScreen> {
  final _taxPercent = TextEditingController(text: '0');

  @override
  void dispose() {
    _taxPercent.dispose();
    super.dispose();
  }

  double? _toDouble(String s) => double.tryParse(s.trim());

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDark;

    final titleColor = isDark ? Colors.white : Colors.black87;

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

    final card = isDark ? const Color(0xFF161E35) : Colors.white;
    final border = isDark ? Colors.white12 : Colors.black12;
    final sub = isDark ? Colors.white70 : Colors.black54;

    return BackToDashboardWrapper(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: bgGradient),
          child: Column(
            children: [
              // ✅ TOP BAR
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                child: Row(
                  children: [
                    backToDashboardButton(context, color: titleColor),
                    const SizedBox(width: 8),
                    Icon(Icons.receipt_outlined, color: titleColor),
                    const SizedBox(width: 8),
                    Text(
                      'Tax',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: titleColor,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Default Tax (%)',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Set your tax rate (e.g. GST). You can apply it during billing.',
                            style: TextStyle(
                              color: sub,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _taxPercent,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Tax %',
                              prefixIcon: const Icon(Icons.percent),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF121A31) : const Color(0xFFF6F7FB),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3CC5FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                final v = _toDouble(_taxPercent.text) ?? -1;
                                if (v < 0 || v > 100) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Tax must be between 0 and 100')),
                                  );
                                  return;
                                }

                                // ✅ connect to billing/tax logic later
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Saved tax: $v%')),
                                );
                              },
                              icon: const Icon(Icons.save),
                              label: const Text(
                                'Save Tax',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Color(0xFFFFC371)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Tip: If you want tax per item, we will apply it using item total.',
                              style: TextStyle(color: sub, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
