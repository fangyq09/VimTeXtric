#!/usr/bin/env bash

SOURCE_FILE="$1"
LINE="$2"

# 1. 生成 socket 名称
SANITIZED_NAME=$(echo "$SOURCE_FILE" | sed 's/[^a-zA-Z0-9]/_/g')

SOCKET="/tmp/nvim-pdf-${SANITIZED_NAME}.socket"

# 2. 判断 Neovim 实例是否存在
if [[ -S "$SOCKET" ]]; then

    # 已存在：调用当前 Neovide 实例
    nvim --server "$SOCKET" \
        --remote-expr \
        "v:lua.jump_to_line(vim.fn.fnameescape('$SOURCE_FILE'), $LINE)"

else

    # 不存在：启动新的 Neovide
    setsid neovide "$SOURCE_FILE" -- \
        --listen "$SOCKET" \
        +"lua open_tex_and_jump(vim.fn.fnameescape('$SOURCE_FILE'), $LINE)" \
        >/dev/null 2>&1 </dev/null &

fi
