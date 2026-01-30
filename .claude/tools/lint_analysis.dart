import 'dart:convert';
import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:yaml/yaml.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;

/// ============================================
/// Flutter 硬编码字符串智能检测工具 v2.0
/// ============================================
/// Author: zhengshuaijie
/// Email: zhengshuaijie@360.cn
/// Created: 2025/11/14
/// Updated: 2025/12/02
/// ============================================
/// 功能特性：
/// - 同时检测 MethodInvocation 和 InstanceCreationExpression
/// - 支持 YAML 配置文件
/// - 深度检测嵌套组件中的字符串
/// - 检测条件表达式中的字符串
/// - 灵活的字符串过滤规则
/// - 多种输出格式（console/json/csv）
/// ============================================
///
/// 使用方法：
/// 1. 创建运行目录并添加 pubspec.yaml:
///    name: lint_runner
///    environment:
///      sdk: ">=3.0.0 <4.0.0"
///    dependencies:
///      analyzer: ^6.0.0
///      yaml: ^3.1.0
///      glob: ^2.1.0
///      path: ^1.8.0
///
/// 2. 运行 dart pub get
///
/// 3. 在项目根目录运行：
///    dart run modules/learn_lib/.claude/tools/lint_analysis.dart modules/learn_lib/.claude/tools/lint_config.yaml
/// ============================================

void main(List<String> args) async {
  // 解析命令行参数
  final configPath = args.isNotEmpty
      ? args[0]
      : 'modules/learn_lib/.claude/tools/lint_config.yaml';

  // 加载配置
  final config = LintConfig.load(configPath);

  print('🔧 配置文件: $configPath');
  print(
      '📦 启用模块: ${config.modules.entries.where((e) => e.value).map((e) => e.key).join(", ")}');
  print('📁 扫描目录: ${config.scanDirectories.join(", ")}');
  print('');

  final results = <HardcodedString>[];

  for (final dirPath in config.scanDirectories) {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) {
      print('⚠️ 目录不存在: $dirPath');
      continue;
    }

    final dartFiles = dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !config.isExcluded(f.path));

    for (var file in dartFiles) {
      try {
        final source = file.readAsStringSync();
        final result = parseString(content: source, path: file.path);
        final unit = result.unit;

        final checker = HardcodedStringChecker(
          filePath: file.path,
          lineInfo: result.lineInfo,
          config: config,
        );
        unit.visitChildren(checker);
        results.addAll(checker.results);
      } catch (e) {
        print('❌ 解析失败: ${file.path}');
        print('   错误: $e');
      }
    }
  }

  // 输出结果
  config.outputResults(results);
}

/// ============================================
/// 配置类
/// ============================================
class LintConfig {
  final List<String> scanDirectories;
  final Map<String, bool> modules;
  final List<Glob> excludePatterns;
  final Map<String, WidgetTypeConfig> widgetTypes;
  final Map<String, bool> namedArguments;
  final List<String> deepCheckArguments;
  final bool checkConditionalExpression;
  final List<String> excludeConditionalInMethods;
  final List<String> excludeAllInMethods;
  final Set<String> excludeMethodCalls;
  final StringFilterConfig stringFilters;
  final OutputConfig output;

  // 新增：需要检测的函数调用（检测位置参数和命名参数）
  final Set<String> checkFunctionCalls;
  // 新增：是否检测变量声明中的硬编码字符串
  final bool checkVariableDeclaration;

  // v2.1 新增检测项
  // 是否检测 Map/Set 字面量中的中文字符串
  final bool checkMapLiteral;
  // 是否检测 return 语句中的中文字符串
  final bool checkReturnStatement;
  // 是否检测 throw 表达式中的中文字符串
  final bool checkThrowExpression;
  // 是否检测字符串插值中的中文部分
  final bool checkStringInterpolation;
  // 是否检测 DateFormat 格式串中的中文
  final bool checkDateFormat;
  // 额外需要检测的命名参数（如 name, description 等）
  final Set<String> additionalNamedParams;

  LintConfig({
    required this.scanDirectories,
    required this.modules,
    required this.excludePatterns,
    required this.widgetTypes,
    required this.namedArguments,
    required this.deepCheckArguments,
    required this.checkConditionalExpression,
    required this.excludeConditionalInMethods,
    required this.excludeAllInMethods,
    required this.excludeMethodCalls,
    required this.stringFilters,
    required this.output,
    required this.checkFunctionCalls,
    required this.checkVariableDeclaration,
    this.checkMapLiteral = true,
    this.checkReturnStatement = true,
    this.checkThrowExpression = true,
    this.checkStringInterpolation = true,
    this.checkDateFormat = true,
    this.additionalNamedParams = const {'name', 'description', 'placeholder', 'hint'},
  });

  factory LintConfig.load(String configPath) {
    final file = File(configPath);
    if (!file.existsSync()) {
      print('⚠️ 配置文件不存在，使用默认配置: $configPath');
      return LintConfig.defaults();
    }

    final yaml = loadYaml(file.readAsStringSync()) as YamlMap;

    // 解析模块配置
    final modulesYaml = yaml['modules'] as YamlMap? ?? YamlMap();
    final modules = <String, bool>{};
    for (final entry in modulesYaml.entries) {
      modules[entry.key.toString()] = entry.value as bool? ?? false;
    }

    // 解析基础目录
    final baseDir = yaml['base_directory']?.toString() ?? 'modules';

    // 根据模块配置生成扫描目录
    final scanDirs = <String>[];
    if (modules.isEmpty) {
      // 如果没有配置模块，使用旧的 scan_directories 配置
      final oldScanDirs = (yaml['scan_directories'] as YamlList?)
          ?.map((e) => e.toString())
          .toList();
      if (oldScanDirs != null && oldScanDirs.isNotEmpty) {
        scanDirs.addAll(oldScanDirs);
      } else {
        scanDirs.add(baseDir);
      }
    } else {
      // 根据模块配置生成扫描目录
      for (final entry in modules.entries) {
        if (entry.value) {
          scanDirs.add('$baseDir/${entry.key}');
        }
      }
    }

    // 解析排除模式
    final excludes = (yaml['exclude_patterns'] as YamlList?)
            ?.map((e) => Glob(e.toString()))
            .toList() ??
        [];

    // 解析组件类型配置
    final widgetTypesYaml = yaml['widget_types'] as YamlMap? ?? YamlMap();
    final widgetTypes = <String, WidgetTypeConfig>{};
    for (final entry in widgetTypesYaml.entries) {
      final name = entry.key.toString();
      final config = entry.value as YamlMap;
      widgetTypes[name] = WidgetTypeConfig(
        enabled: config['enabled'] as bool? ?? true,
        checkPositional: config['check_positional'] as bool? ?? true,
        checkNamed: config['check_named'] as bool? ?? true,
      );
    }

    // 解析命名参数配置
    final namedArgsYaml = yaml['named_arguments'] as YamlMap? ?? YamlMap();
    final namedArguments = <String, bool>{};
    for (final entry in namedArgsYaml.entries) {
      namedArguments[entry.key.toString()] = entry.value as bool? ?? true;
    }

    // 解析深度检测参数
    final deepCheckArgs = (yaml['deep_check_arguments'] as YamlList?)
            ?.map((e) => e.toString())
            .toList() ??
        ['child', 'title', 'label'];

    // 解析条件表达式检测
    final checkConditional =
        yaml['check_conditional_expression'] as bool? ?? true;

    // 解析排除条件表达式检测的方法
    final excludeConditionalInMethods =
        (yaml['exclude_conditional_in_methods'] as YamlList?)
                ?.map((e) => e.toString().toLowerCase())
                .toList() ??
            [];

    // 解析完全排除检测的方法
    final excludeAllInMethods = (yaml['exclude_all_in_methods'] as YamlList?)
            ?.map((e) => e.toString().toLowerCase())
            .toList() ??
        [];

    // 解析排除的方法调用
    final excludeMethodCalls = (yaml['exclude_method_calls'] as YamlList?)
            ?.map((e) => e.toString())
            .toSet() ??
        {'DottingUtil.onEvent', 'debugPrint', 'print'};

    // 解析字符串过滤配置
    final filtersYaml = yaml['string_filters'] as YamlMap? ?? YamlMap();
    final stringFilters = StringFilterConfig(
      minLength: filtersYaml['min_length'] as int? ?? 1,
      ignoreNumbers: filtersYaml['ignore_numbers'] as bool? ?? true,
      ignorePunctuation: filtersYaml['ignore_punctuation'] as bool? ?? true,
      ignoreWhitespace: filtersYaml['ignore_whitespace'] as bool? ?? true,
      chineseOnly: filtersYaml['chinese_only'] as bool? ?? false,
      whitelist: (filtersYaml['whitelist'] as YamlList?)
              ?.map((e) => e.toString())
              .toSet() ??
          {},
      whitelistPatterns: (filtersYaml['whitelist_patterns'] as YamlList?)
              ?.map((e) => RegExp(e.toString()))
              .toList() ??
          [],
    );

    // 解析输出配置
    final outputYaml = yaml['output'] as YamlMap? ?? YamlMap();
    final output = OutputConfig(
      format: outputYaml['format']?.toString() ?? 'console',
      groupByFile: outputYaml['group_by_file'] as bool? ?? true,
      showContext: outputYaml['show_context'] as bool? ?? true,
      outputFile:
          outputYaml['output_file']?.toString() ?? 'hardcode_report.json',
    );

    // 解析需要检测的函数调用（强制启用 showToast 和 showPermissionDialog）
    final checkFunctionCalls = (yaml['check_function_calls'] as YamlList?)
            ?.map((e) => e.toString())
            .toSet() ??
        {'showToast', 'showPermissionDialog'};
    // 强制添加这两个
    checkFunctionCalls.addAll(['showToast', 'showPermissionDialog']);

    // 解析是否检测变量声明（默认启用）
    final checkVariableDeclaration =
        yaml['check_variable_declaration'] as bool? ?? true;

    return LintConfig(
      scanDirectories: scanDirs,
      modules: modules,
      excludePatterns: excludes,
      widgetTypes: widgetTypes,
      namedArguments: namedArguments,
      deepCheckArguments: deepCheckArgs,
      checkConditionalExpression: checkConditional,
      excludeConditionalInMethods: excludeConditionalInMethods,
      excludeAllInMethods: excludeAllInMethods,
      excludeMethodCalls: excludeMethodCalls,
      stringFilters: stringFilters,
      output: output,
      checkFunctionCalls: checkFunctionCalls,
      checkVariableDeclaration: checkVariableDeclaration,
    );
  }

  factory LintConfig.defaults() {
    return LintConfig(
      scanDirectories: ['modules/learn_lib', 'modules/translator_lib'],
      modules: {
        'learn_lib': true,
        'translator_lib': true,
        'scanner_lib': false,
        'patronus': false,
      },
      excludePatterns: [
        Glob('**/generated/**'),
        Glob('**/l10n/**'),
        Glob('**/*.g.dart'),
      ],
      widgetTypes: {
        'Text': WidgetTypeConfig(
            enabled: true, checkPositional: true, checkNamed: false),
        'AppBar': WidgetTypeConfig(
            enabled: true, checkPositional: false, checkNamed: true),
        'TextField': WidgetTypeConfig(
            enabled: true, checkPositional: false, checkNamed: true),
        'TextFormField': WidgetTypeConfig(
            enabled: true, checkPositional: false, checkNamed: true),
      },
      namedArguments: {
        'hintText': true,
        'labelText': true,
        'title': true,
        'message': true,
      },
      deepCheckArguments: ['child', 'title', 'label'],
      checkConditionalExpression: true,
      excludeConditionalInMethods: [
        'report',
        'dotting',
        'track',
        'analytics',
        'log'
      ],
      excludeAllInMethods: ['buildexamplewidget'],
      excludeMethodCalls: {'DottingUtil.onEvent', 'debugPrint', 'print', 'log'},
      stringFilters: StringFilterConfig.defaults(),
      output: OutputConfig.defaults(),
      checkFunctionCalls: {'showToast', 'showPermissionDialog'},
      checkVariableDeclaration: true,
    );
  }

  bool isExcluded(String filePath) {
    for (final pattern in excludePatterns) {
      if (pattern.matches(filePath)) return true;
    }
    return false;
  }

  bool isWidgetEnabled(String name) {
    return widgetTypes[name]?.enabled ?? false;
  }

  bool shouldCheckPositional(String widgetName) {
    return widgetTypes[widgetName]?.checkPositional ?? false;
  }

  bool shouldCheckNamed(String widgetName) {
    return widgetTypes[widgetName]?.checkNamed ?? false;
  }

  bool isNamedArgumentEnabled(String name) {
    return namedArguments[name] ?? false;
  }

  void outputResults(List<HardcodedString> results) {
    if (results.isEmpty) {
      print('\n✅ 未发现硬编码字符串！');
      return;
    }

    switch (output.format) {
      case 'json':
        _outputJson(results);
        break;
      case 'csv':
        _outputCsv(results);
        break;
      default:
        _outputConsole(results);
    }
  }

  void _outputConsole(List<HardcodedString> results) {
    if (output.groupByFile) {
      final grouped = <String, List<HardcodedString>>{};
      for (final r in results) {
        grouped.putIfAbsent(r.filePath, () => []).add(r);
      }

      for (final entry in grouped.entries) {
        print('\n📁 ${entry.key} (${entry.value.length} 个)');
        print('─' * 60);
        for (final r in entry.value) {
          print('  📝 Line ${r.line}:${r.column} | ${r.source}');
          print('     → "${r.value}"');
          if (r.method != null) {
            print('     → method: ${r.method}');
          }
        }
      }
    } else {
      for (final r in results) {
        print('📝 ${r.filePath}:${r.line}:${r.column}');
        print('   → Source: ${r.source}');
        print('   → Value: "${r.value}"');
        print('');
      }
    }

    print('\n' + '═' * 60);
    print('✅ 扫描完成！共发现 ${results.length} 个硬编码字符串');
    print('═' * 60);
  }

  void _outputJson(List<HardcodedString> results) {
    final json = results.map((r) => r.toJson()).toList();
    final content = const JsonEncoder.withIndent('  ').convert({
      'total': results.length,
      'results': json,
    });

    File(output.outputFile).writeAsStringSync(content);
    print('\n✅ JSON 报告已生成: ${output.outputFile}');
    print('   共发现 ${results.length} 个硬编码字符串');
  }

  void _outputCsv(List<HardcodedString> results) {
    final buffer = StringBuffer();
    buffer.writeln('文件路径,行号,列号,来源,字符串内容,方法名');

    for (final r in results) {
      final escapedValue = r.value.replaceAll('"', '""');
      buffer.writeln(
          '"${r.filePath}",${r.line},${r.column},"${r.source}","$escapedValue","${r.method ?? ""}"');
    }

    final csvPath = output.outputFile.replaceAll('.json', '.csv');
    File(csvPath).writeAsStringSync(buffer.toString());
    print('\n✅ CSV 报告已生成: $csvPath');
    print('   共发现 ${results.length} 个硬编码字符串');
  }
}

class WidgetTypeConfig {
  final bool enabled;
  final bool checkPositional;
  final bool checkNamed;

  WidgetTypeConfig({
    required this.enabled,
    required this.checkPositional,
    required this.checkNamed,
  });
}

class StringFilterConfig {
  final int minLength;
  final bool ignoreNumbers;
  final bool ignorePunctuation;
  final bool ignoreWhitespace;
  final bool chineseOnly;
  final Set<String> whitelist;
  final List<RegExp> whitelistPatterns;

  StringFilterConfig({
    required this.minLength,
    required this.ignoreNumbers,
    required this.ignorePunctuation,
    required this.ignoreWhitespace,
    required this.chineseOnly,
    required this.whitelist,
    required this.whitelistPatterns,
  });

  factory StringFilterConfig.defaults() {
    return StringFilterConfig(
      minLength: 1,
      ignoreNumbers: true,
      ignorePunctuation: true,
      ignoreWhitespace: true,
      chineseOnly: false,
      whitelist: {'', ' ', '...'},
      whitelistPatterns: [RegExp(r'^\d+$'), RegExp(r'^https?://')],
    );
  }

  bool shouldFilter(String value) {
    // 空字符串
    if (value.trim().isEmpty) return true;

    // 长度过滤
    if (value.length < minLength) return true;

    // 白名单
    if (whitelist.contains(value)) return true;

    // 白名单正则
    for (final pattern in whitelistPatterns) {
      if (pattern.hasMatch(value)) return true;
    }

    // 纯空格
    if (ignoreWhitespace && value.trim().isEmpty) return true;

    // 纯数字
    if (ignoreNumbers && RegExp(r'^[\d\s.,]+$').hasMatch(value)) return true;

    // 纯标点符号
    if (ignorePunctuation &&
        RegExp(r'^[\p{P}\p{S}\s]+$', unicode: true).hasMatch(value))
      return true;

    // 只检测中文
    if (chineseOnly && !RegExp(r'[\u4e00-\u9fa5]').hasMatch(value)) return true;

    return false;
  }
}

class OutputConfig {
  final String format;
  final bool groupByFile;
  final bool showContext;
  final String outputFile;

  OutputConfig({
    required this.format,
    required this.groupByFile,
    required this.showContext,
    required this.outputFile,
  });

  factory OutputConfig.defaults() {
    return OutputConfig(
      format: 'console',
      groupByFile: true,
      showContext: true,
      outputFile: 'hardcode_report.json',
    );
  }
}

/// ============================================
/// 检测结果类
/// ============================================
class HardcodedString {
  final String filePath;
  final int line;
  final int column;
  final String source;
  final String value;
  final String? method;
  final String type; // positional, named, conditional

  HardcodedString({
    required this.filePath,
    required this.line,
    required this.column,
    required this.source,
    required this.value,
    this.method,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'filePath': filePath,
        'line': line,
        'column': column,
        'source': source,
        'value': value,
        'method': method,
        'type': type,
      };
}

/// ============================================
/// 硬编码字符串检查器
/// ============================================
class HardcodedStringChecker extends RecursiveAstVisitor<void> {
  final String filePath;
  final LineInfo lineInfo;
  final LintConfig config;
  final List<HardcodedString> results = [];

  String? _currentMethod;

  HardcodedStringChecker({
    required this.filePath,
    required this.lineInfo,
    required this.config,
  });

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _currentMethod = node.name.lexeme;
    super.visitMethodDeclaration(node);
    _currentMethod = null;
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _currentMethod = node.name.lexeme;
    super.visitFunctionDeclaration(node);
    _currentMethod = null;
  }

  /// 检查实例创建表达式（如 const Text("硬编码")）
  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name2.lexeme;

    // 检测 DateFormat 格式串中的中文
    if (config.checkDateFormat && typeName == 'DateFormat') {
      final args = node.argumentList.arguments;
      if (args.isNotEmpty) {
        final firstArg = args.first;
        if (firstArg is StringLiteral) {
          final value = firstArg.stringValue ?? '';
          if (RegExp(r'[\u4e00-\u9fa5]').hasMatch(value)) {
            _reportString(firstArg, 'DateFormat', 'date_format');
          }
        }
      }
    }

    // 检测额外的命名参数（如 name, description 等）
    if (!_isMethodExcludedForAll()) {
      for (final arg in node.argumentList.arguments) {
        if (arg is NamedExpression) {
          final paramName = arg.name.label.name;
          if (config.additionalNamedParams.contains(paramName)) {
            final value = arg.expression;
            if (value is StringLiteral) {
              final stringValue = value.stringValue ?? '';
              if (RegExp(r'[\u4e00-\u9fa5]').hasMatch(stringValue)) {
                _reportString(value, '$typeName.$paramName', 'additional_named');
              }
            }
          }
        }
      }
    }

    _checkWidgetArguments(typeName, node.argumentList.arguments);
    super.visitInstanceCreationExpression(node);
  }

  /// 检查方法调用（如 Text("硬编码") - 无 const/new 时被解析为方法调用）
  @override
  void visitMethodInvocation(MethodInvocation node) {
    final methodName = node.methodName.name;

    // 获取完整方法调用名（如 DottingUtil.onEvent）
    final fullMethodName = node.target != null
        ? '${node.target}.${node.methodName.name}'
        : node.methodName.name;

    // 检查是否是排除的方法调用
    if (_isExcludedMethodCall(fullMethodName)) {
      super.visitMethodInvocation(node);
      return;
    }

    // 检测配置的函数调用（如 showToast、showPermissionDialog）
    if (config.checkFunctionCalls.contains(methodName)) {
      _checkFunctionCallArguments(methodName, node.argumentList.arguments);
    }

    // 只检测大写开头的调用（Flutter 组件命名约定）
    if (methodName.isNotEmpty && methodName[0].toUpperCase() == methodName[0]) {
      _checkWidgetArguments(methodName, node.argumentList.arguments);
    }

    super.visitMethodInvocation(node);
  }

  /// 检查变量声明中的硬编码字符串
  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    if (config.checkVariableDeclaration && !_isMethodExcludedForAll()) {
      final initializer = node.initializer;
      if (initializer is StringLiteral) {
        final value = initializer.stringValue ?? '';
        // 只检测包含中文的字符串（避免误报）
        if (RegExp(r'[\u4e00-\u9fa5]').hasMatch(value)) {
          _reportString(
            initializer,
            'VariableDeclaration(${node.name.lexeme})',
            'variable',
          );
        }
      }
    }
    super.visitVariableDeclaration(node);
  }

  /// 检查函数调用参数（showToast、showPermissionDialog 等）
  void _checkFunctionCallArguments(
      String functionName, NodeList<Expression> arguments) {
    if (_isMethodExcludedForAll()) return;

    for (var arg in arguments) {
      // 检查位置参数中的字符串（如 showToast("网络异常")）
      if (arg is StringLiteral) {
        _reportString(arg, functionName, 'function_positional');
      }
      // 检查命名参数中的字符串（如 showPermissionDialog(title: "拍照翻译")）
      else if (arg is NamedExpression) {
        final paramName = arg.name.label.name;
        final value = arg.expression;
        if (value is StringLiteral) {
          _reportString(value, '$functionName.$paramName', 'function_named');
        }
      }
    }
  }

  /// 检查是否是排除的方法调用
  bool _isExcludedMethodCall(String fullMethodName) {
    // 提取方法名（去掉类名前缀）
    final methodNameOnly = fullMethodName.contains('.')
        ? fullMethodName.split('.').last
        : fullMethodName;

    for (final excluded in config.excludeMethodCalls) {
      // 如果排除规则包含 .（如 DottingUtil.onEvent），使用包含匹配
      if (excluded.contains('.')) {
        if (fullMethodName.contains(excluded)) {
          return true;
        }
      } else {
        // 否则使用精确匹配方法名（如 log、print）
        if (methodNameOnly == excluded) {
          return true;
        }
      }
    }
    return false;
  }

  /// 检查当前方法是否应该排除条件表达式检测
  bool _isMethodExcludedForConditional() {
    if (_currentMethod == null) return false;
    final methodLower = _currentMethod!.toLowerCase();
    for (final pattern in config.excludeConditionalInMethods) {
      if (methodLower.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// 检查当前方法是否应该完全跳过所有硬编码检测
  bool _isMethodExcludedForAll() {
    if (_currentMethod == null) return false;
    final methodLower = _currentMethod!.toLowerCase();
    for (final pattern in config.excludeAllInMethods) {
      if (methodLower.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// 检查条件表达式是否在排除的方法调用参数中
  bool _isInExcludedMethodCall(AstNode node) {
    AstNode? current = node.parent;
    while (current != null) {
      if (current is MethodInvocation) {
        final fullMethodName = current.target != null
            ? '${current.target}.${current.methodName.name}'
            : current.methodName.name;
        if (_isExcludedMethodCall(fullMethodName)) {
          return true;
        }
      }
      current = current.parent;
    }
    return false;
  }

  /// 检查条件表达式中的字符串
  @override
  void visitConditionalExpression(ConditionalExpression node) {
    if (config.checkConditionalExpression &&
        !_isMethodExcludedForAll() &&
        !_isMethodExcludedForConditional() &&
        !_isInExcludedMethodCall(node)) {
      // 检查 then 部分
      if (node.thenExpression is StringLiteral) {
        _reportString(
          node.thenExpression as StringLiteral,
          'ConditionalExpression.then',
          'conditional',
        );
      }

      // 检查 else 部分
      if (node.elseExpression is StringLiteral) {
        _reportString(
          node.elseExpression as StringLiteral,
          'ConditionalExpression.else',
          'conditional',
        );
      }
    }

    super.visitConditionalExpression(node);
  }

  /// 检查 Map/Set 字面量中的中文字符串
  @override
  void visitSetOrMapLiteral(SetOrMapLiteral node) {
    if (config.checkMapLiteral && !_isMethodExcludedForAll()) {
      for (final element in node.elements) {
        if (element is MapLiteralEntry) {
          // 检测 Map value 中的中文（key 通常是标识符，不需要国际化）
          if (element.value is StringLiteral) {
            final valueLiteral = element.value as StringLiteral;
            final value = valueLiteral.stringValue ?? '';
            if (RegExp(r'[\u4e00-\u9fa5]').hasMatch(value)) {
              _reportString(valueLiteral, 'MapLiteral.value', 'map_value');
            }
          }
        }
      }
    }
    super.visitSetOrMapLiteral(node);
  }

  /// 检查 return 语句中的中文字符串
  @override
  void visitReturnStatement(ReturnStatement node) {
    if (config.checkReturnStatement && !_isMethodExcludedForAll()) {
      final expression = node.expression;
      if (expression is StringLiteral) {
        final value = expression.stringValue ?? '';
        if (RegExp(r'[\u4e00-\u9fa5]').hasMatch(value)) {
          _reportString(expression, 'ReturnStatement', 'return');
        }
      }
    }
    super.visitReturnStatement(node);
  }

  /// 检查 throw 表达式中的中文字符串
  @override
  void visitThrowExpression(ThrowExpression node) {
    if (config.checkThrowExpression && !_isMethodExcludedForAll()) {
      final expression = node.expression;
      // throw Exception("中文消息") 或 throw FormatException("中文消息")
      if (expression is InstanceCreationExpression) {
        for (final arg in expression.argumentList.arguments) {
          if (arg is StringLiteral) {
            final value = arg.stringValue ?? '';
            if (RegExp(r'[\u4e00-\u9fa5]').hasMatch(value)) {
              _reportString(arg, 'ThrowExpression', 'throw');
            }
          }
        }
      }
      // throw "中文消息" (直接抛出字符串)
      else if (expression is StringLiteral) {
        final value = expression.stringValue ?? '';
        if (RegExp(r'[\u4e00-\u9fa5]').hasMatch(value)) {
          _reportString(expression, 'ThrowExpression', 'throw');
        }
      }
    }
    super.visitThrowExpression(node);
  }

  /// 调试日志前缀模式（用于过滤字符串插值中的调试信息）
  static final _debugPrefixPatterns = [
    RegExp(r'^aaaaaa'),           // 调试前缀
    RegExp(r'^v5x='),             // v5x调试日志
    RegExp(r'^Speech'),           // 语音识别调试
    RegExp(r'^camera_order'),     // 相机订单调试
    RegExp(r'^SimultaneousTransChannel'), // 同传channel调试
    RegExp(r'^==\w+=='),          // ==XXX==> 格式的调试前缀
    RegExp(r'失败[:：]?\s*$'),    // 以"失败:"结尾的错误日志
    RegExp(r'成功[:：]?\s*$'),    // 以"成功:"结尾的日志
    RegExp(r'^(添加|获取|删除|设置|推送|关闭|开启).*[:：]\s*$'), // 操作日志前缀
    RegExp(r'[:：]\s*$'),         // 以冒号结尾的日志前缀
  ];

  /// 检查是否是调试日志字符串
  bool _isDebugLogString(String value) {
    for (final pattern in _debugPrefixPatterns) {
      if (pattern.hasMatch(value)) {
        return true;
      }
    }
    return false;
  }

  /// 检查字符串插值中的中文部分
  @override
  void visitStringInterpolation(StringInterpolation node) {
    if (config.checkStringInterpolation && !_isMethodExcludedForAll()) {
      // 获取完整的字符串插值内容来判断是否是调试日志
      final fullString = node.elements.map((e) {
        if (e is InterpolationString) return e.value;
        return '\${}'; // 占位符
      }).join('');

      // 如果整个字符串看起来像调试日志，跳过
      if (_isDebugLogString(fullString)) {
        super.visitStringInterpolation(node);
        return;
      }

      for (final element in node.elements) {
        if (element is InterpolationString) {
          final value = element.value;
          if (RegExp(r'[\u4e00-\u9fa5]').hasMatch(value)) {
            // 跳过单独的调试日志片段
            if (_isDebugLogString(value)) continue;

            // 创建一个虚拟的位置信息
            final location = lineInfo.getLocation(element.offset);
            results.add(HardcodedString(
              filePath: filePath,
              line: location.lineNumber,
              column: location.columnNumber,
              source: 'StringInterpolation',
              value: value,
              method: _currentMethod,
              type: 'interpolation',
            ));
          }
        }
      }
    }
    super.visitStringInterpolation(node);
  }

  /// 检查组件参数
  void _checkWidgetArguments(
      String widgetName, NodeList<Expression> arguments) {
    if (!config.isWidgetEnabled(widgetName)) return;
    if (_isMethodExcludedForAll()) return;

    for (var arg in arguments) {
      // 检查位置参数（如 Text("硬编码")）
      if (arg is StringLiteral && config.shouldCheckPositional(widgetName)) {
        _reportString(arg, widgetName, 'positional');
      }
      // 检查命名参数
      else if (arg is NamedExpression) {
        final paramName = arg.name.label.name;
        final value = arg.expression;

        // 直接字符串参数（如 hintText: "提示"）
        if (value is StringLiteral &&
            config.shouldCheckNamed(widgetName) &&
            config.isNamedArgumentEnabled(paramName)) {
          _reportString(value, '$widgetName.$paramName', 'named');
        }

        // 深度检测嵌套组件
        if (config.deepCheckArguments.contains(paramName)) {
          _deepCheckExpression(value, '$widgetName.$paramName');
        }
      }
    }
  }

  /// 深度检测表达式中的字符串
  void _deepCheckExpression(Expression expr, String context) {
    if (expr is InstanceCreationExpression) {
      final typeName = expr.constructorName.type.name2.lexeme;
      if (typeName == 'Text') {
        for (var arg in expr.argumentList.arguments) {
          if (arg is StringLiteral) {
            _reportString(arg, '$context > Text', 'deep');
          }
        }
      }
    } else if (expr is MethodInvocation) {
      final methodName = expr.methodName.name;
      if (methodName == 'Text') {
        for (var arg in expr.argumentList.arguments) {
          if (arg is StringLiteral) {
            _reportString(arg, '$context > Text', 'deep');
          }
        }
      }
    }
  }

  /// 报告发现的字符串
  void _reportString(StringLiteral literal, String source, String type) {
    final value = literal.stringValue ?? '';

    // 应用过滤规则
    if (config.stringFilters.shouldFilter(value)) return;

    final location = lineInfo.getLocation(literal.offset);

    results.add(HardcodedString(
      filePath: filePath,
      line: location.lineNumber,
      column: location.columnNumber,
      source: source,
      value: value,
      method: _currentMethod,
      type: type,
    ));
  }
}
