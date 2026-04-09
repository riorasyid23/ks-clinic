import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medisify/presentation/widgets/app_bar_main.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/region_model.dart';
import '../widgets/bottom_nav_bar.dart';
import '../providers/search_providers.dart';

class SearchAppointmentsScreen extends ConsumerStatefulWidget {
  const SearchAppointmentsScreen({super.key});

  @override
  ConsumerState<SearchAppointmentsScreen> createState() =>
      _SearchAppointmentsScreenState();
}

class _SearchAppointmentsScreenState
    extends ConsumerState<SearchAppointmentsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final current = ref.read(doctorSearchParamsProvider);
    ref.read(doctorSearchParamsProvider.notifier).state =
        current.copyWith(searchQuery: query);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final regionsAsync = ref.watch(regionsProvider);
    final doctorsAsync = ref.watch(doctorsSearchResultProvider);
    final params = ref.watch(doctorSearchParamsProvider);

    final hasActiveFilters =
        params.specialties.isNotEmpty || params.availableToday;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBarMain(),
      body: Column(
        children: [
          // Search bar + Filter button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Search by doctor name',
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.onSurfaceVariant,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () => _showFilterModal(context, params),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: hasActiveFilters
                          ? AppColors.primary
                          : AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.tune,
                      color: hasActiveFilters
                          ? Colors.white
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Region dropdown
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: regionsAsync.when(
              loading: () => const SizedBox(
                height: 50,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (_, _) => const SizedBox.shrink(),
              data: (regions) => _RegionDropdown(
                regions: regions,
                selectedRegionId: params.regionId,
                onChanged: (regionId) {
                  final current = ref.read(doctorSearchParamsProvider);
                  ref.read(doctorSearchParamsProvider.notifier).state =
                      current.copyWith(regionId: regionId);
                },
              ),
            ),
          ),

          // Active filters indicator
          if (hasActiveFilters)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Row(
                children: [
                  Icon(Icons.filter_alt, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _buildFilterSummary(params),
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ref.read(doctorSearchParamsProvider.notifier).state =
                          DoctorSearchParams(
                        regionId: params.regionId,
                        searchQuery: params.searchQuery,
                      );
                    },
                    child: Text(
                      'Clear',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // Doctors list
          Expanded(
            child: doctorsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => _buildErrorState(textTheme),
              data: (doctors) {
                if (doctors.isEmpty) {
                  return _buildEmptyState(textTheme);
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(doctorsSearchResultProvider);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                    itemCount: doctors.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final doc = doctors[index];
                      return _buildDoctorCard(context, doc, textTheme);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildDoctorCard(
      BuildContext context, dynamic doc, TextTheme textTheme) {
    return GestureDetector(
      onTap: () => context.push('/doctor-details/${doc.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.15),
          ),
          boxShadow: AppColors.ambientShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doc.specialty,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  if (doc.city != null || doc.region != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            [doc.region, doc.city]
                                .where((e) => e != null)
                                .join(' • '),
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.outlineVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No doctors found',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.outlineVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load doctors',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => ref.invalidate(doctorsSearchResultProvider),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildFilterSummary(DoctorSearchParams params) {
    final parts = <String>[];
    if (params.specialties.isNotEmpty) {
      parts.add(params.specialties.join(', '));
    }
    if (params.availableToday) {
      parts.add('Available today');
    }
    return parts.join(' • ');
  }

  void _showFilterModal(BuildContext context, DoctorSearchParams params) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterModal(
        initialSpecialties: params.specialties,
        initialAvailableToday: params.availableToday,
        onApply: (specialties, availableToday) {
          final current = ref.read(doctorSearchParamsProvider);
          ref.read(doctorSearchParamsProvider.notifier).state =
              current.copyWith(
            specialties: specialties,
            availableToday: availableToday,
          );
        },
      ),
    );
  }
}

// ─── Region Dropdown ─────────────────────────────────────────────────────────

class _RegionDropdown extends StatelessWidget {
  final List<Region> regions;
  final String? selectedRegionId;
  final ValueChanged<String?> onChanged;

  const _RegionDropdown({
    required this.regions,
    required this.selectedRegionId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Build unique city entries: "All Cities" + each region
    final items = regions.map((r) => DropdownMenuItem(
          value: r.id,
          child: Text('${r.city} — ${r.name}'),
        )).toList();

    // Determine the value to show. If params has null, use the first region as default.
    final displayValue = (selectedRegionId == null || selectedRegionId!.isEmpty) 
        ? (regions.isNotEmpty ? regions.first.id : null)
        : selectedRegionId;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: displayValue,
                isExpanded: true,
                dropdownColor: AppColors.surfaceContainerLow,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.onSurfaceVariant,
                ),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                items: items,
                onChanged: (value) {
                  onChanged(value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Modal ────────────────────────────────────────────────────────────

class _FilterModal extends StatefulWidget {
  final List<String> initialSpecialties;
  final bool initialAvailableToday;
  final void Function(List<String> specialties, bool availableToday) onApply;

  const _FilterModal({
    required this.initialSpecialties,
    required this.initialAvailableToday,
    required this.onApply,
  });

  @override
  State<_FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<_FilterModal> {
  late Map<String, bool> _specialties;
  late bool _availableToday;

  static const _allSpecialties = [
    'Cardiology',
    'Neurology',
    'Pediatrics',
    'Dentistry',
    'Orthopedics',
    'Dermatology',
    'Surgery',
    'Biotechnology',
  ];

  @override
  void initState() {
    super.initState();
    _specialties = {
      for (final s in _allSpecialties)
        s: widget.initialSpecialties.contains(s),
    };
    _availableToday = widget.initialAvailableToday;
  }

  void _clearFilters() {
    setState(() {
      _specialties.updateAll((_, _) => false);
      _availableToday = false;
    });
  }

  void _applyFilters() {
    final selected = _specialties.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    widget.onApply(selected, _availableToday);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Doctors',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Specialties',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _specialties.keys.map((specialty) {
              final isSelected = _specialties[specialty]!;
              return FilterChip(
                showCheckmark: false,
                label: Text(specialty),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _specialties[specialty] = selected);
                },
                selectedColor: AppColors.primaryContainer,
                backgroundColor: AppColors.surfaceContainerLow,
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.outlineVariant.withValues(alpha: 0.3),
                ),
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppColors.primaryFixed
                      : AppColors.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text(
              'Available Today',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            value: _availableToday,
            onChanged: (value) => setState(() => _availableToday = value),
            contentPadding: EdgeInsets.zero,
            activeThumbColor: AppColors.primary,
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.outlineVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Clear Filter',
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply Filter',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
