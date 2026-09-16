import 'package:freelancer_app/Model/reviewMode.dart';
import 'package:freelancer_app/Singletones/common_functions.dart';
import 'package:freelancer_app/Utils/app_datetime.dart';
import 'package:freelancer_app/Utils/toastUtils.dart';
import 'package:freelancer_app/constants.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'calista_cafePage_controller.dart';

class ReviewPageController extends GetxController {
  late final CalistaCafePageController calistaCafePageController;
  RxList<ReviewModel> modelList = RxList();
  RxString totalRating = '0'.obs;
  RxInt totalElements = 0.obs;
  /// Counts for stars 5→1 used by the Figma breakdown bars.
  RxMap<int, int> ratingCounts = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0}.obs;

  @override
  void onInit() {
    super.onInit();
    calistaCafePageController = Get.find<CalistaCafePageController>();
    if (Get.arguments != null) {
      totalRating.value = '${Get.arguments[0]}';
      getReview('${Get.arguments[1]}');
    }
  }

  double get averageRating {
    final parsed = double.tryParse(totalRating.value) ?? 0;
    if (parsed > 0) return parsed;
    if (modelList.isEmpty) return 0;
    final sum = modelList.fold<int>(0, (s, e) => s + e.rating);
    return sum / modelList.length;
  }

  /// Newest review relative time for the "Updated …" label.
  String get updatedLabel {
    if (modelList.isEmpty) return '';
    DateTime? newest;
    for (final r in modelList) {
      final t = AppDateTime.parse(r.createdAt);
      if (t == null) continue;
      if (newest == null || t.isAfter(newest)) newest = t;
    }
    if (newest == null) return '';
    return 'Updated ${timeago.format(newest, allowFromNow: true)}';
  }

  double percentForStar(int star) {
    final total = totalElements.value;
    if (total <= 0) return 0;
    return (ratingCounts[star] ?? 0) / total;
  }

  Future<void> getReview(String stationId) async {
    showLoading(kLoading);
    final res = await CommonFunctions().getReviewOfStation(stationId);
    hideLoading();
    totalElements.value = res.length;
    modelList.value = res;
    _recomputeDistribution();
  }

  void _recomputeDistribution() {
    final counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in modelList) {
      final star = r.rating.clamp(1, 5);
      counts[star] = (counts[star] ?? 0) + 1;
    }
    ratingCounts.assignAll(counts);
  }

  String timeAgoFor(ReviewModel model) {
    final t = AppDateTime.parse(model.createdAt);
    if (t == null) return '';
    return timeago.format(t);
  }
}
