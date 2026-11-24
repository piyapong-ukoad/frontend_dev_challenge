import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FlashDealCountdown extends StatefulWidget {
  const FlashDealCountdown({
    super.key,
    required this.dealEnd,
    required this.nowListenable,
    this.onExpired,
  });

  final DateTime dealEnd;
  final ValueListenable<DateTime> nowListenable;
  final VoidCallback? onExpired;

  @override
  State<FlashDealCountdown> createState() => _FlashDealCountdownState();
}

class _FlashDealCountdownState extends State<FlashDealCountdown> {
  bool _expiredNotified = false;

  @override
  void didUpdateWidget(covariant FlashDealCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dealEnd != widget.dealEnd) {
      _expiredNotified = false;
    }
  }

  String _formatDuration(Duration remaining) {
    if (remaining <= Duration.zero) {
      return 'Expired';
    }
    final hours = remaining.inHours;
    final minutes =
        remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(
      valueListenable: widget.nowListenable,
      builder: (context, now, _) {
        final remaining = widget.dealEnd.difference(now);
        final expired = remaining <= Duration.zero;

        if (expired && !_expiredNotified) {
          _expiredNotified = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) widget.onExpired?.call();
          });
        }

        return Text(
          _formatDuration(remaining),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: expired ? Colors.grey.shade600 : Colors.red.shade700,
          ),
        );
      },
    );
  }
}
