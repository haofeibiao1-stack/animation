import 'package:animation/features/user_profile/data/models/user.dart';
import 'package:animation/features/user_profile/data/repositories/user_repository.dart';
import 'package:animation/features/user_profile/data/services/user_service.dart';
import 'package:animation/features/user_profile/presentation/viewmodels/user_profile_state.dart';
import 'package:animation/utils/command.dart';
import 'package:animation/utils/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_profile_viewmodel.g.dart';

/// 用户服务 Provider
@riverpod
UserService userService(UserServiceRef ref) {
  return UserServiceImpl();
}

/// 用户仓库 Provider
@riverpod
UserRepository userRepository(UserRepositoryRef ref) {
  final userService = ref.watch(userServiceProvider);
  return UserRepositoryImpl(userService: userService);
}

/// 用户信息页面的 ViewModel
/// 使用 @Riverpod(keepAlive: true) 保持状态在页面切换时不被销毁
@Riverpod(keepAlive: true)
class UserProfileViewModel extends _$UserProfileViewModel {
  late Command<User> _loadUserCommand;
  late Command1<User, User> _updateUserCommand;
  late Command1<void, String> _deleteUserCommand;

  @override
  UserProfileState build() {
    // 获取 Repository
    final userRepository = ref.watch(userRepositoryProvider);

    // 初始化命令
    _loadUserCommand = Command<User>(
      action: () => userRepository.getUser('1'),
    );

    _updateUserCommand = Command1<User, User>(
      action: (User user) => userRepository.updateUser(user),
    );

    _deleteUserCommand = Command1<void, String>(
      action: (String userId) => userRepository.deleteUser(userId),
    );

    // 监听命令状态变化
    _loadUserCommand.addListener(_onLoadUserCommandChanged);
    _updateUserCommand.addListener(_onUpdateUserCommandChanged);
    _deleteUserCommand.addListener(_onDeleteUserCommandChanged);

    // 返回初始状态
    return UserProfileState.initial(
      loadUserCommand: _loadUserCommand,
      updateUserCommand: _updateUserCommand,
      deleteUserCommand: _deleteUserCommand,
    );
  }

  /// 加载用户信息命令状态变化回调
  void _onLoadUserCommandChanged() {
    if (_loadUserCommand.completed) {
      _loadUserCommand.result!.when(
        ok: (User user) {
          state = state.copyWith(
            user: user,
            nameInput: user.name,
            emailInput: user.email,
          );
        },
        error: (Exception error) {
          state = state.copyWith(user: null);
        },
      );
    }
  }

  /// 更新用户信息命令状态变化回调
  void _onUpdateUserCommandChanged() {
    if (_updateUserCommand.completed) {
      _updateUserCommand.result!.when(
        ok: (User user) {
          state = state.copyWith(
            user: user,
            nameInput: user.name,
            emailInput: user.email,
          );
        },
        error: (Exception error) {
          // 处理更新失败的情况
        },
      );
    }
  }

  /// 删除用户命令状态变化回调
  void _onDeleteUserCommandChanged() {
    if (_deleteUserCommand.completed) {
      _deleteUserCommand.result!.when(
        ok: (void _) {
          state = state.copyWith(
            user: null,
            nameInput: '',
            emailInput: '',
          );
        },
        error: (Exception error) {
          // 处理删除失败的情况
        },
      );
    }
  }

  /// 加载用户信息
  Future<void> loadUser(String userId) async {
    await _loadUserCommand.execute();
  }

  /// 更新用户名输入
  void updateNameInput(String name) {
    state = state.copyWith(nameInput: name);
  }

  /// 更新邮箱输入
  void updateEmailInput(String email) {
    state = state.copyWith(emailInput: email);
  }

  /// 更新用户信息
  Future<void> updateUser() async {
    if (state.user == null) return;

    final updatedUser = state.user!.copyWith(
      name: state.nameInput,
      email: state.emailInput,
    );

    await _updateUserCommand.execute(updatedUser);
  }

  /// 删除用户
  Future<void> deleteUser() async {
    if (state.user == null) return;
    await _deleteUserCommand.execute(state.user!.id);
  }

  /// 重置 ViewModel 状态
  void reset() {
    state = state.copyWith(
      user: null,
      nameInput: '',
      emailInput: '',
    );
    _loadUserCommand.reset();
    _updateUserCommand.reset();
    _deleteUserCommand.reset();
  }
}