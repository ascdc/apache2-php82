#!/bin/bash

# 檢查 /script/run.sh 是否存在並且可執行
if [ -x "/script/run.sh" ]; then
    # 如果存在則執行 /script/run.sh
    exec "/script/run.sh" "$@"
else
    # 若無，複製備用腳本 /backup/run.sh 到 /script/run.sh
    cp "/backup/run.sh" "/script/run.sh"
    
    # 確保腳本具有可執行的權限
    chmod +x "/script/run.sh"
    
    # 然後執行腳本 /script/run.sh
    exec "/script/run.sh" "$@"
fi
