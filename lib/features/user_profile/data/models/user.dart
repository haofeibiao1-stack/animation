/// 用户数据模型
/// 这是应用中用户信息的数据结构定义
class User {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.createdAt,
  });

  /// 从 JSON 创建 User 实例
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// 将 User 实例转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 创建一个 User 的副本（用于不可变更新）
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          avatarUrl == other.avatarUrl &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      avatarUrl.hashCode ^
      createdAt.hashCode;

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, avatarUrl: $avatarUrl, createdAt: $createdAt)';
  }
}