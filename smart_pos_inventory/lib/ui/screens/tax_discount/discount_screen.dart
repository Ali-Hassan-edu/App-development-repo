import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/theme/theme_provider.dart';
import '../../widgets/back_to_dashboard.dart';

class DiscountScreen extends StatefulWidget {
  final VoidCallback onMenuTap; // keep for compatibility with your sidebar
  const DiscountScreen({super.key, required this.onMenuTap});

  @override
  State<DiscountScreen> createState() => _DiscountScreenState();
}

class _DiscountScreenState extends State<DiscountScreen> {
  final _discountPercent = TextEditingController(text: '0');

  @override
  void dispose() {
    _discountPercent.dispose();
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
              // ✅ TOP BAR (FIXED: menu button added)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Menu',
                      onPressed: widget.onMenuTap,
                      icon: Icon(Icons.menu, color: titleColor),
                    ),
                    const SizedBox(width: 6),
                    backToDashboardButton(context, color: titleColor),
                    const SizedBox(width: 8),
                    Icon(Icons.percent_rounded, color: titleColor),
                    const SizedBox(width: 8),
                    Text(
                      'Discount',
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
                            'Default Discount (%)',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Set a default discount percentage that you can apply in billing.',
                            style: TextStyle(
                              color: sub,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _discountPercent,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Discount %',
                              prefixIcon: const Icon(Icons.percent),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF121A31)
                                  : const Color(0xFFF6F7FB),
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
                                final v = _toDouble(_discountPercent.text) ?? -1;
                                if (v < 0 || v > 100) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Discount must be between 0 and 100'),
                                    ),
                                  );
                                  return;
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Saved discount: $v%')),
                                );
                              },
                              icon: const Icon(Icons.save),
                              label: const Text(
                                'Save Discount',
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
                          const Icon(Icons.info_outline, color: Color(0xFF6D5DF6)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Tip: You can apply this discount in POS billing (per bill or per item).',
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
