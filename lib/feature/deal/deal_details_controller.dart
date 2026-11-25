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

  final deal = Rxn<DealModel>();
  final isLoading = true.obs;
  final loadFailed = false.obs;
  int? _dealId;

  final _serverQuantityLeft = 0.obs;
  final _inCartCount = 0.obs;

  int get quantityLeft =>
      (_serverQuantityLeft.value - _inCartCount.value).clamp(0, 9999);

  Worker? _cartWorker;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is DealModel) {
      _dealId = args.id;
      _setDeal(args);
    } else {
      _dealId = int.tryParse(Get.parameters['id'] ?? '');
      loadDeal();
    }
    _cartWorker = ever(cartService.itemCount, (_) => _onCartChanged());
  }

  void _setDeal(DealModel d) {
    deal.value = d;
    _serverQuantityLeft.value = d.quantityLeft;
    _inCartCount.value = cartService.quantityInCart(d.id);
    isLoading.value = false;
    loadFailed.value = false;
    analytics.logEvent('deal_details_view', {
      'deal_id': d.id,
      'source': Get.parameters['source'] ?? 'unknown',
    });
  }

  Future<void> loadDeal() async {
    final id = _dealId;
    if (id == null) {
      loadFailed.value = true;
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    loadFailed.value = false;
    try {
      final fetched = await dealRepo.fetchById(id);
      if (isClosed) return;
      _setDeal(fetched);
    } catch (e) {
      if (isClosed) return;
      LogService.log('failed to load deal $id: $e');
      loadFailed.value = true;
      isLoading.value = false;
    }
  }

  Future<void> _onCartChanged() async {
    final d = deal.value;
    if (isClosed || d == null) return;
    _inCartCount.value = cartService.quantityInCart(d.id);
    LogService.log('re-checking availability for deal ${d.id}');
    final fresh = await dealRepo.fetchById(d.id);
    if (isClosed) return;
    _serverQuantityLeft.value = fresh.quantityLeft;
  }

  @override
  void onClose() {
    _cartWorker?.dispose();
    super.onClose();
  }

  void addToCart() {
    final d = deal.value;
    if (d == null) return;
    cartService.add(d);
    Get.snackbar(
      'Added to bag',
      '${d.name} — pick up ${d.pickupWindow.label}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
