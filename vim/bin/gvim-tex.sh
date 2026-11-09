#!/bin/bash
FILE="$1"
if [ -z "$FILE" ]; then
    gvim
    exit 0
fi

# 1. 获取绝对路径
ABS_PATH=$(realpath "$FILE")

# 2. 将绝对路径中的非字母数字字符替换为下划线，并转为大写
#SAFE_NAME=$(echo "$ABS_PATH" | tr '[:lower:]' '[:upper:]' | tr '/\\:.-' '_____')
SAFE_NAME=$(printf '%s' "$ABS_PATH" | tr '[:lower:]' '[:upper:]' | sed 's/[^A-Z0-9_]/_/g')

# 3. 启动或远程复用 gvim
gvim --servername "$SAFE_NAME" --remote-silent "$ABS_PATH" 2>/dev/null || gvim --servername "$SAFE_NAME" "$ABS_PATH"
&
