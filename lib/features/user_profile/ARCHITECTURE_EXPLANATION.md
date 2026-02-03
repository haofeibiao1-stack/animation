# Flutter 推荐架构详解

本示例展示了 Flutter 官方推荐的应用架构模式，基于 [Flutter 架构指南](https://docs.flutter.cn/app-architecture/guide) 实现。该架构遵循关注点分离原则，将应用分为多个清晰的层，每层都有明确的职责。

## 架构层次结构

### 1. UI 层 (Presentation Layer)

UI 层负责构建用户界面并响应用户交互。它包含以下组件：

#### Views (视图)
- **职责**: 显示数据和处理用户交互
- **实现**: `user_profile_screen.dart`
- **特点**: 
  - 无业务逻辑，仅负责 UI 渲染
  - 通过 ViewModel 获取数据和执行操作
  - 使用 Riverpod 的 `ConsumerWidget` 监听状态变化

#### ViewModels (视图模型)
- **职责**: 管理 UI 状态和业务逻辑
- **实现**: `user_profile_viewmodel.dart`
- **特点**:
  - 使用 `@riverpod` 注解自动生成 Provider
  - 继承 `_$ClassName` (代码生成的基类)
  - 使用 `Command` 模式处理异步操作
  - 与 Repository 层交互获取数据

#### State (状态)
- **职责**: 定义 UI 状态的不可变数据结构
- **实现**: `user_profile_state.dart`
- **特点**:
  - 使用不可变类存储状态
  - 实现 `copyWith` 方法支持状态更新
  - 包含所有与 UI 相关的状态字段

### 2. Data 层 (数据层)

Data 层负责数据获取、存储和管理。它包含以下组件：

#### Repositories (仓库)
- **职责**: 作为 UI 层和数据源之间的桥梁
- **实现**: `user_repository.dart`
- **特点**:
  - 定义业务数据操作接口
  - 处理数据验证、转换和缓存
  - 协调多个数据源

#### Services (服务)
- **职责**: 与外部数据源交互
- **实现**: `user_service.dart`
- **特点**:
  - 实现具体的 API 调用或数据库操作
  - 处理网络错误和异常
  - 返回原始数据

### 3. Domain 层 (领域层)

Domain 层包含核心业务逻辑和实体模型：

#### Models (模型)
- **职责**: 定义应用中的数据结构
- **实现**: `user.dart`
- **特点**:
  - 包含数据序列化/反序列化逻辑
  - 实现数据验证和转换方法
  - 实现 `copyWith` 方法支持数据更新

#### Commands (命令)
- **职责**: 封装异步操作和状态管理
- **实现**: `command.dart`
- **特点**:
  - 统一处理加载、成功、失败状态
  - 支持参数化操作
  - 提供重试和取消功能

## 各层级职责详解

### Views (视图) - lib/features/user_profile/presentation/views/

**职责**:
1. 构建用户界面
2. 响应用户交互事件
3. 从 ViewModel 获取数据并显示
4. 处理导航和路由

**为什么这样拆分**:
- 保持 UI 代码简洁，专注于展示逻辑
- 便于测试和维护
- 支持多种 UI 实现（如 Web、桌面、移动端）

### ViewModels (视图模型) - lib/features/user_profile/presentation/viewmodels/

**职责**:
1. 管理 UI 状态
2. 处理业务逻辑
3. 协调数据获取和更新
4. 提供命令供 UI 调用

**为什么这样拆分**:
- 分离业务逻辑和 UI 逻辑
- 实现状态共享和响应式更新
- 便于单元测试

### Repositories (仓库) - lib/features/user_profile/data/repositories/

**职责**:
1. 定义业务数据操作接口
2. 处理数据验证和转换
3. 管理缓存策略
4. 协调多个数据源

**为什么这样拆分**:
- 隐藏数据源实现细节
- 提供统一的数据访问接口
- 支持离线模式和缓存

### Services (服务) - lib/features/user_profile/data/services/

**职责**:
1. 与外部 API 或数据库交互
2. 处理网络请求和响应
3. 管理认证和授权
4. 处理数据序列化

**为什么这样拆分**:
- 集中处理数据源特定逻辑
- 便于替换或扩展数据源
- 支持多种数据源（REST、GraphQL、数据库等）

### Commands (命令) - lib/utils/command.dart

**职责**:
1. 封装异步操作
2. 管理操作状态（加载、成功、失败）
3. 提供重试和取消机制
4. 统一错误处理

**为什么这样拆分**:
- 简化异步操作处理
- 提供一致的用户体验
- 支持操作状态的响应式更新

## 数据流转过程

```
[User Action] → [View] → [ViewModel] → [Repository] → [Service] → [External API/Database]
     ↑              ↑          ↑            ↑           ↑              ↓
     |              |          |            |           |              |
     |         [State Update]  |            |           |         [Response]
     |              ↑          |            |           ↓              |
     |              |          |       [Data Processing]              |
     |              |          ↓            |                          |
     |         [Command] ← [Result] ← [Result] ← [Result] ← [Result]  |
     |              |                                                    |
     |              ↓                                                    |
[UI Update] ← [ViewModel] ← [Repository] ← [Service] ← [External API/Database]
```

### 详细流程:

1. **用户操作**: 用户在 UI 上执行操作（如点击按钮）
2. **View 处理**: View 捕获事件并调用 ViewModel 的相应方法
3. **ViewModel 执行**: ViewModel 通过 Command 执行异步操作
4. **Repository 调用**: Command 调用 Repository 的业务方法
5. **Service 调用**: Repository 调用 Service 进行数据操作
6. **外部数据源**: Service 与外部 API 或数据库交互
7. **响应返回**: 数据源返回响应给 Service
8. **数据处理**: Service 处理响应并返回给 Repository
9. **结果封装**: Repository 将结果封装为 Result 对象返回
10. **状态更新**: ViewModel 更新 State 并通过 Command 通知 View
11. **UI 更新**: View 监听到状态变化并更新 UI

## 依赖注入实现（使用 Riverpod 代码生成）

本项目使用 Riverpod 的代码生成注解方式实现依赖注入，这是 Riverpod 推荐的最佳实践。

### 依赖配置

在 `pubspec.yaml` 中添加以下依赖：

```yaml
dependencies:
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0

dev_dependencies:
  riverpod_generator: ^2.3.0
  build_runner: ^2.4.0
```

### Provider 定义方式

使用 `@riverpod` 注解自动生成 Provider：

#### 1. 简单 Provider（函数式）

```dart
// user_profile_viewmodel.dart
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
```

#### 2. Notifier Provider（类式）

```dart
/// 用户信息页面的 ViewModel
/// 使用 @Riverpod(keepAlive: true) 保持状态在页面切换时不被销毁
@Riverpod(keepAlive: true)
class UserProfileViewModel extends _$UserProfileViewModel {
  
  @override
  UserProfileState build() {
    // 获取 Repository
    final userRepository = ref.watch(userRepositoryProvider);
    
    // 初始化命令
    _loadUserCommand = Command<User>(
      action: () => userRepository.getUser('1'),
    );
    
    // 返回初始状态
    return UserProfileState.initial(
      loadUserCommand: _loadUserCommand,
      // ...
    );
  }
  
  /// 加载用户信息
  Future<void> loadUser(String userId) async {
    await _loadUserCommand.execute();
  }
  
  /// 更新状态
  void updateNameInput(String name) {
    state = state.copyWith(nameInput: name);
  }
}
```

### 代码生成

运行以下命令生成 Provider 代码：

```bash
# 一次性生成
make gen
# 或
dart run build_runner build --delete-conflicting-outputs

# 监听文件变化并自动生成
make watch
# 或
dart run build_runner watch
```

生成的代码会在 `.g.dart` 文件中：

```dart
// user_profile_viewmodel.g.dart (自动生成)
part of 'user_profile_viewmodel.dart';

final userServiceProvider = AutoDisposeProvider<UserService>((ref) {
  return userService(ref);
});

final userRepositoryProvider = AutoDisposeProvider<UserRepository>((ref) {
  return userRepository(ref);
});

final userProfileViewModelProvider = 
    NotifierProvider<UserProfileViewModel, UserProfileState>(() {
  return UserProfileViewModel();
});
```

### View 使用方式

```dart
class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听状态变化
    final viewModelState = ref.watch(userProfileViewModelProvider);
    
    return Scaffold(
      body: _buildBody(ref, viewModelState),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 调用 ViewModel 方法
          ref.read(userProfileViewModelProvider.notifier).loadUser('1');
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}
```

### Riverpod 代码生成的优势

1. **减少样板代码**: 自动生成 Provider 定义
2. **类型安全**: 编译时检查类型错误
3. **一致性**: 统一的 Provider 定义方式
4. **可维护性**: 代码结构更清晰
5. **IDE 支持**: 更好的代码补全和导航

### keepAlive 参数说明

- `@riverpod`：默认自动销毁，当没有监听者时会被销毁
- `@Riverpod(keepAlive: true)`：保持活跃，即使没有监听者也不会被销毁

### 依赖注入优势

1. **解耦**: 组件之间不直接依赖具体实现
2. **可测试**: 便于注入 Mock 对象进行单元测试
3. **可扩展**: 便于替换或扩展组件实现
4. **生命周期管理**: Riverpod 自动管理 Provider 生命周期

## 不可变状态设计

### State 类设计

```dart
/// 用户信息页面状态（不可变）
class UserProfileState {
  final User? user;
  final String nameInput;
  final String emailInput;
  final Command<User> loadUserCommand;
  final Command1<User, User> updateUserCommand;
  final Command1<void, String> deleteUserCommand;

  const UserProfileState({
    required this.user,
    required this.nameInput,
    required this.emailInput,
    required this.loadUserCommand,
    required this.updateUserCommand,
    required this.deleteUserCommand,
  });

  /// 创建初始状态
  factory UserProfileState.initial({
    required Command<User> loadUserCommand,
    required Command1<User, User> updateUserCommand,
    required Command1<void, String> deleteUserCommand,
  }) {
    return UserProfileState(
      user: null,
      nameInput: '',
      emailInput: '',
      loadUserCommand: loadUserCommand,
      updateUserCommand: updateUserCommand,
      deleteUserCommand: deleteUserCommand,
    );
  }

  /// 复制并修改状态
  UserProfileState copyWith({
    User? user,
    String? nameInput,
    String? emailInput,
    Command<User>? loadUserCommand,
    Command1<User, User>? updateUserCommand,
    Command1<void, String>? deleteUserCommand,
  }) {
    return UserProfileState(
      user: user ?? this.user,
      nameInput: nameInput ?? this.nameInput,
      emailInput: emailInput ?? this.emailInput,
      loadUserCommand: loadUserCommand ?? this.loadUserCommand,
      updateUserCommand: updateUserCommand ?? this.updateUserCommand,
      deleteUserCommand: deleteUserCommand ?? this.deleteUserCommand,
    );
  }
}
```

### 状态更新方式

在 ViewModel 中通过 `copyWith` 更新状态：

```dart
void updateNameInput(String name) {
  state = state.copyWith(nameInput: name);
}
```

## 架构优势

### 1. 关注点分离
- 每层职责明确，代码结构清晰
- 便于团队协作和代码维护

### 2. 可测试性
- 业务逻辑集中在 ViewModel 和 Repository
- 便于编写单元测试和集成测试

### 3. 可扩展性
- 支持多种数据源
- 便于添加新功能和修改现有功能

### 4. 可维护性
- 组件解耦，修改影响范围小
- 便于重构和优化

### 5. 一致性
- 提供统一的开发模式
- 降低团队成员学习成本

## 最佳实践

### 1. 错误处理
- 使用 `Result<T>` 类型统一处理成功和失败情况
- 在各层合理处理和转换错误

### 2. 状态管理
- 使用 `Command` 模式管理异步操作状态
- 使用不可变状态避免意外修改
- 通过 `copyWith` 方法更新状态

### 3. 依赖注入
- 使用 `@riverpod` 注解定义 Provider
- 通过 `ref.watch()` 获取依赖并建立响应式依赖关系
- 使用 `ref.read()` 调用方法（不建立响应式依赖）

### 4. 数据流
- 保持单向数据流
- 避免在 View 中直接处理业务逻辑

### 5. 测试

```dart
// 测试示例
void main() {
  test('loads user successfully', () async {
    final container = ProviderContainer(
      overrides: [
        userServiceProvider.overrideWithValue(MockUserService()),
      ],
    );
    
    // 监听状态变化
    final viewModel = container.read(userProfileViewModelProvider.notifier);
    await viewModel.loadUser('1');
    
    final state = container.read(userProfileViewModelProvider);
    expect(state.user, isNotNull);
  });
}
```

## 项目结构

```
lib/
├── features/
│   └── user_profile/
│       ├── data/
│       │   ├── models/
│       │   │   └── user.dart
│       │   ├── repositories/
│       │   │   └── user_repository.dart
│       │   └── services/
│       │       └── user_service.dart
│       └── presentation/
│           ├── viewmodels/
│           │   ├── user_profile_state.dart
│           │   ├── user_profile_viewmodel.dart
│           │   └── user_profile_viewmodel.g.dart (生成)
│           └── views/
│               └── user_profile_screen.dart
├── utils/
│   ├── command.dart
│   └── result.dart
└── main.dart
```

## 开发命令

项目提供了 Makefile 简化常用操作：

```bash
# 显示帮助
make help

# 生成代码
make gen

# 监听文件变化并自动生成
make watch

# 获取依赖
make get

# 清理项目
make clean

# 运行代码分析
make analyze

# 运行测试
make test

# 运行应用
make run

# 完全重置项目
make reset
```

## 总结

本示例展示了 Flutter 推荐的分层架构模式，结合 Riverpod 代码生成进行状态管理和依赖注入，通过合理的分层和组件设计，实现了关注点分离、可测试性和可维护性。使用 `@riverpod` 注解可以大幅减少样板代码，提高开发效率。该架构适用于中小型到大型 Flutter 应用，能够有效管理应用复杂度并提高开发效率。