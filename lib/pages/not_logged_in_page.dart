import 'package:flutter/material.dart';

class NotLoggedInPage extends StatelessWidget {
  const NotLoggedInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // 顶部用户信息区域
            _buildUserHeader(),
            
            // 可滚动内容区域
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // VIP 会员推广卡片
                    _buildVipPromotionCard(),
                    
                    // 云空间区域
                    _buildCloudStorageSection(),
                    
                    // 最近保存文件
                    _buildRecentFilesSection(),
                    
                    // 会员专属功能
                    _buildMemberExclusiveSection(),
                  ],
                ),
              ),
            ),
            
            // 底部导航栏
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  /// 构建用户头部区域
  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 用户头像
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '点击享更多权益',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '登录后享受更多服务',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // 设置按钮
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  /// 构建 VIP 会员推广卡片
  Widget _buildVipPromotionCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // VIP 标题
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFF4E5B2)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'VIP',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '开通会员，畅享更多专属权益',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 权益图标
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPrivilegeItem('无极扫描', Icons.document_scanner),
              _buildPrivilegeItem('AI问答', Icons.psychology),
              _buildPrivilegeItem('AI写作', Icons.edit_note),
              _buildPrivilegeItem('AI文档', Icons.description),
            ],
          ),
          const SizedBox(height: 16),
          
          // 立即开通按钮
          Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFFF4E5B2)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: TextButton(
              onPressed: () {},
              child: const Text(
                '立即开通',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建权益项
  Widget _buildPrivilegeItem(String title, IconData icon) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFD4AF37),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  /// 构建云空间区域
  Widget _buildCloudStorageSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    '云空间',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '剩余容量0.00GB/云空间',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 文件类型图标
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFileTypeItem('相册', Icons.photo_library, Colors.green),
              _buildFileTypeItem('短视', Icons.videocam, Colors.orange),
              _buildFileTypeItem('文档', Icons.insert_drive_file, Colors.blue),
              _buildFileTypeItem('音乐', Icons.music_note, Colors.purple),
              _buildFileTypeItem('其他', Icons.folder, Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建文件类型项
  Widget _buildFileTypeItem(String title, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  /// 构建最近保存文件区域
  Widget _buildRecentFilesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '最近保存文件',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // 文件列表
          _buildFileItem('导Word 2024-05-06 10:27', 'docx', '2024-05-06 14:35', '202K'),
          _buildFileItem('扫描数据 2024-05-06 10:27', 'pdf', '2024-05-06 14:35', '568K'),
          _buildFileItem('扫描数据 2024-05-06 10:27', 'pdf', '2024-05-06 14:35', '860K'),
        ],
      ),
    );
  }

  /// 构建文件项
  Widget _buildFileItem(String name, String type, String date, String size) {
    IconData icon;
    Color iconColor;
    
    switch (type) {
      case 'docx':
        icon = Icons.description;
        iconColor = Colors.blue;
        break;
      case 'pdf':
        icon = Icons.picture_as_pdf;
        iconColor = Colors.red;
        break;
      default:
        icon = Icons.insert_drive_file;
        iconColor = Colors.grey;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$date · $size',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_horiz,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建会员专属功能区域
  Widget _buildMemberExclusiveSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.star,
            color: Colors.amber[700],
            size: 20,
          ),
          const SizedBox(width: 8),
          const Text(
            '会员专属功能',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  /// 构建底部导航栏
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, '首页', false),
              _buildNavItem(Icons.folder_outlined, '全部文件', false),
              _buildNavItem(Icons.add_circle, '', true, isCenter: true),
              _buildNavItem(Icons.apps_outlined, '实用工具', false),
              _buildNavItem(Icons.person_outline, '我的', true),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建导航项
  Widget _buildNavItem(IconData icon, String label, bool isSelected, {bool isCenter = false}) {
    if (isCenter) {
      return Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF6BB5FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      );
    }
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isSelected ? const Color(0xFF4A90E2) : Colors.grey[600],
          size: 24,
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? const Color(0xFF4A90E2) : Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
}