import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/my_unlogged_page.dart';
import 'features/user_profile/presentation/views/user_profile_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter 架构示例',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ArchitectureDemoHomePage(),
      routes: {
        '/user-profile': (context) => const UserProfileScreen(),
        '/unlogged': (context) => const MyUnloggedPage(),
      },
    );
  }
}

/// 架构示例首页
/// 提供导航到不同页面的入口
class ArchitectureDemoHomePage extends StatelessWidget {
  const ArchitectureDemoHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter 架构示例'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(context),
          const SizedBox(height: 24),
          _buildNavigationCard(
            context,
            title: '用户信息页面',
            subtitle: '演示 MVVM 架构、Command 模式、依赖注入',
            icon: Icons.person,
            onTap: () => Navigator.pushNamed(context, '/user-profile'),
          ),
          const SizedBox(height: 16),
          _buildNavigationCard(
            context,
            title: '未登录页面',
            subtitle: '原有的未登录页面',
            icon: Icons.login,
            onTap: () => Navigator.pushNamed(context, '/unlogged'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.architecture,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Flutter 推荐架构',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '本示例展示了 Flutter 官方推荐的应用架构模式，包括：',
            ),
            const SizedBox(height: 8),
            const _ArchitectureItem(
              icon: Icons.layers,
              title: 'UI 层',
              description: 'Views + ViewModels',
            ),
            const _ArchitectureItem(
              icon: Icons.storage,
              title: 'Data 层',
              description: 'Repositories + Services',
            ),
            const _ArchitectureItem(
              icon: Icons.precision_manufacturing,
              title: 'Command 模式',
              description: '处理异步操作和状态管理',
            ),
            const _ArchitectureItem(
              icon: Icons.hub,
              title: '依赖注入',
              description: '使用 Riverpod 进行依赖管理',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

/// 架构项目组件
class _ArchitectureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ArchitectureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            description,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
