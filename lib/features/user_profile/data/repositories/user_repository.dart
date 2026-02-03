import 'package:animation/features/user_profile/data/models/user.dart';
import 'package:animation/features/user_profile/data/services/user_service.dart';
import 'package:animation/utils/result.dart';

/// 用户仓库接口
/// 定义了用户相关的业务数据操作方法
abstract interface class UserRepository {
  /// 获取用户信息
  Future<Result<User>> getUser(String userId);

  /// 更新用户信息
  Future<Result<User>> updateUser(User user);

  /// 删除用户
  Future<Result<void>> deleteUser(String userId);
}

/// 用户仓库实现
/// 作为服务层和业务逻辑层之间的桥梁
class UserRepositoryImpl implements UserRepository {
  final UserService _userService;

  UserRepositoryImpl({required UserService userService})
      : _userService = userService;

  @override
  Future<Result<User>> getUser(String userId) async {
    // 可以在这里添加额外的业务逻辑，如：
    // 1. 数据验证
    // 2. 缓存处理
    // 3. 日志记录
    // 4. 数据转换
    
    // 验证输入参数
    if (userId.isEmpty) {
      return Result.error(Exception('用户ID不能为空'));
    }
    
    // 调用服务层获取数据
    final result = await _userService.getUser(userId);
    
    // 可以在这里对结果进行处理或转换
    return result;
  }

  @override
  Future<Result<User>> updateUser(User user) async {
    // 验证用户数据
    if (user.id.isEmpty) {
      return Result.error(Exception('用户ID不能为空'));
    }
    
    if (user.name.isEmpty) {
      return Result.error(Exception('用户名不能为空'));
    }
    
    // 调用服务层更新数据
    final result = await _userService.updateUser(user);
    
    // 可以在这里添加更新后的处理逻辑，如：
    // 1. 清除相关缓存
    // 2. 发送通知
    // 3. 记录操作日志
    
    return result;
  }

  @override
  Future<Result<void>> deleteUser(String userId) async {
    // 验证输入参数
    if (userId.isEmpty) {
      return Result.error(Exception('用户ID不能为空'));
    }
    
    // 调用服务层删除数据
    final result = await _userService.deleteUser(userId);
    
    // 可以在这里添加删除后的处理逻辑，如：
    // 1. 清除相关缓存
    // 2. 发送通知
    // 3. 记录操作日志
    
    return result;
  }
}