import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kigali_directory/core/constants/app_colors.dart';
import 'package:kigali_directory/core/constants/app_strings.dart';
import 'package:kigali_directory/data/models/listing_model.dart';
import 'package:kigali_directory/presentation/providers/listing_provider.dart';
import 'package:kigali_directory/presentation/widgets/listing_card.dart';
import 'package:kigali_directory/presentation/screens/directory/listing_detail_screen.dart';
import 'listing_form_screen.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(myListingsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          AppStrings.myListings,
          style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: AppColors.primary, size: 28),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ListingFormScreen()),
            ),
          ),
        ],
      ),
      body: listingsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Error: $e',
                style: const TextStyle(color: AppColors.error))),
        data: (listings) {
          if (listings.isEmpty) {
            return _EmptyMyListings(
              onAdd: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ListingFormScreen()),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listings.length,
            itemBuilder: (ctx, i) => ListingCard(
              listing: listings[i],
              showActions: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        ListingDetailScreen(listing: listings[i])),
              ),
              onEdit: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        ListingFormScreen(existingListing: listings[i])),
              ),
              onDelete: () => _confirmDelete(context, ref, listings[i]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ListingFormScreen()),
        ),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(AppStrings.addListing,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, ListingModel listing) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.deleteListing),
        content: Text('Delete "${listing.name}"? ${AppStrings.confirmDelete}'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(AppStrings.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(listingNotifierProvider.notifier)
                  .delete(listing.id);
            },
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}

class _EmptyMyListings extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyMyListings({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add_location_alt_outlined,
              size: 72, color: AppColors.textHint),
          const SizedBox(height: 16),
          const Text(AppStrings.noMyListings,
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 15)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text(AppStrings.addListing),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
