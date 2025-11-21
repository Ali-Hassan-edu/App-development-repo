import 'package:flutter/material.dart';

enum TaskSort { dueSoon, priorityHighFirst, titleAZ }

class SearchFilterState {
  final String query;
  final Set<String> priorities;
  final TaskSort sort;

  const SearchFilterState({this.query = '', this.priorities = const {}, this.sort = TaskSort.dueSoon});

  SearchFilterState copyWith({String? query, Set<String>? priorities, TaskSort? sort}) =>
      SearchFilterState(query: query ?? this.query, priorities: priorities ?? this.priorities, sort: sort ?? this.sort);

  static int priorityScore(String p) => switch (p.toLowerCase()) { 'high' => 3, 'medium' => 2, _ => 1 };
}

class SearchFilterBar extends StatefulWidget {
  final SearchFilterState initial;
  final void Function(SearchFilterState) onChanged;
  final List<String> priorityOptions;

  const SearchFilterBar({
    super.key,
    required this.onChanged,
    this.initial = const SearchFilterState(),
    this.priorityOptions = const ['Low', 'Medium', 'High'],
  });

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  late TextEditingController _q;
  late SearchFilterState _state;

  @override
  void initState() {
    super.initState();
    _state = widget.initial;
    _q = TextEditingController(text: _state.query);
  }

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  void _emit() => widget.onChanged(_state);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _q,
          onChanged: (v) { _state = _state.copyWith(query: v.trim()); _emit(); },
          decoration: InputDecoration(
            hintText: 'Search tasks…',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _state.query.isEmpty
                ? null
                : IconButton(icon: const Icon(Icons.clear), onPressed: () { _q.clear(); _state = _state.copyWith(query: ''); _emit(); setState(() {}); }),
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...widget.priorityOptions.map((p) {
                final selected = _state.priorities.contains(p);
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(p),
                    selected: selected,
                    onSelected: (v) {
                      final next = Set<String>.from(_state.priorities);
                      v ? next.add(p) : next.remove(p);
                      _state = _state.copyWith(priorities: next);
                      _emit();
                      setState(() {});
                    },
                  ),
                );
              }),
              const SizedBox(width: 6),
              PopupMenuButton<TaskSort>(
                initialValue: _state.sort,
                onSelected: (s) { _state = _state.copyWith(sort: s); _emit(); setState(() {}); },
                itemBuilder: (ctx) => const [
                  PopupMenuItem(value: TaskSort.dueSoon, child: Text('Sort: Due soon')),
                  PopupMenuItem(value: TaskSort.priorityHighFirst, child: Text('Sort: Priority')),
                  PopupMenuItem(value: TaskSort.titleAZ, child: Text('Sort: Title A–Z')),
                ],
                child: const Chip(avatar: Icon(Icons.sort, size: 18), label: Text('Sort')),
              ),
              const SizedBox(width: 6),
              TextButton.icon(
                onPressed: () { _q.clear(); _state = const SearchFilterState(); _emit(); setState(() {}); },
                icon: const Icon(Icons.refresh), label: const Text('Clear'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}