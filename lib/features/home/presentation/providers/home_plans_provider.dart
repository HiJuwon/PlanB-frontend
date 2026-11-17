import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plan_b/features/home/data/models/trip_plan_summary.dart';
import 'package:plan_b/features/home/data/repositories/home_repository.dart';

final homePlansProvider = FutureProvider<List<TripPlanSummary>>((ref) {
  return ref.read(homeRepositoryProvider).getMyPlans();
});