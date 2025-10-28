import 'package:flutter/material.dart';

class HorizontalListSection<T> extends StatelessWidget {
  final String title;
  final double height;
  final List<T> items;
  final Widget Function(T item) itemBuilder;

  const HorizontalListSection({
    super.key,
    required this.title,
    required this.height,
    required this.items,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        const SizedBox(height: 12),
        SizedBox(
          height: height,
          child: items.isEmpty
              ? const SizedBox.shrink()
              : ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (_, index) => itemBuilder(items[index]),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: items.length,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Container(width: 4, height: 24, color: Colors.greenAccent),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}
