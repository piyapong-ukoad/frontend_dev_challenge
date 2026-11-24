import 'dart:async';

import 'package:flutter/material.dart';

class FlashDealCountdown extends StatefulWidget {
  const FlashDealCountdown({
    super.key,
    required this.dealEnd,
    required this.onExpired,
  });

  final DateTime dealEnd;
  final VoidCallback onExpired;

  @override
  State<FlashDealCountdown> createState() => _FlashDealCountdownState();
}

class _FlashDealCountdownState extends State<FlashDealCountdown> {
  Timer? _timer;
  String _text = '';
  bool _notifiedExpired = false;

  @override
  void initState() {
    super.initState();
    _updateCountdown(afterFrame: true);
    if (!_notifiedExpired) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(covariant FlashDealCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dealEnd != widget.dealEnd) {
      _timer?.cancel();
      _notifiedExpired = false;
      _updateCountdown(afterFrame: true);
      if (!_notifiedExpired) {
        _startTimer();
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown(afterFrame: false);
    });
  }

  void _updateCountdown({required bool afterFrame}) {
    final remaining = widget.dealEnd.difference(DateTime.now().toUtc());
    if (remaining.isNegative) {
      _timer?.cancel();
      if (mounted && _text != 'Expired') {
        setState(() {
          _text = 'Expired';
        });
      }
      if (!_notifiedExpired) {
        _notifiedExpired = true;
        if (afterFrame) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) widget.onExpired();
          });
        } else {
          widget.onExpired();
        }
      }
      return;
    }

    final h = remaining.inHours;
    final m = remaining.inMinutes % 60;
    final s = remaining.inSeconds % 60;
    final formatted = h > 0
        ? '${h}h ${m}m'
        : '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    if (mounted && formatted != _text) {
      setState(() {
        _text = formatted;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: _notifiedExpired ? Colors.grey.shade700 : Colors.red.shade700,
      ),
    );
  }
}
