// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$upcomingAppointmentsHash() =>
    r'79ac0ac6f3173d9439988580df09ee60e0e0c0fb';

/// See also [upcomingAppointments].
@ProviderFor(upcomingAppointments)
final upcomingAppointmentsProvider =
    AutoDisposeProvider<List<Appointment>>.internal(
      upcomingAppointments,
      name: r'upcomingAppointmentsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$upcomingAppointmentsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpcomingAppointmentsRef = AutoDisposeProviderRef<List<Appointment>>;
String _$recommendedDoctorsHash() =>
    r'23e69e764ec71d91faf62d35849c129e1391fcdd';

/// See also [recommendedDoctors].
@ProviderFor(recommendedDoctors)
final recommendedDoctorsProvider = AutoDisposeProvider<List<Doctor>>.internal(
  recommendedDoctors,
  name: r'recommendedDoctorsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recommendedDoctorsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecommendedDoctorsRef = AutoDisposeProviderRef<List<Doctor>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
