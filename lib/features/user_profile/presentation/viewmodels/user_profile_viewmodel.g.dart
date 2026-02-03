// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userServiceHash() => r'158da6f78e0c227d5668e0bbf9ab21a7d6bc855c';

/// 用户服务 Provider
///
/// Copied from [userService].
@ProviderFor(userService)
final userServiceProvider = AutoDisposeProvider<UserService>.internal(
  userService,
  name: r'userServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserServiceRef = AutoDisposeProviderRef<UserService>;
String _$userRepositoryHash() => r'62cfc2ed49db43d217a75dd73fa34f07ebc3b5a0';

/// 用户仓库 Provider
///
/// Copied from [userRepository].
@ProviderFor(userRepository)
final userRepositoryProvider = AutoDisposeProvider<UserRepository>.internal(
  userRepository,
  name: r'userRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserRepositoryRef = AutoDisposeProviderRef<UserRepository>;
String _$userProfileViewModelHash() =>
    r'21372613fc8bf851475affa9467db8680c71a6ea';

/// 用户信息页面的 ViewModel
/// 使用 @Riverpod(keepAlive: true) 保持状态在页面切换时不被销毁
///
/// Copied from [UserProfileViewModel].
@ProviderFor(UserProfileViewModel)
final userProfileViewModelProvider =
    NotifierProvider<UserProfileViewModel, UserProfileState>.internal(
      UserProfileViewModel.new,
      name: r'userProfileViewModelProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userProfileViewModelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$UserProfileViewModel = Notifier<UserProfileState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
