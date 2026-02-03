import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animation/features/user_profile/presentation/viewmodels/user_profile_viewmodel.dart';
import 'package:animation/features/user_profile/presentation/viewmodels/user_profile_state.dart';

/// 用户信息页面 (View)
/// 负责显示用户信息和响应用户交互
class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听 ViewModel 状态变化
    final viewModelState = ref.watch(userProfileViewModelProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户信息'),
        centerTitle: true,
        actions: [
          // 刷新按钮
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(userProfileViewModelProvider.notifier).loadUser('1');
            },
          ),
        ],
      ),
      body: _buildBody(ref, viewModelState),
    );
  }

  Widget _buildBody(WidgetRef ref, UserProfileState state) {
    // 显示加载状态
    if (state.loadUserCommand.running) {
      return const _LoadingWidget();
    }

    // 显示错误状态
    if (state.loadUserCommand.failed) {
      return _ErrorWidget(
        error: state.loadUserCommand.error?.toString() ?? '未知错误',
        onRetry: () => ref.read(userProfileViewModelProvider.notifier).loadUser('1'),
      );
    }

    // 显示用户信息
    if (state.user != null) {
      return _UserProfileContent(state: state);
    }

    // 空状态
    return const _EmptyWidget();
  }
}

/// 加载中组件
class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('加载中...'),
        ],
      ),
    );
  }
}

/// 错误组件
class _ErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorWidget({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
          ),
        ],
      ),
    );
  }
}

/// 空状态组件
class _EmptyWidget extends StatelessWidget {
  const _EmptyWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '暂无用户信息',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// 用户信息内容组件
class _UserProfileContent extends ConsumerWidget {
  final UserProfileState state;

  const _UserProfileContent({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 用户头像
          _AvatarSection(user: state.user!),
          const SizedBox(height: 32),

          // 用户信息表单
          _UserInfoForm(state: state),
          const SizedBox(height: 32),

          // 操作按钮
          _ActionButtons(state: state),
        ],
      ),
    );
  }
}

/// 头像区域
class _AvatarSection extends StatelessWidget {
  final dynamic user;

  const _AvatarSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Icon(
              Icons.person,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '加入时间: ${_formatDate(user.createdAt)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}

/// 用户信息表单
class _UserInfoForm extends ConsumerWidget {
  final UserProfileState state;

  const _UserInfoForm({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '编辑信息',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            // 用户名输入框
            TextField(
              controller: TextEditingController()..text = state.nameInput,
              onChanged: (value) {
                ref.read(userProfileViewModelProvider.notifier).updateNameInput(value);
              },
              decoration: const InputDecoration(
                labelText: '用户名',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // 邮箱输入框
            TextField(
              controller: TextEditingController()..text = state.emailInput,
              onChanged: (value) {
                ref.read(userProfileViewModelProvider.notifier).updateEmailInput(value);
              },
              decoration: const InputDecoration(
                labelText: '邮箱',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
    );
  }
}

/// 操作按钮区域
class _ActionButtons extends ConsumerWidget {
  final UserProfileState state;

  const _ActionButtons({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(userProfileViewModelProvider.notifier);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 更新按钮
        ElevatedButton.icon(
          onPressed: state.updateUserCommand.running
              ? null
              : () => viewModel.updateUser(),
          icon: state.updateUserCommand.running
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save),
          label: Text(
            state.updateUserCommand.running ? '保存中...' : '保存修改',
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),

        // 显示更新结果
        if (state.updateUserCommand.successful)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 18),
                  SizedBox(width: 8),
                  Text(
                    '保存成功',
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
          )
        else if (state.updateUserCommand.failed)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '保存失败: ${state.updateUserCommand.error}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 16),

        // 删除按钮
        OutlinedButton.icon(
          onPressed: state.deleteUserCommand.running
              ? null
              : () => _showDeleteConfirmation(context, ref),
          icon: state.deleteUserCommand.running
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.delete_outline),
          label: Text(
            state.deleteUserCommand.running ? '删除中...' : '删除账户',
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除此账户吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(userProfileViewModelProvider.notifier).deleteUser();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}