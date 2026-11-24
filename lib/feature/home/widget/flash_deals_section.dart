import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rescu/feature/home/widget/flash_sale_card.dart';
import 'package:rescu/model/deal_model.dart';

/// Horizontal flash-sale rail.
///
/// NOTE: the countdown is currently a static "Ends soon" label — turning it
/// into a live per-deal countdown is one of the feature tasks in PROBLEM.md.
class FlashDealsSection extends StatefulWidget {
  final List<DealModel> deals;

  const FlashDealsSection({super.key, required this.deals});

  @override
  State<FlashDealsSection> createState() => _FlashDealsSectionState();
}

class _FlashDealsSectionState extends State<FlashDealsSection> {
  final ValueNotifier<DateTime> _now = ValueNotifier<DateTime>(DateTime.now().toUtc());
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _now.value = DateTime.now().toUtc();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _now.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(Icons.bolt, color: Colors.red, size: 20),
              SizedBox(width: 4),
              Text(
                'Flash sales',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: widget.deals.length,
            itemBuilder: (context, index) {
              final deal = widget.deals[index];
              return FlashSaleCard(
                deal: deal,
                nowListenable: _now,
              );
            },
          ),
        ),
      ],
    );
  }
}
