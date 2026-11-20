import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/features/trip_check/data/models/options/trip_selection_type.dart';
import 'package:plan_b/features/trip_check/presentation/providers/trip_check_draft_provider.dart';
import 'package:plan_b/features/trip_select/data/models/trip_plan.dart';
import 'package:plan_b/features/trip_select/data/repositories/trip_select_repository.dart';

/// 지갑 기준 여행 고르기의 [여행지 티켓 TOP 1~3순위]
/// - 재시도: ref.invalidate(walletRecommendationsProvider)
final walletRecommendationsProvider =
    FutureProvider.autoDispose<List<TripPlan>>((ref) {
  // planId / tripType이 바뀔 때만 다시 실행
  final planId = ref.watch(tripCheckDraftProvider.select((d) => d.planId));
  final tripType = ref.watch(tripCheckDraftProvider.select((d) => d.tripType));
  if (planId == null || tripType != TripSelectionType.budget) return const [];

  return ref.read(tripSelectRepositoryProvider).createWalletRecommendations(planId);
});