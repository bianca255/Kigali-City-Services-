import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/listing_model.dart';
import '../../data/services/listing_service.dart';
import 'auth_provider.dart';

// ── Service singleton ──────────────────────────────────────────────────────
final listingServiceProvider =
    Provider<ListingService>((ref) => ListingService());

// ── All listings stream ────────────────────────────────────────────────────
final allListingsStreamProvider =
    StreamProvider<List<ListingModel>>((ref) {
  return ref.watch(listingServiceProvider).watchAllListings();
});

// ── My listings stream ─────────────────────────────────────────────────────
final myListingsStreamProvider =
    StreamProvider<List<ListingModel>>((ref) {
  final uid =
      ref.watch(userProfileProvider).value?.uid ?? '';
  if (uid.isEmpty) return const Stream.empty();
  return ref.watch(listingServiceProvider).watchMyListings(uid);
});

// ── Search / filter state ──────────────────────────────────────────────────
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// ── Filtered listings (derived) ────────────────────────────────────────────
final filteredListingsProvider =
    Provider<AsyncValue<List<ListingModel>>>((ref) {
  final all = ref.watch(allListingsStreamProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final category = ref.watch(selectedCategoryProvider);

  return all.whenData((listings) {
    var filtered = listings;
    if (category != null && category.isNotEmpty) {
      filtered =
          filtered.where((l) => l.category == category).toList();
    }
    if (query.isNotEmpty) {
      filtered = filtered
          .where((l) =>
              l.name.toLowerCase().contains(query) ||
              l.address.toLowerCase().contains(query) ||
              l.category.toLowerCase().contains(query))
          .toList();
    }
    return filtered;
  });
});

// ── CRUD operations ────────────────────────────────────────────────────────
class ListingNotifier extends StateNotifier<AsyncValue<void>> {
  final ListingService _service;

  ListingNotifier(this._service) : super(const AsyncValue.data(null));

  Future<bool> create(ListingModel listing) async {
    state = const AsyncValue.loading();
    try {
      await _service.createListing(listing);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      return false;
    }
  }

  Future<bool> update(String id, ListingModel listing) async {
    state = const AsyncValue.loading();
    try {
      await _service.updateListing(id, listing);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      return false;
    }
  }

  Future<bool> delete(String id) async {
    state = const AsyncValue.loading();
    try {
      await _service.deleteListing(id);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      return false;
    }
  }
}

final listingNotifierProvider =
    StateNotifierProvider<ListingNotifier, AsyncValue<void>>(
  (ref) => ListingNotifier(ref.watch(listingServiceProvider)),
);
