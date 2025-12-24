import 'package:flutter/material.dart';

class FilterChipGroup extends StatelessWidget {
  final List<String> options;
  final String? selectedOption;
  final void Function(String?) onSelected;
  final bool showAll;
  
  const FilterChipGroup({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onSelected,
    this.showAll = true,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (showAll)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('All'),
                selected: selectedOption == null,
                onSelected: (_) => onSelected(null),
              ),
            ),
          ...options.map((option) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(option),
              selected: selectedOption == option,
              onSelected: (_) => onSelected(option),
            ),
          )),
        ],
      ),
    );
  }
}

class SegmentFilter extends StatelessWidget {
  final List<String> segments;
  final int selectedIndex;
  final void Function(int) onSelected;
  
  const SegmentFilter({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      segments: segments.asMap().entries.map((entry) {
        return ButtonSegment<int>(
          value: entry.key,
          label: Text(entry.value),
        );
      }).toList(),
      selected: {selectedIndex},
      onSelectionChanged: (selected) {
        if (selected.isNotEmpty) {
          onSelected(selected.first);
        }
      },
    );
  }
}
