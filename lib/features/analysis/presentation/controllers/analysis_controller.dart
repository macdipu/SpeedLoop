import 'package:get/get.dart';

import '../../../trip/data/repositories/trip_repository_impl.dart';
import '../../../trip/domain/entities/trip_entity.dart';
import '../../../trip/domain/repositories/trip_repository.dart';
import '../../domain/entities/analysis_entity.dart';
import '../../domain/services/trip_analyzer.dart';

class AnalysisController extends GetxController {
  AnalysisController({TripRepository? repository, TripAnalyzer? analyzer})
      : _repository = repository ?? TripRepositoryImpl(),
        _analyzer = analyzer ?? const TripAnalyzer();

  final TripRepository _repository;
  final TripAnalyzer _analyzer;

  final selectedTrip = Rxn<TripEntity>();
  final analysisResult = Rxn<TripAnalysisEntity>();
  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> analyzeTrip(int tripId) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      selectedTrip.value = await _repository.getTripById(tripId);
      final trip = selectedTrip.value;
      analysisResult.value = trip == null ? null : _analyzer.analyze(trip);
    } catch (error) {
      analysisResult.value = null;
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
