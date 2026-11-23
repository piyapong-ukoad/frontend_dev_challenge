import 'dart:async';

import 'package:flutter/material.dart';

class FlashDealCountdown extends StatefulWidget {
  const FlashDealCountdown({super.key, required this.dealEnd});
  final DateTime dealEnd;

  @override
  State<FlashDealCountdown> createState() => _FlashDealCountdownState();
}

class _FlashDealCountdownState extends State<FlashDealCountdown> {
  Timer? _timer;
  String _text = '';

  @override
  void initState() {
    _updateCountdown();
    _startTimer();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FlashDealCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dealEnd != widget.dealEnd) {
      _timer?.cancel();
      _updateCountdown();
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    final remaining = widget.dealEnd.difference(DateTime.now().toUtc());
    if (remaining.isNegative) {
      _timer?.cancel();
      if (mounted) {
        setState(() {
          _text = 'Expired';
        });
      }
      return;
    }

    final h = remaining.inHours;
    final m = remaining.inMinutes % 60;
    final s = remaining.inSeconds % 60;
    final formatted = h > 0
        ? '${h}h ${m}m'
        : '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    if (mounted) {
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
        color: Colors.red.shade700,
      ),
    );
  }
}
