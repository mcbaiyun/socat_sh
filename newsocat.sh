#!/bin/bash

# 自用Socat启动脚本
# 亦可配合定时任务实现进程守护作用
# 默认绑定到本地ipv6的端口，目标地址可为ipv4或ipv6
# 本脚本只支持了TCP，有UDP需求的请自行修改！

# 检查参数数量
if [ "$#" -ne 4 ]; then
    echo "用法: $0 -l <本地端口> -r <远程地址>"
    exit 1
fi

# 解析参数
while getopts "l:r:" opt; do
    case ${opt} in
        l )
            local_port=$OPTARG
            # echo "本地端口设置为: $local_port"
            ;;
        r )
            remote_address=$OPTARG
            # echo "远程地址设置为: $remote_address"
            ;;
        \? )
            echo "输入有误，正确用法： $0 -l <本地端口> -r <远程地址>"
            exit 1
            ;;
    esac
done

# 根据不同的远程地址格式构建grep字符串
if [[ $remote_address =~ ^\[.*\]:.* ]]; then
    escaped_remote_address=$(echo "$remote_address" | sed 's/\[/\\[/g; s/\]/\\]/g')
    grep_string="TCP6-LISTEN:$local_port,reuseaddr,fork TCP6:$escaped_remote_address"
    socat_command="nohup socat TCP6-LISTEN:$local_port,reuseaddr,fork TCP6:$remote_address > /dev/null 2>&1 &"
    # echo "检测到IPv6地址。Grep字符串: $grep_string"
else
    grep_string="TCP6-LISTEN:$local_port,reuseaddr,fork TCP4:$remote_address"
    socat_command="nohup socat TCP6-LISTEN:$local_port,reuseaddr,fork TCP4:$remote_address > /dev/null 2>&1 &"
    # echo "检测到IPv4地址。Grep字符串: $grep_string"
fi

# 判断是否已经存在相应的socat进程
if ! pgrep socat -a | grep -iq "$grep_string"; then
    # echo "正在启动socat，命令为: $socat_command"
    eval $socat_command
    echo "【New】已启动socat程序：本地端口 $local_port -> 目标地址 $remote_address"
else
    echo "【Exist】已存在该socat程序：本地端口 $local_port -> 目标地址 $remote_address"
fi
