#!/usr/bin/env bash
SOURCE_FILE="$1"
LINE="$2"


# 1. 将所有非字母数字字符（空格、减号、括号等）转换为下划线
SANITIZED_NAME=$(echo "$SOURCE_FILE" | sed 's/[^a-zA-Z0-9]/_/g')

# 2. 生成规范化的 Socket 路径
SOCKET="/tmp/nvim-pdf-${SANITIZED_NAME}.socket"

# 3. 精准投递
if [ -S "$SOCKET" ]; then
    nvim --servername "$SOCKET" --remote +"$LINE" "$SOURCE_FILE"
else
    # 降级兜底
    nvim --remote +"$LINE" "$SOURCE_FILE"
fi
