import 'package:animation/features/user_profile/data/models/user.dart';
import 'package:animation/utils/command.dart';
import 'package:animation/utils/result.dart';

/// 用户信息页面的状态
/// 使用不可变状态模式，所有状态更新都返回新的状态实例
class UserProfileState {
  /// 当前用户信息
  final User? user;

  /// 加载用户信息的命令
  final Command<User> loadUserCommand;

  /// 更新用户信息的命令
  final Command1<User, User> updateUserCommand;

  /// 删除用户的命令
  final Command1<void, String> deleteUserCommand;

  /// 用户名输入值
  final String nameInput;

  /// 邮箱输入值
  final String emailInput;

  const UserProfileState({
    this.user,
    required this.loadUserCommand,
    required this.updateUserCommand,
    required this.deleteUserCommand,
    this.nameInput = '',
    this.emailInput = '',
  });

  /// 创建初始状态
  factory UserProfileState.initial({
    required Command<User> loadUserCommand,
    required Command1<User, User> updateUserCommand,
    required Command1<void, String> deleteUserCommand,
  }) {
    return UserProfileState(
      loadUserCommand: loadUserCommand,
      updateUserCommand: updateUserCommand,
      deleteUserCommand: deleteUserCommand,
    );
  }

  /// 复制状态并更新部分字段
  UserProfileState copyWith({
    User? user,
    Command<User>? loadUserCommand,
    Command1<User, User>? updateUserCommand,
    Command1<void, String>? deleteUserCommand,
    String? nameInput,
    String? emailInput,
  }) {
    return UserProfileState(
      user: user ?? this.user,
      loadUserCommand: loadUserCommand ?? this.loadUserCommand,
      updateUserCommand: updateUserCommand ?? this.updateUserCommand,
      deleteUserCommand: deleteUserCommand ?? this.deleteUserCommand,
      nameInput: nameInput ?? this.nameInput,
      emailInput: emailInput ?? this.emailInput,
    );
  }

  /// 是否正在加载
  bool get isLoading => loadUserCommand.running;

  /// 是否加载失败
  bool get hasError => loadUserCommand.failed;

  /// 错误信息
  Exception? get error => loadUserCommand.error;

  /// 是否正在更新
  bool get isUpdating => updateUserCommand.running;

  /// 是否正在删除
  bool get isDeleting => deleteUserCommand.running;

  /// 是否更新成功
  bool get isUpdateSuccessful => updateUserCommand.successful;

  /// 是否更新失败
  bool get isUpdateFailed => updateUserCommand.failed;

  /// 更新错误信息
  Exception? get updateError => updateUserCommand.error;
}