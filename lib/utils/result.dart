/// Result 类型用于封装操作结果，可以是成功(Ok)或失败(Error)
/// 这是 Flutter 架构推荐的错误处理模式
sealed class Result<T> {
  const Result();

  /// 创建一个成功的结果
  factory Result.ok(T value) = Ok<T>;

  /// 创建一个失败的结果
  factory Result.error(Exception error) = Error<T>;

  /// 判断是否成功
  bool get isOk => this is Ok<T>;

  /// 判断是否失败
  bool get isError => this is Error<T>;

  /// 获取成功的值，如果是错误则抛出异常
  T get value {
    if (this is Ok<T>) {
      return (this as Ok<T>).value;
    }
    throw (this as Error<T>).error;
  }

  /// 获取错误，如果是成功则返回 null
  Exception? get error {
    if (this is Error<T>) {
      return (this as Error<T>).error;
    }
    return null;
  }

  /// 模式匹配：根据结果类型执行不同的操作
  R when<R>({
    required R Function(T value) ok,
    required R Function(Exception error) error,
  }) {
    return switch (this) {
      Ok<T>(value: final v) => ok(v),
      Error<T>(error: final e) => error(e),
    };
  }

  /// 转换成功的值
  Result<R> map<R>(R Function(T value) mapper) {
    return switch (this) {
      Ok<T>(value: final v) => Result.ok(mapper(v)),
      Error<T>(error: final e) => Result.error(e),
    };
  }

  /// 转换成功的值（返回 Result）
  Result<R> flatMap<R>(Result<R> Function(T value) mapper) {
    return switch (this) {
      Ok<T>(value: final v) => mapper(v),
      Error<T>(error: final e) => Result.error(e),
    };
  }
}

/// 表示成功的结果
final class Ok<T> extends Result<T> {
  const Ok(this.value);

  @override
  final T value;

  @override
  String toString() => 'Ok($value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ok<T> && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// 表示失败的结果
final class Error<T> extends Result<T> {
  const Error(this.error);

  @override
  final Exception error;

  @override
  String toString() => 'Error($error)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Error<T> && runtimeType == other.runtimeType && error == other.error;

  @override
  int get hashCode => error.hashCode;
}