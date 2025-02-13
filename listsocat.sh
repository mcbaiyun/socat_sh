#!/bin/bash

# 自用Socat列表脚本
# 可以按序号列出当前存在的socat进程列表，并快捷关闭对应序号的Socat程序
# 本脚本用于与我自己的newsocat.sh搭配使用
# 如你已修改newsocat.sh的内容，则你可能也需要对应修改本脚本才能搭配使用

# 获取socat进程信息
processes=$(pgrep socat -a)

# 检查是否有socat进程在运行
if [ -z "$processes" ]; then
    echo "没有找到socat进程"
    exit 1
fi

# 将进程信息转换为数组
IFS=$'\n' read -r -d '' -a process_array <<< "$processes"

# 显示进程信息
echo "找到以下socat进程："
for i in "${!process_array[@]}"; do
    line="${process_array[i]}"
    pid=$(echo "$line" | awk '{print $1}')
    local_port=$(echo "$line" | grep -oP '(?<=TCP6-LISTEN:|TCP4-LISTEN:)\d+')
    remote_address=$(echo "$line" | grep -oP '(?<=TCP6:|TCP4:)[^ ]+')
    echo "【$((i+1))】[SocatPID:$pid] 本地端口 $local_port -> 远程地址 $remote_address"
done

# 提示用户输入
read -p "请输入要结束的进程编号（1-${#process_array[@]}），或输入0退出: " choice

# 处理用户输入
if [ "$choice" -eq 0 ]; then
    exit 0
elif [ "$choice" -ge 1 ] && [ "$choice" -le "${#process_array[@]}" ]; then
    # 获取选中的进程ID
    selected_process=$(echo "${process_array[$((choice-1))]}" | awk '{print $1}')
    # 结束进程
    kill "$selected_process"
    echo "已结束进程ID: $selected_process"
else
    echo "无效的选择，请输入正确的编号或0退出"
fi
