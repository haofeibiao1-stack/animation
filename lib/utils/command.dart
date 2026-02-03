import 'package:flutter/foundation.dart';
import 'package:animation/utils/result.dart';

/// Command 类用于封装异步操作，提供统一的加载状态和错误处理
/// 这是 Flutter 架构推荐的 ViewModel 中处理异步操作的模式
///
/// Command 主要职责：
/// 1. 封装异步操作
/// 2. 管理加载状态
/// 3. 存储最新结果
/// 4. 通知监听器状态变化
/// 5. 支持取消和重试
class Command<T> extends ChangeNotifier {
  /// 异步操作函数
  final Future<Result<T>> Function() _action;

  /// 当前是否正在执行
  bool _running = false;
  bool get running => _running;

  /// 最新的执行结果
  Result<T>? _result;
  Result<T>? get result => _result;

  /// 是否已完成（无论成功或失败）
  bool get completed => _result != null;

  /// 是否执行成功
  bool get successful => _result != null && _result!.isOk;

  /// 是否执行失败
  bool get failed => _result != null && _result!.isError;

  /// 获取错误信息
  Exception? get error => _result?.error;

  /// 获取成功的值
  T? get value => _result?.isOk == true ? _result!.value : null;

  Command({required Future<Result<T>> Function() action}) : _action = action;

  /// 创建一个不带参数的 Command
  factory Command.simple(Future<Result<T>> Function() action) {
    return Command(action: action);
  }

  /// 执行命令
  /// 如果命令正在执行中，则忽略此次调用
  Future<void> execute() async {
    if (_running) {
      return;
    }

    _running = true;
    _result = null;
    notifyListeners();

    try {
      _result = await _action();
    } catch (e) {
      _result = Result.error(
        e is Exception ? e : Exception(e.toString()),
      );
    } finally {
      _running = false;
      notifyListeners();
    }
  }

  /// 重置命令状态
  void reset() {
    _running = false;
    _result = null;
    notifyListeners();
  }

  /// 清除结果但保持其他状态
  void clearResult() {
    _result = null;
    notifyListeners();
  }
}

/// 带参数的 Command
/// 允许执行时传入参数
class Command1<T, A> extends ChangeNotifier {
  /// 异步操作函数（带一个参数）
  final Future<Result<T>> Function(A arg) _action;

  /// 当前是否正在执行
  bool _running = false;
  bool get running => _running;

  /// 最新的执行结果
  Result<T>? _result;
  Result<T>? get result => _result;

  /// 是否已完成
  bool get completed => _result != null;

  /// 是否执行成功
  bool get successful => _result != null && _result!.isOk;

  /// 是否执行失败
  bool get failed => _result != null && _result!.isError;

  /// 获取错误信息
  Exception? get error => _result?.error;

  /// 获取成功的值
  T? get value => _result?.isOk == true ? _result!.value : null;

  Command1({required Future<Result<T>> Function(A arg) action})
      : _action = action;

  /// 执行命令
  Future<void> execute(A arg) async {
    if (_running) {
      return;
    }

    _running = true;
    _result = null;
    notifyListeners();

    try {
      _result = await _action(arg);
    } catch (e) {
      _result = Result.error(
        e is Exception ? e : Exception(e.toString()),
      );
    } finally {
      _running = false;
      notifyListeners();
    }
  }

  /// 重置命令状态
  void reset() {
    _running = false;
    _result = null;
    notifyListeners();
  }
}

/// 带两个参数的 Command
class Command2<T, A, B> extends ChangeNotifier {
  /// 异步操作函数（带两个参数）
  final Future<Result<T>> Function(A arg1, B arg2) _action;

  /// 当前是否正在执行
  bool _running = false;
  bool get running => _running;

  /// 最新的执行结果
  Result<T>? _result;
  Result<T>? get result => _result;

  /// 是否已完成
  bool get completed => _result != null;

  /// 是否执行成功
  bool get successful => _result != null && _result!.isOk;

  /// 是否执行失败
  bool get failed => _result != null && _result!.isError;

  /// 获取错误信息
  Exception? get error => _result?.error;

  /// 获取成功的值
  T? get value => _result?.isOk == true ? _result!.value : null;

  Command2({required Future<Result<T>> Function(A arg1, B arg2) action})
      : _action = action;

  /// 执行命令
  Future<void> execute(A arg1, B arg2) async {
    if (_running) {
      return;
    }

    _running = true;
    _result = null;
    notifyListeners();

    try {
      _result = await _action(arg1, arg2);
    } catch (e) {
      _result = Result.error(
        e is Exception ? e : Exception(e.toString()),
      );
    } finally {
      _running = false;
      notifyListeners();
    }
  }

  /// 重置命令状态
  void reset() {
    _running = false;
    _result = null;
    notifyListeners();
  }
}