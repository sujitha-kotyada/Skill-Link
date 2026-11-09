import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';

class WorkerFilterSheet extends StatefulWidget {
  final String currentCategory;
  final String currentCity;
  final double? currentMaxRate;
  final double? currentMinRating;
  final String currentSortBy;
  final void Function({
    required String category,
    required String city,
    required double? maxRate,
    required double? minRating,
    required String sortBy,
  }) onApply;

  const WorkerFilterSheet({
    super.key,
    required this.currentCategory,
    required this.currentCity,
    required this.currentMaxRate,
    required this.currentMinRating,
    required this.currentSortBy,
    required this.onApply,
  });

  @override
  State<WorkerFilterSheet> createState() => _WorkerFilterSheetState();
}

class _WorkerFilterSheetState extends State<WorkerFilterSheet> {
  late String _selectedCategory;
  late double _maxRateSlider;
  late double _minRating;
  late String _sortBy;
  final _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.currentCategory;
    _cityController.text = widget.currentCity;
    _maxRateSlider = widget.currentMaxRate ?? 2500;
    _minRating = widget.currentMinRating ?? 0.0;
    _sortBy = widget.currentSortBy;
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter & Sort Workers',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.charcoal),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = 'All';
                      _cityController.clear();
                      _maxRateSlider = 2500;
                      _minRating = 0.0;
                      _sortBy = 'rating_desc';
                    });
                  },
                  child: const Text('Reset All'),
                ),
              ],
            ),
            const Divider(height: 24),

            // Service Category
            const Text('Service Category', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  items: ['All', ...AppConstants.serviceCategories].map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),

            // City Filter
            const Text('City / Region', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                hintText: 'e.g. Bengaluru, Mumbai, Delhi',
                prefixIcon: Icon(Icons.location_on_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 18),

            // Maximum Rate Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Maximum Rate (₹)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                Text(
                  'Up to ₹${_maxRateSlider.toInt()}',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryTeal),
                ),
              ],
            ),
            Slider(
              value: _maxRateSlider,
              min: 100,
              max: 5000,
              divisions: 49,
              activeColor: AppColors.primaryTeal,
              onChanged: (val) => setState(() => _maxRateSlider = val),
            ),
            const SizedBox(height: 12),

            // Minimum Rating
            const Text('Minimum Rating', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [0.0, 3.5, 4.0, 4.5].map((r) {
                final isSelected = _minRating == r;
                return ChoiceChip(
                  label: Text(r == 0.0 ? 'Any Rating' : '$r+ Stars'),
                  selected: isSelected,
                  selectedColor: AppColors.tealSurface,
                  onSelected: (val) {
                    setState(() => _minRating = r);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Sort By
            const Text('Sort Results By', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildSortChip('rating_desc', 'Highest Rated'),
                _buildSortChip('rate_asc', 'Price: Low to High'),
                _buildSortChip('experience_desc', 'Most Experienced'),
              ],
            ),
            const SizedBox(height: 28),

            AppButton(
              label: 'Apply Filters',
              icon: Icons.done_all_rounded,
              onPressed: () {
                widget.onApply(
                  category: _selectedCategory,
                  city: _cityController.text.trim(),
                  maxRate: _maxRateSlider,
                  minRating: _minRating > 0 ? _minRating : null,
                  sortBy: _sortBy,
                );
                Navigator.pop(context);
              },
              isFullWidth: true,
              variant: AppButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortChip(String value, String label) {
    final isSelected = _sortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.tealSurface,
      onSelected: (_) => setState(() => _sortBy = value),
    );
  }
}
