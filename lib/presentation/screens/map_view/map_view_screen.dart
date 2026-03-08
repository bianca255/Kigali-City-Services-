import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kigali_directory/core/constants/app_colors.dart';
import 'package:kigali_directory/core/constants/app_strings.dart';
import 'package:kigali_directory/core/constants/categories.dart';
import 'package:kigali_directory/data/models/listing_model.dart';
import 'package:kigali_directory/presentation/providers/listing_provider.dart';
import 'package:kigali_directory/presentation/screens/directory/listing_detail_screen.dart';

class MapViewScreen extends ConsumerStatefulWidget {
  const MapViewScreen({super.key});

  @override
  ConsumerState<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends ConsumerState<MapViewScreen> {
  ListingModel? _selected;

  // Kigali city centre
  static const LatLng _kigaliCenter = LatLng(-1.9441, 30.0619);

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(allListingsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          listingsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
                child: Text('Error: $e',
                    style: const TextStyle(color: AppColors.error))),
            data: (listings) {
              final markers = listings.map((l) {
                return Marker(
                  markerId: MarkerId(l.id),
                  position: LatLng(l.latitude, l.longitude),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      _markerHue(l.category)),
                  infoWindow: InfoWindow(
                    title: l.name,
                    snippet: l.category,
                  ),
                  onTap: () => setState(() => _selected = l),
                );
              }).toSet();

              return GoogleMap(
                initialCameraPosition:
                    const CameraPosition(target: _kigaliCenter, zoom: 13),
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                onMapCreated: (_) {},
                onTap: (_) => setState(() => _selected = null),
              );
            },
          ),
          // Top label
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.map_outlined,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  const Text(AppStrings.mapView,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                ],
              ),
            ),
          ),
          // Bottom card for selected listing
          if (_selected != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: _SelectedCard(
                listing: _selected!,
                onView: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          ListingDetailScreen(listing: _selected!)),
                ),
                onClose: () => setState(() => _selected = null),
              ),
            ),
        ],
      ),
    );
  }

  double _markerHue(String category) {
    const map = {
      'Hospital': BitmapDescriptor.hueRed,
      'Police Station': BitmapDescriptor.hueBlue,
      'Library': BitmapDescriptor.hueViolet,
      'Restaurant': BitmapDescriptor.hueOrange,
      'Café': BitmapDescriptor.hueRose,
      'Park': BitmapDescriptor.hueGreen,
      'Tourist Attraction': BitmapDescriptor.hueYellow,
      'Utility Office': BitmapDescriptor.hueCyan,
    };
    return map[category] ?? BitmapDescriptor.hueRed;
  }
}

class _SelectedCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onView;
  final VoidCallback onClose;

  const _SelectedCard(
      {required this.listing,
      required this.onView,
      required this.onClose});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(listing.category);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: AppColors.cardShadow, blurRadius: 16, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(AppCategories.iconFor(listing.category),
                  style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(listing.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(listing.address,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onView,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 0,
            ),
            child: const Text('View',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 18),
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
