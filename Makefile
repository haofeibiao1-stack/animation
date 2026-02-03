# Flutter 项目 Makefile
# 提供常用的开发命令快捷方式

.PHONY: gen watch clean get analyze test run build help

# 默认目标：显示帮助信息
help:
	@echo "Flutter 项目常用命令:"
	@echo ""
	@echo "  make gen       - 运行代码生成器 (build_runner)"
	@echo "  make watch     - 监听文件变化并自动生成代码"
	@echo "  make get       - 获取项目依赖 (flutter pub get)"
	@echo "  make clean     - 清理项目 (flutter clean)"
	@echo "  make analyze   - 运行代码分析 (flutter analyze)"
	@echo "  make test      - 运行测试 (flutter test)"
	@echo "  make run       - 运行应用 (flutter run)"
	@echo "  make build-apk - 构建 Android APK"
	@echo "  make build-ios - 构建 iOS 应用"
	@echo ""

# 代码生成
gen:
	@echo "🔄 正在生成代码..."
	@dart run build_runner build --delete-conflicting-outputs
	@echo "✅ 代码生成完成"

# 监听文件变化并自动生成代码
watch:
	@echo "👀 开始监听文件变化..."
	dart run build_runner watch

# 获取依赖
get:
	@echo "📦 正在获取依赖..."
	flutter pub get
	@echo "✅ 依赖获取完成"

# 清理项目
clean:
	@echo "🧹 正在清理项目..."
	flutter clean
	rm -rf .dart_tool
	rm -rf build
	@echo "✅ 清理完成"

# 代码分析
analyze:
	@echo "🔍 正在分析代码..."
	flutter analyze
	@echo "✅ 分析完成"

# 运行测试
test:
	@echo "🧪 正在运行测试..."
	flutter test
	@echo "✅ 测试完成"

# 运行应用
run:
	flutter run

# 构建 Android APK
build-apk:
	@echo "🔨 正在构建 Android APK..."
	flutter build apk --release
	@echo "✅ APK 构建完成"

# 构建 iOS 应用
build-ios:
	@echo "🔨 正在构建 iOS 应用..."
	flutter build ios --release
	@echo "✅ iOS 构建完成"

# 完全重置项目（清理 + 获取依赖 + 代码生成）
reset: clean get gen
	@echo "✅ 项目重置完成"