import 'dart:async';

import 'package:get/get.dart';

import '../model/cart_item_model.dart';
import '../model/deal_model.dart';
import '../util/log_service.dart';

/// App-wide cart. Lives for the whole session.
///
/// NOTE: the starter cart is purely local — it does not reserve stock on the
/// backend. See the "Reservations" feature task in PROBLEM.md.
class CartService extends GetxService {
  final items = <CartItemModel>[].obs;
  final itemCount = 0.obs;

  Timer? _expirySnackbarTimer;
  int _expiredRemovedCount = 0;

  void removeExpiredDeal(int dealId) {
    final removedCount = items
        .where((i) => i.deal.id == dealId)
        .fold(0, (sum, i) => sum + i.quantity);

    if (removedCount <= 0) return;

    items.removeWhere((i) => i.deal.id == dealId);
    _recount();

    _expiredRemovedCount += removedCount;
    _expirySnackbarTimer?.cancel();
    _expirySnackbarTimer = Timer(const Duration(milliseconds: 300), () {
      final count = _expiredRemovedCount;
      _expiredRemovedCount = 0;

      Get.snackbar(
        'Flash sale expired',
        count == 1
            ? 'An expired flash deal was removed from your bag.'
            : '$count expired flash deals were removed from your bag.',
        snackPosition: SnackPosition.BOTTOM,
      );
    });
  }

  @override
  void onClose() {
    _expirySnackbarTimer?.cancel();
    super.onClose();
  }

  void add(DealModel deal) {
    final existing = items.firstWhereOrNull((i) => i.deal.id == deal.id);
    if (existing != null) {
      if (existing.quantity >= deal.quantityLeft) {
        LogService.log('cart: cannot add more of deal ${deal.id}');
        return;
      }
      existing.quantity++;
      items.refresh();
    } else {
      items.add(CartItemModel(deal: deal));
    }
    _recount();
  }

  void decrement(int dealId) {
    final existing = items.firstWhereOrNull((i) => i.deal.id == dealId);
    if (existing == null) return;
    existing.quantity--;
    if (existing.quantity <= 0) {
      items.removeWhere((i) => i.deal.id == dealId);
    } else {
      items.refresh();
    }
    _recount();
  }

  void remove(int dealId) {
    items.removeWhere((i) => i.deal.id == dealId);
    _recount();
  }

  void clear() {
    items.clear();
    _recount();
  }

  num get total => items.fold(0, (sum, i) => sum + i.lineTotal);

  void _recount() {
    itemCount.value = items.fold(0, (sum, i) => sum + i.quantity);
  }

  int quantityInCart(int dealId) {
    return items
        .where((item) => item.deal.id == dealId)
        .fold(0, (sum, item) => sum + item.quantity);
  }
}
