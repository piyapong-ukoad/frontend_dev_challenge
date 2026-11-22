import 'package:get/get.dart';

import '../../model/deal_model.dart';
import '../../repository/deal_repo.dart';
import '../../service/analytics_service.dart';
import '../../service/cart_service.dart';
import '../../util/log_service.dart';

class DealDetailsController extends GetxController {
  final DealRepo dealRepo;
  final CartService cartService;
  final AnalyticsService analytics;

  DealDetailsController({
    required this.dealRepo,
    required this.cartService,
    required this.analytics,
  });

  late final DealModel deal;

  final _serverQuantityLeft = 0.obs;
  final _inCartCount = 0.obs;

  int get quantityLeft =>
      (_serverQuantityLeft.value - _inCartCount.value).clamp(0, 9999);

  Worker? _cartWorker;

  @override
  void onInit() {
    super.onInit();
    deal = Get.arguments as DealModel;
    _serverQuantityLeft.value = deal.quantityLeft;
    _inCartCount.value = cartService.quantityInCart(deal.id);

    analytics.logEvent('deal_details_view', {
      'deal_id': deal.id,
      'source': Get.parameters['source'] ?? 'unknown',
    });

    _cartWorker = ever(cartService.itemCount, (_) => _onCartChanged());
  }

  Future<void> _onCartChanged() async {
    if (isClosed) return;
    _inCartCount.value = cartService.quantityInCart(deal.id);

    LogService.log('re-checking availability for deal ${deal.id}');
    final fresh = await dealRepo.fetchById(deal.id);
    if (isClosed) return;
    _serverQuantityLeft.value = fresh.quantityLeft;
  }

  @override
  void onClose() {
    _cartWorker?.dispose();
    super.onClose();
  }

  void addToCart() {
    cartService.add(deal);
    Get.snackbar(
      'Added to bag',
      '${deal.name} — pick up ${deal.pickupWindow.label}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
