import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/train_info.dart';
import '../services/train_service.dart';

class TrainSearchState {
  const TrainSearchState({this.loading = false, this.error, this.query = ''});

  final bool loading;
  final String? error;
  final String query;

  TrainSearchState copyWith({
    bool? loading,
    String? error,
    bool clearError = false,
    String? query,
  }) {
    return TrainSearchState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      query: query ?? this.query,
    );
  }
}

class TrainSearchController extends StateNotifier<TrainSearchState> {
  TrainSearchController() : super(const TrainSearchState());

  void setQuery(String value) {
    state = state.copyWith(query: value);
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(clearError: true);
    }
  }

  void clearQuery() {
    state = state.copyWith(query: '', clearError: true);
  }

  Future<TrainInfo?> search() async {
    final trainNo = state.query.trim();
    if (trainNo.isEmpty) {
      state = state.copyWith(error: 'Please enter a train number.');
      return null;
    }

    state = state.copyWith(loading: true, clearError: true);
    try {
      final info = await TrainService.fetchTrain(trainNo);
      return info;
    } on TrainServiceException catch (e) {
      state = state.copyWith(error: e.message);
      return null;
    } catch (_) {
      state = state.copyWith(error: 'Something went wrong. Please try again.');
      return null;
    } finally {
      state = state.copyWith(loading: false);
    }
  }
}

final trainSearchControllerProvider =
    StateNotifierProvider.autoDispose<TrainSearchController, TrainSearchState>(
      (ref) => TrainSearchController(),
    );
