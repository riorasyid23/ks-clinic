import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/region_model.dart';
import '../../data/models/doctor_result_model.dart';
import '../../data/models/doctor_detail_model.dart';
import '../../data/repositories/search_repository.dart';

/// Provides the singleton [SearchRepository].
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository();
});

/// Fetches all clinic regions from the API.
final regionsProvider = FutureProvider<List<Region>>((ref) async {
  final repo = ref.read(searchRepositoryProvider);
  return repo.getRegions();
});

/// Holds the current search/filter parameters.
class DoctorSearchParams {
  final String? regionId;
  final List<String> specialties;
  final bool availableToday;
  final String searchQuery;

  const DoctorSearchParams({
    this.regionId,
    this.specialties = const [],
    this.availableToday = false,
    this.searchQuery = '',
  });

  DoctorSearchParams copyWith({
    String? regionId,
    List<String>? specialties,
    bool? availableToday,
    String? searchQuery,
  }) {
    return DoctorSearchParams(
      regionId: regionId ?? this.regionId,
      specialties: specialties ?? this.specialties,
      availableToday: availableToday ?? this.availableToday,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// State provider for search parameters so the UI can modify them.
final doctorSearchParamsProvider =
    StateProvider<DoctorSearchParams>((ref) => const DoctorSearchParams());

/// Fetches doctors based on the current search parameters.
/// Automatically re-fetches when params change.
final doctorsSearchResultProvider =
    FutureProvider<List<DoctorResult>>((ref) async {
  final params = ref.watch(doctorSearchParamsProvider);
  final repo = ref.read(searchRepositoryProvider);

  String? effectiveRegionId = params.regionId;

  // If no region is explicitly selected, use the first one from regionsProvider
  if (effectiveRegionId == null || effectiveRegionId.isEmpty) {
    final regions = await ref.watch(regionsProvider.future);
    if (regions.isNotEmpty) {
      effectiveRegionId = regions.first.id;
    }
  }

  if (effectiveRegionId == null) {
    return [];
  }

  final doctors = await repo.getDoctors(
    regionId: effectiveRegionId,
    specialties:
        params.specialties.isNotEmpty ? params.specialties.join(',') : null,
    availableToday: params.availableToday,
  );

  // Client-side filtering by doctor name search query
  if (params.searchQuery.isEmpty) return doctors;

  return doctors
      .where((d) =>
          d.name.toLowerCase().contains(params.searchQuery.toLowerCase()))
      .toList();
});

/// Fetches detailed information about a doctor by their ID.
final doctorDetailsProvider =
    FutureProvider.family<DoctorDetail, String>((ref, doctorId) async {
  final repo = ref.read(searchRepositoryProvider);
  return repo.getDoctorDetails(doctorId);
});

/// Parameters for fetching doctor slots.
class DoctorSlotParams {
  final String doctorProfileId;
  final String date;

  const DoctorSlotParams({
    required this.doctorProfileId,
    required this.date,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoctorSlotParams &&
          runtimeType == other.runtimeType &&
          doctorProfileId == other.doctorProfileId &&
          date == other.date;

  @override
  int get hashCode => doctorProfileId.hashCode ^ date.hashCode;
}

/// Fetches available slots for a doctor on a specific date.
final doctorSlotsProvider =
    FutureProvider.family<SlotResult, DoctorSlotParams>((ref, params) async {
  final repo = ref.read(searchRepositoryProvider);
  return repo.getDoctorSlots(
    doctorProfileId: params.doctorProfileId,
    date: params.date,
  );
});
