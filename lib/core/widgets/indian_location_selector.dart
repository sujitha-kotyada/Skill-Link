import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/indian_locations.dart';

/// Reusable Indian State and City dependent dropdown selector.
/// Adheres strictly to the Skill-Link design system with responsive layouts,
/// clean form validation, legacy value preservation, and state-city cascading.
class IndianLocationSelector extends StatefulWidget {
  final String? initialSelectedState;
  final String? initialSelectedCity;
  final ValueChanged<String?> onStateChanged;
  final ValueChanged<String?> onCityChanged;
  final bool isRequired;
  final String stateLabel;
  final String cityLabel;
  final String stateHint;
  final String cityHint;
  final String cityDisabledHint;

  const IndianLocationSelector({
    super.key,
    this.initialSelectedState,
    this.initialSelectedCity,
    required this.onStateChanged,
    required this.onCityChanged,
    this.isRequired = true,
    this.stateLabel = 'State / Union Territory',
    this.cityLabel = 'City / Town',
    this.stateHint = 'Select State / UT',
    this.cityHint = 'Select City / Town',
    this.cityDisabledHint = 'Select State first',
  });

  @override
  State<IndianLocationSelector> createState() => _IndianLocationSelectorState();
}

class _IndianLocationSelectorState extends State<IndianLocationSelector> {
  String? _currentState;
  String? _currentCity;

  @override
  void initState() {
    super.initState();
    _initStateAndCity(widget.initialSelectedState, widget.initialSelectedCity);
  }

  void _initStateAndCity(String? state, String? city) {
    final cleanState = (state != null && state.trim().isNotEmpty) ? state.trim() : null;
    final cleanCity = (city != null && city.trim().isNotEmpty) ? city.trim() : null;

    _currentState = cleanState;
    if (cleanState != null) {
      _currentCity = cleanCity;
    } else {
      _currentCity = null;
    }
  }

  @override
  void didUpdateWidget(covariant IndianLocationSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSelectedState != oldWidget.initialSelectedState ||
        widget.initialSelectedCity != oldWidget.initialSelectedCity) {
      _initStateAndCity(widget.initialSelectedState, widget.initialSelectedCity);
    }
  }

  void _handleStateSelected(String? newState) {
    if (newState == _currentState) return;

    setState(() {
      _currentState = newState;
      _currentCity = null; // Always reset city when state changes
    });

    widget.onStateChanged(newState);
    widget.onCityChanged(null);
  }

  void _handleCitySelected(String? newCity) {
    setState(() {
      _currentCity = newCity;
    });
    widget.onCityChanged(newCity);
  }

  @override
  Widget build(BuildContext context) {
    final availableStates = IndianLocations.getAvailableStates(_currentState);
    final availableCities = IndianLocations.getAvailableCities(_currentState, _currentCity);
    final isCityEnabled = _currentState != null && _currentState!.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 520;

        final stateField = _buildDropdownField(
          label: widget.stateLabel,
          hint: widget.stateHint,
          icon: Icons.map_outlined,
          value: _currentState,
          items: availableStates,
          isEnabled: true,
          onChanged: _handleStateSelected,
          validator: widget.isRequired
              ? (val) => (val == null || val.trim().isEmpty) ? 'Please select a state' : null
              : null,
        );

        final cityField = _buildDropdownField(
          label: widget.cityLabel,
          hint: isCityEnabled ? widget.cityHint : widget.cityDisabledHint,
          icon: Icons.location_city_rounded,
          value: _currentCity,
          items: availableCities,
          isEnabled: isCityEnabled,
          onChanged: isCityEnabled ? _handleCitySelected : null,
          validator: widget.isRequired
              ? (val) => (val == null || val.trim().isEmpty) ? 'Please select a city' : null
              : null,
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: stateField),
              const SizedBox(width: 16),
              Expanded(child: cityField),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              stateField,
              const SizedBox(height: 16),
              cityField,
            ],
          );
        }
      },
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required bool isEnabled,
    required ValueChanged<String?>? onChanged,
    required String? Function(String?)? validator,
  }) {
    // If value is not empty and not in items list, make sure it is included to prevent Flutter dropdown runtime crash
    final effectiveItems = (value != null && value.isNotEmpty && !items.contains(value))
        ? [value, ...items]
        : items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          key: ValueKey('${label}_$value'),
          initialValue: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isEnabled ? AppColors.charcoal : AppColors.secondaryGrey.withAlpha(120),
          ),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isEnabled ? AppColors.charcoal : AppColors.secondaryGrey,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              size: 20,
              color: isEnabled ? AppColors.secondaryGrey : AppColors.secondaryGrey.withAlpha(120),
            ),
            filled: true,
            fillColor: isEnabled ? AppColors.white : AppColors.borderGrey.withAlpha(70),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderGrey),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderGrey.withAlpha(100)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.errorRed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
            ),
          ),
          dropdownColor: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          menuMaxHeight: 350,
          items: isEnabled
              ? effectiveItems.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
                    ),
                  );
                }).toList()
              : null,
          onChanged: isEnabled ? onChanged : null,
          validator: validator,
        ),
      ],
    );
  }
}
