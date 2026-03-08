import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:kigali_directory/core/constants/app_colors.dart';
import 'package:kigali_directory/core/constants/app_strings.dart';
import 'package:kigali_directory/core/constants/categories.dart';
import 'package:kigali_directory/data/models/listing_model.dart';
import 'package:kigali_directory/presentation/providers/auth_provider.dart';
import 'package:kigali_directory/presentation/providers/listing_provider.dart';
import 'package:kigali_directory/presentation/screens/my_listings/listing_form_screen.dart';

class ListingDetailScreen extends ConsumerWidget {
  final ListingModel listing;
  const ListingDetailScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(userProfileProvider).value?.uid ?? '';
    final isOwner = listing.createdBy == uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: _MapHero(
                  lat: listing.latitude, lng: listing.longitude),
            ),
            actions: [
              if (isOwner) ...[
                IconButton(
                  icon:
                      const Icon(Icons.edit_outlined, color: Colors.white),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            ListingFormScreen(existingListing: listing)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.white),
                  onPressed: () =>
                      _confirmDelete(context, ref, listing.id),
                ),
              ],
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryBadge(listing.category),
                  const SizedBox(height: 12),
                  Text(listing.name,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 20),
                  _InfoRow(
                      icon: Icons.location_on_outlined,
                      text: listing.address),
                  const SizedBox(height: 10),
                  _InfoRow(
                      icon: Icons.phone_outlined,
                      text: listing.contactNumber,
                      tappable: true,
                      onTap: () => _call(listing.contactNumber)),
                  const SizedBox(height: 20),
                  const Text('Description',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text(listing.description,
                      style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.6)),
                  const SizedBox(height: 20),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 12),
                  _CoordinatesCard(lat: listing.latitude, lng: listing.longitude),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 16, color: AppColors.textHint),
                      const SizedBox(width: 6),
                      Text('Added by ${listing.createdByName}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textHint)),
                      const Spacer(),
                      Text(
                          DateFormat('MMM d, yyyy')
                              .format(listing.createdAt),
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textHint)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _NavigateButton(
                      lat: listing.latitude, lng: listing.longitude),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
    final color = AppColors.categoryColor(category);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppCategories.iconFor(category),
                  style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(category,
                  style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  void _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.deleteListing),
        content: const Text(AppStrings.confirmDelete),
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
                  .delete(id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}

class _MapHero extends StatefulWidget {
  final double lat;
  final double lng;
  const _MapHero({required this.lat, required this.lng});

  @override
  State<_MapHero> createState() => _MapHeroState();
}

class _MapHeroState extends State<_MapHero> {
  @override
  Widget build(BuildContext context) {
    final position = LatLng(widget.lat, widget.lng);
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: position, zoom: 15),
      markers: {
        Marker(markerId: const MarkerId('place'), position: position)
      },
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool tappable;
  final VoidCallback? onTap;

  const _InfoRow(
      {required this.icon,
      required this.text,
      this.tappable = false,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tappable ? onTap : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 14,
                    color: tappable
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    decoration: tappable
                        ? TextDecoration.underline
                        : null)),
          ),
        ],
      ),
    );
  }
}

class _CoordinatesCard extends StatelessWidget {
  final double lat;
  final double lng;
  const _CoordinatesCard({required this.lat, required this.lng});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.my_location_outlined,
              size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            'Lat: ${lat.toStringAsFixed(6)},  Lng: ${lng.toStringAsFixed(6)}',
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}

class _NavigateButton extends StatelessWidget {
  final double lat;
  final double lng;
  const _NavigateButton({required this.lat, required this.lng});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.directions_outlined, size: 20),
        label: const Text(AppStrings.navigate,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: () async {
          final uri = Uri.parse(
              'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
          if (await canLaunchUrl(uri)) {
            launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
      ),
    );
  }
}
