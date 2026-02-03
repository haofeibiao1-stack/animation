# Flutter MVVM 架构开发规范

本文档定义了基于 MVVM 模式的 Flutter 应用开发规范，适用于所有 Flutter 项目。

## 目录

1. [架构原则](#架构原则)
2. [项目结构](#项目结构)
3. [分层职责](#分层职责)
4. [代码规范](#代码规范)
5. [依赖注入](#依赖注入)
6. [状态管理](#状态管理)
7. [命名规范](#命名规范)
8. [最佳实践](#最佳实践)

---

## 架构原则

### 核心原则

1. **关注点分离**: 每层只负责自己的职责
2. **单向数据流**: 数据从上到下流动，事件从下到上传递
3. **依赖倒置**: 高层模块不依赖低层模块，都依赖抽象
4. **开闭原则**: 对扩展开放，对修改关闭
5. **单一职责**: 每个类只负责一个功能

### 技术栈

- **状态管理**: Riverpod (代码生成注解方式)
- **依赖注入**: Riverpod Provider
- **异步处理**: Command 模式
- **错误处理**: Result 类型

---

## 项目结构

### 标准目录结构

```
lib/
├── main.dart                    # 应用入口
├── app/                         # 应用级配置
│   ├── routes/                  # 路由配置
│   └── theme/                   # 主题配置
├── core/                        # 核心功能
│   ├── constants/               # 常量定义
│   ├── utils/                   # 工具类
│   │   ├── command.dart         # 命令模式
│   │   └── result.dart          # 结果类型
│   └── network/                 # 网络配置
├── features/                    # 功能模块
│   └── {feature_name}/          # 功能名称
│       ├── data/                # 数据层
│       │   ├── models/          # 数据模型
│       │   ├── repositories/    # 仓库
│       │   └── services/        # 服务
│       ├── domain/              # 领域层
│       │   ├── entities/        # 实体
│       │   └── value_objects/   # 值对象
│       └── presentation/        # 表现层
│           ├── viewmodels/      # 视图模型
│           │   ├── {feature}_state.dart
│           │   ├── {feature}_viewmodel.dart
│           │   └── {feature}_viewmodel.g.dart
│           └── views/           # 视图
│               └── {feature}_screen.dart
└── shared/                      # 共享资源
    ├── widgets/                 # 通用组件
    └── l10n/                    # 国际化
```

### 文件命名规范

- **小写蛇形命名**: `user_profile_screen.dart`
- **功能前缀**: `{feature}_{type}.dart`
- **生成文件**: `{file}.g.dart` (不提交到版本控制)

---

## 分层职责

### 1. 表现层 (Presentation Layer)

#### Views (视图)

**职责**:
- 构建 UI 界面
- 响应用户交互
- 显示数据
- 处理导航

**规范**:
```dart
class FeatureScreen extends ConsumerWidget {
  const FeatureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听状态
    final state = ref.watch(featureViewModelProvider);
    
    return Scaffold(
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(featureViewModelProvider.notifier).action(),
      ),
    );
  }
}
```

**规则**:
- 必须使用 `ConsumerWidget` 或 `ConsumerStatefulWidget`
- 通过 `ref.watch()` 监听状态
- 通过 `ref.read()` 调用方法
- 不包含业务逻辑
- 不直接访问数据层

#### ViewModels (视图模型)

**职责**:
- 管理 UI 状态
- 处理业务逻辑
- 协调数据获取
- 提供命令接口

**规范**:
```dart
@Riverpod(keepAlive: true)
class FeatureViewModel extends _$FeatureViewModel {
  @override
  FeatureState build() {
    final repository = ref.watch(featureRepositoryProvider);
    return FeatureState.initial();
  }

  Future<void> loadData() async {
    // 业务逻辑
  }

  void updateInput(String value) {
    state = state.copyWith(input: value);
  }
}
```

**规则**:
- 使用 `@riverpod` 或 `@Riverpod(keepAlive: true)` 注解
- 继承 `_$ClassName`
- 实现 `build()` 方法返回初始状态
- 通过 `state = state.copyWith()` 更新状态
- 通过 `ref.watch()` 获取依赖

#### State (状态)

**职责**:
- 定义 UI 状态结构
- 提供状态更新方法

**规范**:
```dart
class FeatureState {
  final Data? data;
  final String input;
  final Command<Data> loadCommand;

  const FeatureState({
    required this.data,
    required this.input,
    required this.loadCommand,
  });

  factory FeatureState.initial() {
    return FeatureState(
      data: null,
      input: '',
      loadCommand: Command<Data>(action: () async {}),
    );
  }

  FeatureState copyWith({
    Data? data,
    String? input,
    Command<Data>? loadCommand,
  }) {
    return FeatureState(
      data: data ?? this.data,
      input: input ?? this.input,
      loadCommand: loadCommand ?? this.loadCommand,
    );
  }
}
```

**规则**:
- 所有字段必须是 `final`
- 实现 `copyWith` 方法
- 提供 `initial` 工厂构造函数
- 包含所有 Command 对象

### 2. 数据层 (Data Layer)

#### Repositories (仓库)

**职责**:
- 定义数据操作接口
- 处理数据验证和转换
- 管理缓存策略
- 协调多个数据源

**规范**:
```dart
@riverpod
FeatureRepository featureRepository(FeatureRepositoryRef ref) {
  final service = ref.watch(featureServiceProvider);
  return FeatureRepositoryImpl(service: service);
}

class FeatureRepositoryImpl implements FeatureRepository {
  final FeatureService service;

  FeatureRepositoryImpl({required this.service});

  @override
  Future<Result<Data>> getData() async {
    try {
      final result = await service.fetchData();
      return Result.ok(result);
    } catch (e) {
      return Result.error(e as Exception);
    }
  }
}
```

**规则**:
- 使用 `@riverpod` 注解
- 通过 `ref.watch()` 获取 Service
- 返回 `Result<T>` 类型
- 处理异常并转换为 Result

#### Services (服务)

**职责**:
- 与外部数据源交互
- 处理网络请求
- 管理认证
- 数据序列化

**规范**:
```dart
@riverpod
FeatureService featureService(FeatureServiceRef ref) {
  return FeatureServiceImpl();
}

class FeatureServiceImpl implements FeatureService {
  @override
  Future<Data> fetchData() async {
    // API 调用或数据库操作
  }
}
```

**规则**:
- 使用 `@riverpod` 注解
- 实现具体的数据访问逻辑
- 处理网络错误
- 返回原始数据

### 3. 领域层 (Domain Layer)

#### Models (模型)

**职责**:
- 定义数据结构
- 实现序列化/反序列化
- 数据验证

**规范**:
```dart
class Data {
  final String id;
  final String name;
  final DateTime createdAt;

  Data({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Data copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return Data(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

**规则**:
- 所有字段必须是 `final`
- 实现 `fromJson` 和 `toJson`
- 实现 `copyWith` 方法
- 实现 `==` 和 `hashCode`

---

## 代码规范

### 导入顺序

```dart
// 1. Dart 核心库
import 'dart:async';

// 2. Flutter 框架
import 'package:flutter/material.dart';

// 3. 第三方包
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 4. 项目内部
import 'package:my_app/core/utils/result.dart';
import 'package:my_app/features/feature/data/models/data.dart';

// 5. 生成文件
part 'feature_viewmodel.g.dart';
```

### 注释规范

```dart
/// 功能描述
///
/// 详细说明（可选）
///
/// 示例:
/// ```dart
/// final viewModel = ref.watch(featureViewModelProvider);
/// ```
class FeatureViewModel extends _$FeatureViewModel {
  /// 方法描述
  ///
  /// [param] 参数说明
  /// 返回值说明
  Future<void> loadData(String param) async {
    // 实现
  }
}
```

### 错误处理

```dart
// 使用 Result 类型
Future<Result<Data>> getData() async {
  try {
    final data = await service.fetchData();
    return Result.ok(data);
  } on NetworkException catch (e) {
    return Result.error(e);
  } catch (e) {
    return Result.error(Exception('Unknown error: $e'));
  }
}

// 在 ViewModel 中处理
void _onLoadComplete() {
  _loadCommand.result!.when(
    ok: (data) {
      state = state.copyWith(data: data);
    },
    error: (error) {
      // 处理错误
    },
  );
}
```

---

## 依赖注入

### Provider 定义

```dart
// Service Provider
@riverpod
FeatureService featureService(FeatureServiceRef ref) {
  return FeatureServiceImpl();
}

// Repository Provider
@riverpod
FeatureRepository featureRepository(FeatureRepositoryRef ref) {
  final service = ref.watch(featureServiceProvider);
  return FeatureRepositoryImpl(service: service);
}

// ViewModel Provider
@Riverpod(keepAlive: true)
class FeatureViewModel extends _$FeatureViewModel {
  @override
  FeatureState build() {
    final repository = ref.watch(featureRepositoryProvider);
    return FeatureState.initial();
  }
}
```

### 使用 Provider

```dart
// 监听状态（响应式）
final state = ref.watch(featureViewModelProvider);

// 调用方法（非响应式）
ref.read(featureViewModelProvider.notifier).loadData();

// 获取依赖
final repository = ref.watch(featureRepositoryProvider);
```

### Provider 生命周期

- **AutoDisposeProvider**: 无监听者时自动销毁
- **NotifierProvider**: 默认自动销毁
- **NotifierProvider(keepAlive: true)**: 保持活跃

---

## 状态管理

### Command 模式

```dart
// 无参数命令
final loadCommand = Command<Data>(
  action: () => repository.getData(),
);

// 单参数命令
final updateCommand = Command1<Data, Data>(
  action: (Data data) => repository.updateData(data),
);

// 使用命令
await loadCommand.execute();

// 监听命令状态
if (loadCommand.running) {
  // 显示加载中
} else if (loadCommand.successful) {
  // 显示成功
} else if (loadCommand.failed) {
  // 显示错误
}
```

### 状态更新

```dart
// 使用 copyWith 更新状态
void updateName(String name) {
  state = state.copyWith(name: name);
}

// 批量更新
void updateAll({
  String? name,
  String? email,
}) {
  state = state.copyWith(
    name: name,
    email: email,
  );
}
```

---

## 命名规范

### 文件命名

- **小写蛇形**: `user_profile_screen.dart`
- **功能前缀**: `{feature}_{type}.dart`

### 类命名

- **大驼峰**: `UserProfileScreen`
- **后缀规范**:
  - Screen: 页面
  - ViewModel: 视图模型
  - State: 状态
  - Repository: 仓库
  - Service: 服务
  - Model: 模型

### 变量命名

- **小驼峰**: `userName`
- **私有变量**: `_userName`
- **常量**: `MAX_COUNT`

### Provider 命名

```dart
// 函数式 Provider
@riverpod
FeatureService featureService(FeatureServiceRef ref) {}

// 类式 Provider
@Riverpod(keepAlive: true)
class FeatureViewModel extends _$FeatureViewModel {}
```

---

## 最佳实践

### 1. 避免在 View 中处理业务逻辑

```dart
// ❌ 错误
class BadScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // 业务逻辑不应该在这里
        final data = fetchData();
        processData(data);
      },
      child: Text('Submit'),
    );
  }
}

// ✅ 正确
class GoodScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        ref.read(viewModelProvider.notifier).submit();
      },
      child: Text('Submit'),
    );
  }
}
```

### 2. 使用不可变状态

```dart
// ❌ 错误
class BadState {
  String name; // 不是 final
}

// ✅ 正确
class GoodState {
  final String name;
}
```

### 3. 正确使用 ref.watch 和 ref.read

```dart
// ✅ 监听状态变化
final state = ref.watch(viewModelProvider);

// ✅ 调用方法（不建立响应式依赖）
ref.read(viewModelProvider.notifier).loadData();

// ❌ 错误：在 build 中使用 ref.read 调用方法
@override
Widget build(BuildContext context, WidgetRef ref) {
  ref.read(viewModelProvider.notifier).loadData(); // 会导致重复调用
  return Container();
}
```

### 4. 错误处理

```dart
// ✅ 使用 Result 类型
Future<Result<Data>> getData() async {
  try {
    final data = await service.fetchData();
    return Result.ok(data);
  } catch (e) {
    return Result.error(e as Exception);
  }
}

// ❌ 直接抛出异常
Future<Data> getData() async {
  return await service.fetchData(); // 异常会传播到 UI
}
```

### 5. 测试友好

```dart
// ✅ 使用依赖注入，便于测试
@riverpod
FeatureRepository featureRepository(FeatureRepositoryRef ref) {
  final service = ref.watch(featureServiceProvider);
  return FeatureRepositoryImpl(service: service);
}

// 测试时可以覆盖
final container = ProviderContainer(
  overrides: [
    featureServiceProvider.overrideWithValue(MockService()),
  ],
);
```

---

## 开发流程

### 1. 创建新功能

1. 创建目录结构
2. 定义 Model
3. 实现 Service
4. 实现 Repository
5. 定义 State
6. 实现 ViewModel
7. 创建 View
8. 运行代码生成

### 2. 代码生成

```bash
# 生成代码
make gen
# 或
dart run build_runner build --delete-conflicting-outputs

# 监听文件变化
make watch
# 或
dart run build_runner watch
```

### 3. 代码检查

```bash
# 运行分析
make analyze
# 或
flutter analyze

# 运行测试
make test
# 或
flutter test
```

---

## 总结

本规范定义了基于 MVVM 模式的 Flutter 应用开发标准，遵循这些规范可以：

1. **提高代码质量**: 清晰的分层和职责划分
2. **增强可维护性**: 统一的代码风格和结构
3. **提升可测试性**: 依赖注入和模块化设计
4. **加快开发速度**: 减少决策时间，提高效率
5. **降低学习成本**: 新成员快速上手

所有项目都应遵循本规范，确保代码的一致性和可维护性。