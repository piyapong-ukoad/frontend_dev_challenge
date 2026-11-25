import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:rescu/service/analytics_service.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ImpressionTracker extends StatefulWidget {
  const ImpressionTracker({
    super.key,
    required this.dealId,
    required this.source,
    required this.position,
    required this.child,
  });

  final int dealId;
  final String source;
  final int position;
  final Widget child;

  @override
  State<ImpressionTracker> createState() => _ImpressionTrackerState();
}

class _ImpressionTrackerState extends State<ImpressionTracker> {
  Timer? _timer;

  void _onVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction >= 0.5) {
      _timer ??= Timer(const Duration(seconds: 1), _onVisibleLongEnough);
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _onVisibleLongEnough() {
    _timer = null;
    Get.find<AnalyticsService>().trackDealImpression(
      dealId: widget.dealId,
      source: widget.source,
      position: widget.position,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey('impression-${widget.source}-${widget.dealId}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: widget.child,
    );
  }
}
