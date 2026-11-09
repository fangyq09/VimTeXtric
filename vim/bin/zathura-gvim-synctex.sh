#!/usr/bin/env bash

SOURCE_FILE="$1"
LINE="$2"

# 1. 生成 server name
SERVER_NAME=$(echo "$SOURCE_FILE" | sed 's/[^a-zA-Z0-9]/_/g')

# 2. 启动 GVim 实例
gvim --servername "$SERVER_NAME" \
	"$SOURCE_FILE" \
	"+call cursor($LINE, 1)" \
	>/dev/null 2>&1 &

