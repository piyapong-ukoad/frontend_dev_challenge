
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rescu/app_config.dart';
import 'package:rescu/feature/home/widget/flash_deal_countdown.dart';
import 'package:rescu/feature/shared_widget/the_network_image.dart';
import 'package:rescu/model/deal_model.dart';
import 'package:rescu/routes/routes.dart';

class FlashSaleCard extends StatefulWidget {
  const FlashSaleCard({
    super.key,
    required this.deal,
    required this.nowListenable,
  });

  final DealModel deal;
  final ValueListenable<DateTime> nowListenable;

  @override
  State<FlashSaleCard> createState() => _FlashSaleCardState();
}

class _FlashSaleCardState extends State<FlashSaleCard> {
  late final ValueNotifier<bool> _isExpiredNotifier;

  @override
  void initState() {
    super.initState();
    _isExpiredNotifier = ValueNotifier<bool>(
      _checkExpired(widget.deal.flashSaleEndsAt, widget.nowListenable.value),
    );
  }

  @override
  void didUpdateWidget(covariant FlashSaleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deal.flashSaleEndsAt != widget.deal.flashSaleEndsAt) {
      _isExpiredNotifier.value = _checkExpired(
        widget.deal.flashSaleEndsAt,
        widget.nowListenable.value,
      );
    }
  }

  @override
  void dispose() {
    _isExpiredNotifier.dispose();
    super.dispose();
  }

  bool _checkExpired(DateTime? end, DateTime now) {
    return end == null || !end.isAfter(now);
  }

  void _onCountdownExpired() {
    if (!_isExpiredNotifier.value) {
      _isExpiredNotifier.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final deal = widget.deal;
    final end = deal.flashSaleEndsAt;

    return SizedBox(
      width: 200,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isExpiredNotifier,
        builder: (context, isExpired, _) {
          return Card(
            color: isExpired ? Colors.grey.shade100 : Colors.white,
            elevation: 0.5,
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: isExpired
                  ? null
                  : () => Get.toNamed(
                        Routes.dealRoute(deal.id, source: 'flash_rail'),
                        arguments: deal,
                      ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TheNetworkImage(
                    url: deal.imageUrl,
                    height: 90,
                    width: double.infinity,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deal.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          deal.storeName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              '฿${deal.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppConfig.primaryGreen,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isExpired
                                    ? Colors.grey.shade200
                                    : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: end == null
                                  ? const Text('Expired')
                                  : FlashDealCountdown(
                                      dealEnd: end,
                                      nowListenable: widget.nowListenable,
                                      onExpired: _onCountdownExpired,
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}