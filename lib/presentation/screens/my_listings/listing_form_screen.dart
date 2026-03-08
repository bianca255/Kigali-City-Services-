import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kigali_directory/core/constants/app_colors.dart';
import 'package:kigali_directory/core/constants/app_strings.dart';
import 'package:kigali_directory/core/constants/categories.dart';
import 'package:kigali_directory/core/utils/validators.dart';
import 'package:kigali_directory/data/models/listing_model.dart';
import 'package:kigali_directory/presentation/providers/auth_provider.dart';
import 'package:kigali_directory/presentation/providers/listing_provider.dart';

class ListingFormScreen extends ConsumerStatefulWidget {
  final ListingModel? existingListing;
  const ListingFormScreen({super.key, this.existingListing});

  @override
  ConsumerState<ListingFormScreen> createState() => _ListingFormScreenState();
}

class _ListingFormScreenState extends ConsumerState<ListingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  late String _category;
  bool _saving = false;
  bool _fetchingLocation = false;

  bool get _isEditing => widget.existingListing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existingListing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _addressCtrl = TextEditingController(text: e?.address ?? '');
    _contactCtrl = TextEditingController(text: e?.contactNumber ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _latCtrl = TextEditingController(
        text: e != null ? e.latitude.toString() : '');
    _lngCtrl = TextEditingController(
        text: e != null ? e.longitude.toString() : '');
    _category = e?.category ?? AppCategories.all.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _contactCtrl.dispose();
    _descCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    setState(() => _fetchingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services are disabled.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied.');
      }

      final pos = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high));
      _latCtrl.text = pos.latitude.toStringAsFixed(7);
      _lngCtrl.text = pos.longitude.toStringAsFixed(7);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _fetchingLocation = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final profile = ref.read(userProfileProvider).value!;
    final now = DateTime.now();
    final model = ListingModel(
      id: widget.existingListing?.id ?? '',
      name: _nameCtrl.text.trim(),
      category: _category,
      address: _addressCtrl.text.trim(),
      contactNumber: _contactCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      latitude: double.parse(_latCtrl.text.trim()),
      longitude: double.parse(_lngCtrl.text.trim()),
      createdBy: profile.uid,
      createdByName: profile.displayName,
      createdAt: widget.existingListing?.createdAt ?? now,
      updatedAt: _isEditing ? now : null,
    );

    bool success;
    if (_isEditing) {
      success = await ref
          .read(listingNotifierProvider.notifier)
          .update(model.id, model);
    } else {
      success =
          await ref.read(listingNotifierProvider.notifier).create(model);
    }

    if (mounted) {
      setState(() => _saving = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _isEditing ? 'Listing updated!' : 'Listing created!'),
            backgroundColor: AppColors.secondary,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.genericError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          _isEditing ? AppStrings.editListing : AppStrings.addListing,
          style: const TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        foregroundColor: AppColors.textPrimary,
        actions: [
          if (!_saving)
            TextButton(
              onPressed: _save,
              child: const Text(AppStrings.save,
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
            ),
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(14),
              child:
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionTitle('Basic Information'),
            const SizedBox(height: 12),
            _field(
                ctrl: _nameCtrl,
                label: AppStrings.placeName,
                icon: Icons.place_outlined,
                validator: Validators.required),
            const SizedBox(height: 16),
            _CategoryDropdown(
              value: _category,
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),
            _field(
                ctrl: _addressCtrl,
                label: AppStrings.address,
                icon: Icons.home_outlined,
                validator: Validators.required),
            const SizedBox(height: 16),
            _field(
                ctrl: _contactCtrl,
                label: AppStrings.contactNumber,
                icon: Icons.phone_outlined,
                keyboard: TextInputType.phone,
                validator: Validators.phone),
            const SizedBox(height: 16),
            _field(
                ctrl: _descCtrl,
                label: AppStrings.description,
                icon: Icons.description_outlined,
                maxLines: 4,
                validator: Validators.required),
            const SizedBox(height: 24),
            _SectionTitle('Location Coordinates'),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _fetchingLocation ? null : _getLocation,
              icon: _fetchingLocation
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location,
                      color: AppColors.primary),
              label: Text(
                _fetchingLocation
                    ? 'Getting location...'
                    : AppStrings.useMyLocation,
                style: const TextStyle(color: AppColors.primary),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _field(
                      ctrl: _latCtrl,
                      label: AppStrings.latitude,
                      icon: Icons.explore_outlined,
                      keyboard: const TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      validator: Validators.latitude),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                      ctrl: _lngCtrl,
                      label: AppStrings.longitude,
                      icon: Icons.explore_outlined,
                      keyboard: const TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      validator: Validators.longitude),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(
                        _isEditing
                            ? 'Update Listing'
                            : 'Create Listing',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    TextInputType? keyboard,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error)),
        floatingLabelStyle: const TextStyle(color: AppColors.primary),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary));
  }
}

class _CategoryDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  const _CategoryDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: AppStrings.category,
        prefixIcon: const Icon(Icons.category_outlined,
            color: AppColors.primary, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 2)),
        floatingLabelStyle: const TextStyle(color: AppColors.primary),
      ),
      items: AppCategories.all.map((c) {
        return DropdownMenuItem(
          value: c,
          child: Row(
            children: [
              Text(AppCategories.iconFor(c),
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(c,
                  style: const TextStyle(fontSize: 14)),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? AppStrings.fieldRequired : null,
    );
  }
}
