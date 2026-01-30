import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 我的_未登录页面
///
/// 设计稿来源: https://www.figma.com/design/ZiujFaGRONmlNmLjGfAfow/Untitled?node-id=127:778
class MyUnloggedPage extends StatelessWidget {
  const MyUnloggedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FF),
      body: Stack(
        children: [
          // 背景图片
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/images/background.svg',
              width: 375,
              height: 248,
              fit: BoxFit.cover,
            ),
          ),
          // 可滚动内容
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 52),
                  // 用户信息头部
                  const _UserInfoHeader(),
                  const SizedBox(height: 12),
                  // VIP 会员卡片
                  const _VIPMainCard(),
                  const SizedBox(height: 12),
                  // 云空间卡片
                  const _CloudSpaceCard(),
                  const SizedBox(height: 12),
                  // 最近保存文件卡片
                  const _RecentFilesCard(),
                  const SizedBox(height: 12),
                  // 设置列表卡片
                  const _SettingsListCard(),
                  // 底部间距（为底部导航栏留出空间）
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          // 底部导航栏
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomTabBar(),
          ),
        ],
      ),
    );
  }
}

/// 用户信息头部
class _UserInfoHeader extends StatelessWidget {
  const _UserInfoHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // 未登录头像
          SvgPicture.asset(
            'assets/images/ic_avatar_unlogged.svg',
            width: 32,
            height: 32,
          ),
          const SizedBox(width: 6),
          // 文字信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '登录享更多特权',
                  style: TextStyle(
                    fontFamily: 'PingFang SC',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF29283C),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Opacity(
                      opacity: 0.7,
                      child: Text(
                        '立即登录',
                        style: TextStyle(
                          fontFamily: 'PingFang SC',
                          fontWeight: FontWeight.w400,
                          fontSize: 10,
                          height: 1,
                          color: const Color(0xFF7B7B96),
                        ),
                      ),
                    ),
                    const SizedBox(width: 0),
                    Opacity(
                      opacity: 0.7,
                      child: SvgPicture.asset(
                        'assets/images/ic_arrow_right_login.svg',
                        width: 10,
                        height: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// VIP 会员卡片（包含工具网格和开通按钮）
class _VIPMainCard extends StatelessWidget {
  const _VIPMainCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: 343,
        height: 196,
        child: Stack(
          children: [
            // 卡片背景
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SvgPicture.asset(
                  'assets/images/vip_card_bg.svg',
                  width: 343,
                  height: 196,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            // VIP 标签和文字
            Positioned(
              left: 12,
              top: 13,
              child: Row(
                children: [
                  // VIP 标签
                  Container(
                    width: 30,
                    height: 14,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1D1B3E), Color(0xFF1D1C3F)],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6.05),
                        topRight: Radius.circular(14.36),
                        bottomRight: Radius.circular(14.36),
                        bottomLeft: Radius.circular(0),
                      ),
                      border: Border.all(
                        width: 1,
                        color: Colors.transparent,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'VIP',
                        style: TextStyle(
                          fontFamily: 'PingFang SC',
                          fontWeight: FontWeight.w600,
                          fontSize: 8,
                          color: Color(0xFFFFD196),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                  // 开通会员文字
                  Opacity(
                    opacity: 0.8,
                    child: Text(
                      '开通会员，享受超多VIP专属特权',
                      style: TextStyle(
                        fontFamily: 'PingFang SC',
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                        height: 1,
                        color: const Color(0xFFFFD8A4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 工具网格（全能扫描、AI图片、AI文档）
            Positioned(
              left: 0,
              right: 0,
              top: 52,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ToolItem(
                    iconPath: 'assets/images/ic_scan.svg',
                    title: '全能扫描',
                    subtitle: '快速精准',
                  ),
                  // 分割线
                  Opacity(
                    opacity: 0.6,
                    child: SvgPicture.asset(
                      'assets/images/divider_1.svg',
                      width: 1,
                      height: 48,
                    ),
                  ),
                  _ToolItem(
                    iconPath: 'assets/images/ic_ai_image.svg',
                    title: 'AI图片',
                    subtitle: '智能修图',
                  ),
                  // 分割线
                  Opacity(
                    opacity: 0.6,
                    child: SvgPicture.asset(
                      'assets/images/divider_2.svg',
                      width: 1,
                      height: 48,
                    ),
                  ),
                  _ToolItem(
                    iconPath: 'assets/images/ic_ai_doc.svg',
                    title: 'AI文档',
                    subtitle: '效率翻倍',
                  ),
                ],
              ),
            ),
            // 立即开通按钮
            Positioned(
              left: 20,
              right: 20,
              top: 134,
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFEACD), Color(0xFFFFCD8E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28.8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFCDA879).withAlpha(255),
                      offset: const Offset(-1, -1),
                      blurRadius: 0.5,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: const Color(0xFFFFF2E0).withAlpha(255),
                      offset: const Offset(1, 1),
                      blurRadius: 0.5,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '立即开通',
                    style: TextStyle(
                      fontFamily: 'PingFang HK',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      height: 1.54,
                      color: Color(0xFF29283C),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 工具项
class _ToolItem extends StatelessWidget {
  final String iconPath;
  final String title;
  final String subtitle;

  const _ToolItem({
    required this.iconPath,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 66,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 32,
            height: 32,
          ),
          const SizedBox(height: 7),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'PingFang SC',
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.17,
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [Color(0xFFF8DAA1), Color(0xFFF4C973)],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ).createShader(const Rect.fromLTWH(0, 0, 66, 14)),
            ),
          ),
          const SizedBox(height: 3),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFF8DAA1), Color(0xFFF4C973)],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ).createShader(bounds),
            child: Opacity(
              opacity: 0.6,
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'PingFang SC',
                  fontWeight: FontWeight.w400,
                  fontSize: 10,
                  height: 1,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 云空间卡片
class _CloudSpaceCard extends StatelessWidget {
  const _CloudSpaceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            offset: const Offset(0, 2),
            blurRadius: 20,
          ),
        ],
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
                      fontFamily: 'PingFang SC',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      height: 1,
                      color: Color(0xFF29283C),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '新会员赠送100G云空间',
                    style: TextStyle(
                      fontFamily: 'PingFang SC',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      height: 1,
                      color: Color(0xFF693F01),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '更多',
                    style: TextStyle(
                      fontFamily: 'PingFang HK',
                      fontWeight: FontWeight.w400,
                      fontSize: 11,
                      height: 0.91,
                      color: Colors.black.withAlpha(102),
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/images/ic_arrow_right_small.svg',
                    width: 10,
                    height: 10,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 云空间图标行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _CloudItem(
                iconPath: 'assets/images/ic_album.svg',
                title: '相册',
              ),
              _CloudItem(
                iconPath: 'assets/images/ic_video.svg',
                title: '视频',
              ),
              _CloudItem(
                iconPath: 'assets/images/ic_document.svg',
                title: '文档',
              ),
              _CloudItem(
                iconPath: 'assets/images/ic_music.svg',
                title: '音乐',
              ),
              _CloudItem(
                iconPath: 'assets/images/ic_other.svg',
                title: '其他',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 云空间项
class _CloudItem extends StatelessWidget {
  final String iconPath;
  final String title;

  const _CloudItem({
    required this.iconPath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          iconPath,
          width: 32,
          height: 32,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'PingFang SC',
            fontWeight: FontWeight.w500,
            fontSize: 12,
            height: 1,
            color: Color(0xFF29283C),
          ),
        ),
      ],
    );
  }
}

/// 最近保存文件卡片
class _RecentFilesCard extends StatelessWidget {
  const _RecentFilesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            offset: const Offset(0, 2),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          // 标题行
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '最近保存文件',
                  style: TextStyle(
                    fontFamily: 'PingFang SC',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 1,
                    color: Color(0xFF29283C),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '更多',
                      style: TextStyle(
                        fontFamily: 'PingFang HK',
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        height: 0.91,
                        color: Colors.black.withAlpha(102),
                      ),
                    ),
                    SvgPicture.asset(
                      'assets/images/ic_arrow_right_small.svg',
                      width: 10,
                      height: 10,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // 文件列表
          _FileItem(
            pageNumber: '1',
            title: '转Word 2024-05-09 10:27',
            date: '2024-05-09 14:30',
            size: '203K',
            bgColor: const Color(0x1A29283C),
          ),
          _FileItem(
            pageNumber: '8',
            title: '拍照翻译 2024-05-09 10:27',
            date: '2024-05-09 14:30',
            size: '203K',
            bgColor: const Color(0x1A29283C),
          ),
          _FileItem(
            pageNumber: '2',
            title: '拍照翻译 2024-05-09 10:27',
            date: '2024-05-09 14:30',
            size: '203K',
            bgColor: const Color(0x1A29283C),
          ),
        ],
      ),
    );
  }
}

/// 文件项
class _FileItem extends StatelessWidget {
  final String pageNumber;
  final String title;
  final String date;
  final String size;
  final Color bgColor;

  const _FileItem({
    required this.pageNumber,
    required this.title,
    required this.date,
    required this.size,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          // 文件缩略图
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0x1A29283C),
                width: 0.5,
              ),
            ),
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.all(4),
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0x8029283C),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  pageNumber,
                  style: const TextStyle(
                    fontFamily: 'PingFang SC',
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                    height: 1,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 文件信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'PingFang SC',
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF29283C),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontFamily: 'PingFang SC',
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                        height: 1.4,
                        color: Color(0xFF7B7B96),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      size,
                      style: const TextStyle(
                        fontFamily: 'PingFang SC',
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                        height: 1.4,
                        color: Color(0xFF7B7B96),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 设置列表卡片
class _SettingsListCard extends StatelessWidget {
  const _SettingsListCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            offset: const Offset(0, 2),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          _SettingsItem(
            iconPath: 'assets/images/ic_feedback.svg',
            title: '会员专属反馈',
            showDivider: true,
          ),
          _SettingsItem(
            iconPath: 'assets/images/ic_check_update.svg',
            title: '检查更新',
            showDivider: true,
          ),
          _SettingsItem(
            iconPath: 'assets/images/ic_device_manage.svg',
            title: '设备管理',
            showDivider: true,
          ),
          _SettingsItem(
            iconPath: 'assets/images/ic_settings.svg',
            title: '设置',
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

/// 设置项
class _SettingsItem extends StatelessWidget {
  final String iconPath;
  final String title;
  final bool showDivider;

  const _SettingsItem({
    required this.iconPath,
    required this.title,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              SvgPicture.asset(
                iconPath,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'PingFang SC',
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    height: 1.23,
                    color: Color(0xFF29283C),
                  ),
                ),
              ),
              SvgPicture.asset(
                'assets/images/ic_arrow_right.svg',
                width: 10,
                height: 10,
              ),
            ],
          ),
        ),
        if (showDivider)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            height: 0.5,
            color: const Color(0x1A29283C),
          ),
      ],
    );
  }
}

/// 底部导航栏
class _BottomTabBar extends StatelessWidget {
  const _BottomTabBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 106,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          // 顶部渐变条
          Container(
            height: 12,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0x0029283C), Color(0x0529283C)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // 导航项
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _TabItem(
                  iconPath: 'assets/images/ic_tab_home.svg',
                  title: '首页',
                  isSelected: false,
                ),
                _TabItem(
                  iconPath: 'assets/images/ic_history.svg',
                  title: '全部工具',
                  isSelected: false,
                ),
                _TabItem(
                  iconPath: 'assets/images/ic_tab_mine_selected.svg',
                  title: '我的',
                  isSelected: true,
                ),
              ],
            ),
          ),
          // Home Indicator
          Container(
            width: 134,
            height: 5,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF222222),
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// 导航项
class _TabItem extends StatelessWidget {
  final String iconPath;
  final String title;
  final bool isSelected;

  const _TabItem({
    required this.iconPath,
    required this.title,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isSelected ? 1.0 : 0.6,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 24,
              height: 24,
              colorFilter: isSelected
                  ? const ColorFilter.mode(Color(0xFF5257EF), BlendMode.srcIn)
                  : null,
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'PingFang SC',
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                fontSize: 11,
                height: 1,
                color: isSelected
                    ? const Color(0xFF5257EF)
                    : const Color(0xFF29283C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}