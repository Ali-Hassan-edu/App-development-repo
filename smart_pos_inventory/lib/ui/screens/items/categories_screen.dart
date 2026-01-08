import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/categories/category_models.dart';
import '../../../state/categories/category_provider.dart';

class CategoriesScreen extends StatefulWidget {
  final VoidCallback onMenuTap;
  const CategoriesScreen({super.key, required this.onMenuTap});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final p = context.read<CategoryProvider>();
      if (p.categories.isEmpty) {
        await p.load();
      }
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _addDialog(BuildContext context) {
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Category', style: TextStyle(fontWeight: FontWeight.w900)),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Category name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final err = await context.read<CategoryProvider>().addCategory(ctrl.text);
              if (!ctx.mounted) return;
              if (err != null) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(err)));
                return;
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Category added')),
              );
            },
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _editDialog(BuildContext context, Category c) {
    final ctrl = TextEditingController(text: c.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Category', style: TextStyle(fontWeight: FontWeight.w900)),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Category name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final err = await context.read<CategoryProvider>().updateCategory(
                c.copyWith(name: ctrl.text),
              );
              if (!ctx.mounted) return;
              if (err != null) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(err)));
                return;
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Category updated')),
              );
            },
            child: const Text('Update', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CategoryProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : Colors.black87;

    final items = p.search(_search.text);

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
          colors: [Color(0xFF0F1320), Color(0xFF121A31), Color(0xFF0F1320)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : const LinearGradient(
          colors: [Color(0xFFF4F7FF), Color(0xFFFFF6F9), Color(0xFFF6FFFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.menu, color: titleColor),
                  onPressed: widget.onMenuTap,
                ),
                const SizedBox(width: 8),
                Icon(Icons.category_outlined, color: titleColor),
                const SizedBox(width: 8),
                Text(
                  'Categories',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: titleColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Add',
                  onPressed: () => _addDialog(context),
                  icon: Icon(Icons.add_circle_outline, color: titleColor),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? const Color(0xFF161E35) : Colors.white,
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search category...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: p.loading
                ? const Center(child: CircularProgressIndicator())
                : p.error != null
                ? Center(child: Text('Error: ${p.error}'))
                : items.isEmpty
                ? const Center(child: Text('No categories yet'))
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 90),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final c = items[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isDark ? const Color(0xFF161E35) : Colors.white,
                    border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.label_outline),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          c.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: titleColor,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Edit',
                        onPressed: () => _editDialog(context, c),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        onPressed: () async {
                          final err = await context
                              .read<CategoryProvider>()
                              .deleteCategory(c.id);
                          if (err != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(err)),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Category deleted')),
                            );
                          }
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
