---
name: Figma 转 Flutter 像素级还原
description: 将 Figma 设计稿严格 1:1 像素级转换为生产可用的 Flutter 代码，遵循 Dart 3.x 最佳实践
metadata:
  labels: [figma, flutter, ui, pixel-perfect, dart]
  triggers:
    files: ['**/*_page.dart', '**/*_screen.dart', '**/widgets/**', '**/ui/**']
    keywords: [figma, 设计稿, UI还原, 像素级, 1:1, f2c, design-to-code]
---

# Figma 转 Flutter 像素级还原

## **Priority: P0 (CRITICAL)**

将 Figma 设计稿精确转换为 Flutter 代码，以"工程可落地"为最高优先级。确保视觉 1:1 还原、遵循 Dart 3.x 语言规范、模块化工程规范、代码可直接提交仓库。

## 触发条件

满足以下任一条件时启用此技能：
- 用户输入包含 `figma.com` 的链接
- 用户提到 Figma、设计稿、设计转 Flutter、UI 还原、像素级、1:1
- 使用 MCP 工具 `figma-developer-mcp` 进行设计转换

## 角色设定

使用此技能时，你是：
- 资深 Flutter 工程师（精通 Dart 3.x 特性）
- Figma 设计规范专家
- MCP 协议专家
- 严格的代码 Reviewer

---

## Dart 语言规范 (Dart 3.x+)

### Null Safety

- **避免 `!` 操作符**：使用 `?.`、`??` 或 short-circuiting，仅在能证明非空时使用 `!`
- **谨慎使用 `late`**：仅在确实需要延迟初始化时使用
- **类型推断**：优先使用 `final` 声明变量，避免 `var` 用于类成员

```dart
// ✅ Good
final String? userName = user?.name;
final displayName = userName ?? 'Guest';

// ❌ Bad
final displayName = user!.name;
```

### Immutability

- **优先使用 `const`**：对于编译时常量使用 `const`，运行时不变量使用 `final`
- **使用 `@freezed`**：对于数据类使用 freezed 包

```dart
// ✅ Good
const EdgeInsets.all(16);
final controller = TextEditingController();

// ❌ Bad
var padding = EdgeInsets.all(16);
```

### Pattern Matching (3.x)

- 使用 `switch (value)` 配合 patterns 和 destructuring
- 优先使用 Records 返回多个值

```dart
// ✅ Good - Switch expression with patterns
String getStatusText(ConnectionState state) => switch (state) {
  ConnectionState.none => '未连接',
  ConnectionState.waiting => '连接中...',
  ConnectionState.active => '已连接',
  ConnectionState.done => '已断开',
};

// ✅ Good - Records for multiple return values
(double width, double height) getSize(BoxConstraints constraints) =>
    (constraints.maxWidth, constraints.maxHeight);
```

### Sealed Classes

- 使用 `sealed class` 处理有限状态集

```dart
// ✅ Good - Sealed class for exhaustive state handling
sealed class LoadState {}
class Loading extends LoadState {}
class Success extends LoadState { final String data; Success(this.data); }
class Error extends LoadState { final String message; Error(this.message); }

Widget buildContent(LoadState state) => switch (state) {
  Loading() => const CircularProgressIndicator(),
  Success(:final data) => Text(data),
  Error(:final message) => Text('错误: $message'),
};
```

### Extensions

- 使用 `extension` 为第三方类型添加工具方法

```dart
// ✅ Good - Extension for Theme access
extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
}

// Usage
Text('Hello', style: context.textTheme.titleLarge);
```

### 命名规范

遵循 [Effective Dart](https://dart.dev/guides/language/effective-dart):
- **类名**：`PascalCase`（如 `HomePageWidget`）
- **变量/函数**：`camelCase`（如 `getUserName`）
- **常量**：`lowerCamelCase`（如 `defaultPadding`）
- **私有成员**：`_` 前缀（如 `_internalState`）
- **文件名**：`snake_case`（如 `home_page.dart`）

---

## Flutter Widget 规范

### Widget 类型选择

- **默认使用 `StatelessWidget`**：仅在需要本地状态/控制器时使用 `StatefulWidget`
- **Composition 优先**：将复杂 UI 拆分为小型、原子化的 `const` widgets
- **避免深层嵌套**：避免超过 3-4 层嵌套，使用 helper methods 或提取 widgets

```dart
// ✅ Good - Composition with const widgets
class UserCard extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  
  const UserCard({super.key, required this.name, this.avatarUrl});
  
  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          _UserAvatar(url: avatarUrl),
          SizedBox(width: 12),
          _UserName(name: name),
        ],
      ),
    ),
  );
}
```

### Layout 最佳实践（CRITICAL - 避免常见错误）

#### 1. 布局选择原则

**优先使用流式布局**：
- `Column`：垂直排列元素
- `Row`：水平排列元素
- `Flex`：灵活的弹性布局
- `ListView`：可滚动列表

**谨慎使用绝对定位**：
- `Stack` + `Positioned`：仅用于层叠场景（背景图+内容、浮动按钮）
- 避免使用绝对定位来控制常规布局

#### 2. 常见布局错误与修正

**错误 1：过度使用绝对定位导致重叠**

```dart
// ❌ 错误 - 组件重叠
Stack(
  children: [
    Positioned(
      left: 16,
      top: 102,
      child: VIPCard(), // height: 196
    ),
    Positioned(
      left: 44,
      top: 154, // 与 VIPCard 重叠！
      child: ToolsSection(),
    ),
  ],
)

// ✅ 正确 - 使用流式布局
Column(
  children: [
    SizedBox(height: 102),
    VIPCard(),
    SizedBox(height: 16),
    ToolsSection(),
  ],
)
```

**错误 2：子元素定位超出父容器**

```dart
// ❌ 错误 - VIPButton 超出 VIPCard 范围
class VIPCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SvgPicture.asset('assets/images/vip_card_bg.svg', width: 343, height: 196),
        Positioned(
          left: 36,
          top: 236, // 超出 196 的高度！
          child: VIPButton(),
        ),
      ],
    );
  }
}

// ✅ 正确 - 按钮在卡片内部
class VIPCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 343,
      height: 196,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/vip_card_bg.svg'),
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
        children: [
          // ... 其他内容
          Padding(
            padding: EdgeInsets.only(top: 120),
            child: VIPButton(),
          ),
        ],
      ),
    );
  }
}
```

**错误 3：重复定位导致冲突**

```dart
// ❌ 错误 - VIPBadge 在页面和卡片中都有定位
Stack(
  children: [
    Positioned(left: 39.3, top: 61.89, child: VIPBadge()), // 页面级定位
    Positioned(left: 16, top: 102, child: VIPCard()), // 卡片内部也有 VIPBadge
  ],
)

// ✅ 正确 - 只在卡片内部定位
Column(
  children: [
    UserInfoSection(),
    VIPCard(), // VIPBadge 在卡片内部
  ],
)
```

**错误 4：固定高度导致溢出**

```dart
// ❌ 错误 - 固定高度，内容可能溢出
Container(
  height: 192, // 固定高度
  child: Column(
    children: [
      _buildItem(),
      _buildItem(),
      _buildItem(),
      _buildItem(), // 可能溢出
    ],
  ),
)

// ✅ 正确 - 自适应高度
Container(
  constraints: BoxConstraints(minHeight: 192),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _buildItem(),
      _buildItem(),
      _buildItem(),
      _buildItem(),
    ],
  ),
)
```

#### 3. 间距控制

**使用 SizedBox 或 Gap**：

```dart
// ✅ Good - SizedBox for spacing
Column(
  children: const [
    HeaderWidget(),
    SizedBox(height: 16),
    ContentWidget(),
    SizedBox(height: 24),
    FooterWidget(),
  ],
)

// ✅ Good - Gap for spacing (requires gap package)
Column(
  children: const [
    HeaderWidget(),
    Gap(16),
    ContentWidget(),
    Gap(24),
    FooterWidget(),
  ],
)
```

#### 4. 对齐控制

**使用 mainAxisAlignment 和 crossAxisAlignment**：

```dart
// ✅ Good - 使用对齐属性
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Text('左侧'),
    Text('右侧'),
  ],
)

// ❌ Bad - 使用绝对定位控制对齐
Stack(
  children: [
    Positioned(left: 0, child: Text('左侧')),
    Positioned(right: 0, child: Text('右侧')),
  ],
)
```

#### 5. Stack 使用规范

**仅用于层叠场景**：

```dart
// ✅ 正确的 Stack 使用 - 背景图 + 内容
Stack(
  children: [
    // 背景图
    Positioned.fill(
      child: SvgPicture.asset(
        'assets/images/background.svg',
        fit: BoxFit.cover,
      ),
    ),
    // 内容区域
    Positioned.fill(
      child: SafeArea(
        child: Column(
          children: [
            Header(),
            Expanded(child: Content()),
          ],
        ),
      ),
    ),
  ],
)

// ✅ 正确的 Stack 使用 - 浮动按钮
Stack(
  children: [
    MainContent(),
    Positioned(
      right: 16,
      bottom: 16,
      child: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    ),
  ],
)
```

#### 6. 响应式布局

**使用 FractionallySizedBox 处理相对尺寸**：

```dart
// ✅ Good - 相对宽度
FractionallySizedBox(
  widthFactor: 0.9, // 90% 宽度
  child: Container(
    height: 200,
    color: Colors.blue,
  ),
)

// ✅ Good - 使用 LayoutBuilder
LayoutBuilder(
  builder: (context, constraints) {
    return Container(
      width: constraints.maxWidth * 0.8,
      height: constraints.maxHeight * 0.5,
    );
  },
)
```

### Spacing

- **Spacing**：使用 `Gap(n)` 或 `SizedBox` 代替 `Padding` 实现简单间距
- **Empty UI**：使用 `const SizedBox.shrink()` 表示空组件
- **避免 IntrinsicWidth/Height**：使用 `Stack` + `FractionallySizedBox` 处理 overlays
- **Flex 布局**：使用 `Flex` + `Gap/SizedBox` 组合

### 性能优化

- **使用 `ColoredBox` / `Padding` / `DecoratedBox`** 代替 `Container`（当仅需单一功能时）
- **ListView.builder**：大列表必须使用 `.builder` 或 `.separated`
- **const 构造函数**：尽可能使用 `const` 构造函数

```dart
// ✅ Good - Specific widgets
const ColoredBox(
  color: Colors.blue,
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text('Hello'),
  ),
);

// ❌ Bad - Container for single purpose
Container(
  color: Colors.blue,
  padding: EdgeInsets.all(16),
  child: Text('Hello'),
);
```

### Async Gaps

- 在 `await` 之后使用 `BuildContext` 前，必须检查 `context.mounted`

```dart
// ✅ Good
Future<void> loadData() async {
  final data = await fetchData();
  if (!context.mounted) return;
  Navigator.of(context).pop(data);
}

// ❌ Bad
Future<void> loadData() async {
  final data = await fetchData();
  Navigator.of(context).pop(data); // 可能导致崩溃
}
```

---

## 执行流程

### 1. 解析与获取数据

1. 从 Figma 链接提取 `fileKey` 和 `nodeId`（如无则使用页面根节点）
2. 若链接或节点非法则提示用户并停止
3. 使用 MCP 工具 `figma-developer-mcp_get_figma_data` 获取节点结构、样式信息、布局数据
4. **此阶段不生成任何 Dart 代码**

### 2. 确认生成路径

必须向用户确认以下信息后才能继续：
- **Dart 文件生成路径**（示例：`lib/src/ui/home/home_page.dart`）
- **所属模块名称**（若路径已包含模块则自动识别，否则给出建议并让用户确认）

⚠️ **未确认前禁止**：下载图片、更新 pubspec.yaml、生成代码

### 3. 分析设计结构

分析并记录：
- 页面整体布局方式（优先使用 `Column` / `Row`，谨慎使用 `Stack`）
- 页面背景处理
- 固定区域（如底部按钮、顶部导航）
- 可交互区域标识
- 响应式断点需求
- **组件层级关系**：明确哪些元素是父容器的子元素，避免重复定位

### 4. 节点处理

**排除系统 UI 元素**：
- 状态栏、时间、电池、WiFi/信号图标
- 完全忽略，不下载、不渲染、不占位

**节点分类**：
| 类型 | 处理方式 |
|------|----------|
| 文本 | `Text` widget，提取多语言 key |
| 图片（PNG/JPG） | `Image.asset` with package |
| 矢量图（SVG） | `SvgPicture.asset` (flutter_svg) |
| 纯容器 | `Container` / `DecoratedBox` / `ColoredBox` |
| 可点击区域 | `GestureDetector` / `InkWell` |

### 5. 资源下载与校验

1. 使用 `figma-developer-mcp_download_figma_images` 下载所有非系统 UI 图像
2. 若无切图则对节点截图
3. 保存路径规范：
   - 图片：`<module>/assets/images/`
   - 图标：`<module>/assets/icons/`
4. 校验文件可解码性、扩展名正确性
5. 资源缺失则重新下载或提示用户

### 6. 更新配置

1. 读取模块 `pubspec.yaml`，获取 `name` 字段作为 package 名
2. 将新资源加入 `assets`
3. **不覆盖、不破坏已有配置**

### 7. 生成 Flutter 代码

#### 布局规则（CRITICAL）
- 所有尺寸、间距、圆角**精确来自 Figma**，不使用"接近值"
- **优先使用流式布局**（`Column`、`Row`、`Flex`）
- **谨慎使用绝对定位**（`Stack` + `Positioned`），仅用于层叠场景
- **避免组件重叠**：确保所有元素在正确的容器内
- **避免溢出**：动态内容使用自适应高度，固定高度仅用于明确尺寸的元素
- **子元素定位一致性**：如果组件内部已包含子元素，不要在父容器中重复定位

#### 资源引用规则（强制使用 package 参数）

```dart
// ✅ 图片资源
Image.asset(
  'assets/images/banner.png',
  package: 'module_name',
  width: 375,
  height: 200,
  fit: BoxFit.cover,
);

// ✅ SVG 资源
SvgPicture.asset(
  'assets/icons/icon_home.svg',
  package: 'module_name',
  width: 24,
  height: 24,
  colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
);

// ✅ 装饰图片
DecoratedBox(
  decoration: BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/images/bg.png', package: 'module_name'),
      fit: BoxFit.cover,
    ),
  ),
);
```

#### 文本处理
- **禁止硬编码文本**
- 每段文本生成唯一 key
- 使用模块现有的多语言访问方式

```dart
// ✅ Good - Using localization
Text(S.of(context).homeTitle);

// ❌ Bad - Hardcoded text
Text('首页');
```

#### 交互处理
- 优先视觉 1:1，不改变对齐、不拉伸
- 仅在不影响布局时扩大点击区域
- 推荐使用 `HitTestBehavior.opaque`

```dart
// ✅ Good - Proper tap handling
GestureDetector(
  behavior: HitTestBehavior.opaque,
  onTap: onPressed,
  child: Padding(
    padding: const EdgeInsets.all(8), // 扩大点击区域
    child: Icon(Icons.close, size: 16),
  ),
);
```

---

## 代码模板

### 页面基础结构

```dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 首页
/// 
/// 设计稿来源: [Figma链接]
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: const [
            _Header(),
            Expanded(child: _Content()),
            _BottomBar(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    // TODO: 实现头部组件
    return const SizedBox.shrink();
  }
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    // TODO: 实现内容区域
    return const SizedBox.shrink();
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    // TODO: 实现底部栏
    return const SizedBox.shrink();
  }
}
```

### 可复用组件模板

```dart
/// 自定义按钮组件
/// 
/// [label] 按钮文本
/// [onPressed] 点击回调
/// [isLoading] 是否显示加载状态
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isLoading ? null : onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: onPressed == null 
              ? const Color(0xFFCCCCCC) 
              : const Color(0xFF007AFF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}
```

---

## 质量校验清单

最终提交前逐项确认：

- [ ] **像素级还原**：所有尺寸、间距、颜色与设计稿一致
- [ ] **排除系统 UI**：状态栏等系统元素已忽略
- [ ] **图片完整**：所有图片资源已下载并正确引用
- [ ] **package 参数**：所有资源引用包含 `package` 参数
- [ ] **pubspec.yaml**：assets 配置已更新
- [ ] **无硬编码文本**：所有文本使用多语言 key
- [ ] **SVG 处理**：使用 flutter_svg，保持原始尺寸
- [ ] **点击区域**：交互区域合理，不影响视觉布局
- [ ] **Dart 规范**：遵循 Null Safety、const 优先、合理命名
- [ ] **const 使用**：尽可能使用 const 构造函数
- [ ] **代码可提交**：无编译错误，可直接 PR
- [ ] **布局使用流式布局**：优先使用 Column/Row，避免过度使用 Stack
- [ ] **无组件重叠**：所有元素在正确的容器内，无重叠
- [ ] **无溢出**：动态内容使用自适应高度
- [ ] **子元素定位一致**：组件内部已包含的子元素不在父容器中重复定位
- [ ] **固定高度合理**：固定高度仅用于明确尺寸的元素

---

## 异常处理

- **不确定则询问**：设计不清晰、规格模糊时主动询问
- **不猜、不脑补、不将就**：严格按设计稿执行
- **MCP 调用失败**：记录错误信息，提示用户检查 Figma 链接或权限

---

## 输出内容

最终输出应包含：

1. **Dart 文件代码**：完整可运行的 Widget 代码
2. **资源目录说明**：下载的图片/图标列表及路径
3. **pubspec.yaml 修改说明**：需要添加的 assets 配置
4. **多语言 CSV 表**：格式 `key,中文,英文`

---

## Related Topics

- flutter/widgets
- flutter/idiomatic-flutter
- flutter/layer-based-clean-architecture
- dart/language
- dart/best-practices