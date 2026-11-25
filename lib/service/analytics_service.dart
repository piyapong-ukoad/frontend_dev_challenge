import 'dart:async';

import 'package:get/get.dart';

import '../util/log_service.dart';

class AnalyticsEvent {
  final String name;
  final Map<String, dynamic> properties;
  final DateTime at;

  AnalyticsEvent(this.name, this.properties) : at = DateTime.now();

  Map<String, dynamic> toJson() => {
        'name': name,
        'properties': properties,
        'at': at.toIso8601String(),
      };

  @override
  String toString() {
    return 'AnalyticsEvent(name: $name, at: $at, properties: $properties)';
  }
}

/// In-memory analytics sink. Events are visible on the debug screen
/// (overflow menu on Home -> "Analytics debug") and in the console.
///
/// The "Impression tracking" feature task builds on top of this service.
class AnalyticsService extends GetxService {
  final events = <AnalyticsEvent>[].obs;

  final _seenDealIds = <int>{};
  final _pending = <AnalyticsEvent>[];
  Timer? _flushTimer;

  static const _batchSize = 10;
  static const _maxWait = Duration(seconds: 15);

  AnalyticsEvent logEvent(String name,
      [Map<String, dynamic> properties = const {}]) {
    final event = AnalyticsEvent(name, properties);
    events.add(event);
    LogService.log('analytics: $name $properties');
    return event;
  }

  void trackDealImpression({
    required int dealId,
    required String source,
    required int position,
  }) {
    if (!_seenDealIds.add(dealId)) return;

    final event = logEvent('deal_impression', {
      'deal_id': dealId,
      'source': source,
      'position': position,
    });
    _pending.add(event);

    if (_pending.length >= _batchSize) {
      _flush();
    } else {
      _flushTimer ??= Timer(_maxWait, _flush);
    }
  }

  Future<void> _flush() async {
    _flushTimer?.cancel();
    _flushTimer = null;
    if (_pending.isEmpty) return;

    final batch = List<AnalyticsEvent>.of(_pending);
    _pending.clear();
    logEvent('barch data $batch');
  }

  @override
  void onClose() {
    _flushTimer?.cancel();
    super.onClose();
  }
}
