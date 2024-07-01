#!/bin/zsh
###
# 重建flutter项目,如果遇到无法运行编译可以尝试执行此脚本
###
SCRIPT="$(realpath "$0")"
# 获取脚本所在的目录
SCRIPT_DIR=$(dirname "$SCRIPT")
# 假设项目根目录是脚本所在目录的上一级
PROJECT_ROOT="$SCRIPT_DIR/."
# 移动到项目根目录
cd "$PROJECT_ROOT"
echo "[common_function]The workspace has been changed to [file://$(pwd)]"
# 要删除的文件夹
dirs=("macos" "linux" "windows" "android" "web" "ios" "pubspec.lock" "schedule.iml" ".idea")
for item in "${dirs[@]}"; do
    # 检查文件或文件夹是否存在
    if [ -e "$item" ]; then
        # 删除文件或文件夹
        rm -rf "$item"
        echo "Deleted file or directory [$item]"
    else
        echo "[$item] does not exist, skipping."
    fi
done

# 检查flutter命令是否存在
if command -v flutter &> /dev/null
then
    # 执行flutter clean
    flutter clean
    flutter pub get
    flutter create .
    echo "The environment has been rebuilt."
else
    echo "Flutter command not found. Please ensure Flutter is installed and added to PATH."
fi