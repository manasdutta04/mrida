import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mandi_price.dart';
import '../services/mandi_service.dart';
import 'user_provider.dart';
import 'scan_provider.dart';

final mandiServiceProvider = Provider((ref) => MandiService());

class MandiNotifier extends StateNotifier<AsyncValue<List<MandiPrice>>> {
  final Ref _ref;
  String? _currentState;
  String? _currentCommodity;

  MandiNotifier(this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    _currentState = null;
    _currentCommodity = null;

    await fetchPrices(state: _currentState, commodity: _currentCommodity);
  }

  Future<void> fetchPrices({String? state, String? commodity}) async {
    final newState = state ?? _currentState;
    final newCommodity = commodity ?? _currentCommodity;
    
    _currentState = newState;
    _currentCommodity = newCommodity;

    this.state = const AsyncValue.loading();
    try {
      final prices = await _ref.read(mandiServiceProvider).fetchPrices(
        state: newState,
        commodity: newCommodity,
      );
      this.state = AsyncValue.data(prices);
    } catch (e, st) {
      this.state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await fetchPrices(state: _currentState, commodity: _currentCommodity);
  }

  Future<void> clearFilters() async {
    _currentState = null;
    _currentCommodity = null;
    await fetchPrices(state: '', commodity: '');
  }

  String? get currentState => _currentState;
  String? get currentCommodity => _currentCommodity;
}

final mandiProvider = StateNotifierProvider<MandiNotifier, AsyncValue<List<MandiPrice>>>((ref) {
  return MandiNotifier(ref);
});
