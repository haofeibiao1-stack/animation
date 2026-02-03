import 'dart:async';
import 'package:animation/features/user_profile/data/models/user.dart';
import 'package:animation/utils/result.dart';

/// 用户服务接口
/// 定义了用户相关的数据操作方法
abstract interface class UserService {
  /// 获取用户信息
  Future<Result<User>> getUser(String userId);

  /// 更新用户信息
  Future<Result<User>> updateUser(User user);

  /// 删除用户
  Future<Result<void>> deleteUser(String userId);
}

/// 用户服务的内存实现（用于演示）
/// 在实际应用中，这可能会调用 REST API 或数据库
class UserServiceImpl implements UserService {
  // 模拟数据存储
  final Map<String, User> _users = {};
  
  // 模拟网络延迟
  static const Duration _networkDelay = Duration(milliseconds: 500);

  UserServiceImpl() {
    // 初始化一些示例数据
    _users['1'] = User(
      id: '1',
      name: '张三',
      email: 'zhangsan@example.com',
      avatarUrl: 'assets/images/ic_avatar_unlogged.svg',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
    
    _users['2'] = User(
      id: '2',
      name: '李四',
      email: 'lisi@example.com',
      avatarUrl: 'assets/images/ic_avatar_unlogged.svg',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    );
  }

  @override
  Future<Result<User>> getUser(String userId) async {
    // 模拟网络请求
    await Future.delayed(_networkDelay);
    
    try {
      // 模拟可能的网络错误
      if (userId.isEmpty) {
        return Result.error(Exception('用户ID不能为空'));
      }
      
      final user = _users[userId];
      if (user == null) {
        return Result.error(Exception('用户不存在'));
      }
      
      // 模拟 10% 的网络错误率
      if (DateTime.now().millisecondsSinceEpoch % 10 == 0) {
        return Result.error(Exception('网络连接失败'));
      }
      
      return Result.ok(user);
    } catch (e) {
      return Result.error(Exception('获取用户信息失败: $e'));
    }
  }

  @override
  Future<Result<User>> updateUser(User user) async {
    // 模拟网络请求
    await Future.delayed(_networkDelay);
    
    try {
      // 验证用户数据
      if (user.id.isEmpty) {
        return Result.error(Exception('用户ID不能为空'));
      }
      
      if (user.name.isEmpty) {
        return Result.error(Exception('用户名不能为空'));
      }
      
      if (user.email.isEmpty || !user.email.contains('@')) {
        return Result.error(Exception('邮箱格式不正确'));
      }
      
      // 更新用户信息
      _users[user.id] = user;
      return Result.ok(user);
    } catch (e) {
      return Result.error(Exception('更新用户信息失败: $e'));
    }
  }

  @override
  Future<Result<void>> deleteUser(String userId) async {
    // 模拟网络请求
    await Future.delayed(_networkDelay);
    
    try {
      if (userId.isEmpty) {
        return Result.error(Exception('用户ID不能为空'));
      }
      
      if (!_users.containsKey(userId)) {
        return Result.error(Exception('用户不存在'));
      }
      
      _users.remove(userId);
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('删除用户失败: $e'));
    }
  }
}