#! /bin/bash

useage(){
    echo "Usage: git subrepo <command> [options] <subrepo_name>"
    echo "command:  add,init,del,fetch,pull,checkout "
    echo "add:      git subrepo add https://github.com/MiV1N/subrepo.git my_subrepo"
    echo "init:     git subrepo init my_subrepo"
    echo "del:      git subrepo del my_subrepo"
    echo "fetch:    git subrepo fetch -p my_subrepo"
    echo "pull:     git subrepo pull -f my_subrepo"
    echo "checkout: git subrepo checkout -b test my_subrepo"
}

# 全局日志级别变量，用于控制日志输出
LOG_LEVEL="DEBUG" # 可以设置为 INFO, DEBUG, ERROR, NONE

# ANSI 颜色代码
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# 日志函数，用于调试
# 参数1: 日志级别（INFO, DEBUG, ERROR）
# 参数2: 日志消息
log() {
    local level=$1
    local message=$2
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S") # 获取当前时间戳

    # 定义一个数组，用于存储日志级别的顺序
    local levels=("NONE" "ERROR" "INFO" "DEBUG")

    # 找到全局日志级别在数组中的索引
    local global_index=-1
    for ((i=0; i<${#levels[@]}; i++)); do
        if [[ "${levels[$i]}" == "$LOG_LEVEL" ]]; then
            global_index=$i
            break
        fi
    done

    # 如果全局日志级别未定义，或者不在数组中，则不打印日志
    if [[ $global_index -eq -1 ]]; then
        return
    fi

    # 找到要打印的日志级别在数组中的索引
    local log_index=-1
    for ((i=0; i<${#levels[@]}; i++)); do
        if [[ "${levels[$i]}" == "$level" ]]; then
            log_index=$i
            break
        fi
    done

    # 如果要打印的日志级别未定义，或者不在数组中，则不打印日志
    if [[ $log_index -eq -1 ]]; then
        return
    fi

    # 如果要打印的日志级别大于全局日志级别，则不打印日志
    if [[ $log_index -gt $global_index ]]; then
        return
    fi

    # 根据日志级别选择颜色
    local color=""
    if [[ "$level" == "ERROR" ]]; then
        color=$RED
    elif [[ "$level" == "INFO" ]]; then
        color=$GREEN
    elif [[ "$level" == "DEBUG" ]]; then
        color=$YELLOW
    else
        color=$NC
    fi

    # 打印日志
    echo -e "[${color}${level}${NC}] $message"
    # echo -e "${timestamp} [${color}${level}${NC}] $message"
}

# 调试代码
# log "INFO" "This is an informational message."
# log "DEBUG" "This is a debug message."
# log "ERROR" "This is an error message."
# exit 0


# 操作 .gitsubrepo 格式的文件的函数
# 参数1: 操作类型（add, delete, get）
# 参数2: 文件路径
# 参数3: （可选）条目名称，仅在操作类型为 get 且需要获取特定条目的 path 时使用
config() {
    local confPath=$1
    local action=$2
    local entry=$3
    local url=$4
    local temp_file=".tmp"

    if [[ ! -f "$confPath" ]]; then
        log "ERROR"  "File does not exist. create it"
        touch $confPath
    fi

    case "$action" in
        add)
            # 添加条目到文件
            if grep -qP "^\[subrepo\s+\"${entry}\"\]" "$confPath"; then
                log "ERROR"  "Entry '$entry' already exists."
                return 1
            else
                cat "$confPath" > "$temp_file"
                echo "" >> "$temp_file"
                echo "[subrepo \"$entry\"]" >> "$temp_file"
                echo "    path = $url" >> "$temp_file"
                mv "$temp_file" "$confPath"
            fi
            ;;
        delete)
            # 删除条目
            perl -0777 -pe "s#\[subrepo\s+\"$entry\"\]\s*\r?\n\s*path\s*=\s*(.*)\r?\n(\s*\r?\n)##"  "$confPath" > "$temp_file"
            mv "$temp_file" "$confPath"
            ;;
        get)
            if [[ -n "$entry" ]]; then
                # 获取指定条目的 path
                local path=$(awk "/$entry\"\]/{getline nextline;print nextline}" "$confPath" | awk -F= '{print $2}')
                # local path=$(grep "^\[subrepo\s+\"$entry\"\]\s*\r*\n\s*path\s*=\s*(.*)$" "$confPath" | grep "path" | cut -d ' ' -f 3)
                if [[ -z "$path" ]]; then
                    log "ERROR"  "Entry '$entry' not found."
                    return 1
                else
                    # log "DEBUG"  "Path for '$entry': $path"
                    echo $path
                fi
            else
                log "ERROR"  "need param entry!"
            fi
            ;;
        *)
            log "ERROR"  "Invalid action. Use 'add', 'delete', or 'get'."
            return 1
            ;;
    esac

    # 清理临时文件
    # rm "$temp_file"
}

# 调试代码

# # 清除数据
# rm  .gitsubrepo  

# # 调用函数添加条目
# config ".gitsubrepo" "add"  "subrepo_test" "https://github.com/MiV1N/subrepo.git"
# config ".gitsubrepo" "add"  "subrepo_test2" "https://github.com/MiV1N/subrepo.git"

# # 调用函数获取指定条目的路径
# output=$(config ".gitsubrepo" "get" "subrepo_test")
# log "DEBUG" "获取指定路径的条目信息：$output"

# #判定entry是否存在
# output=$(config ".gitsubrepo" "get" "subrepo_test3")
# echo $output | grep ERROR
# if [ $? -eq 0 ]; then
#     log "DEBUG"  "子仓库：subrepo_test3 未配置"
# fi


# # 调用函数删除条目
# config ".gitsubrepo" "delete" "subrepo_test"

# exit 0


# 初始化函数
init() {
    log "DEBUG"  "Executing init with params: $*"
    subrepo_name=$1

    # 检查参数
    if [ -z "$subrepo_name" ]; then
        log "DEBUG" "init 传入的subrepo_name参数为空"
        useage
        return 1
    fi

    # 检查项目是否存在
    subrepo_url=$(config ".gitsubrepo" "get" "$subrepo_name")
    echo $subrepo_url | grep ERROR
    if [ $? -eq 0 ]; then
        log "ERROR"  "子仓库：${subrepo_name} 未配置"
        return 1
    fi

    # 检查目录是否为空
    if [ -d "$subrepo_name" ]; then
        if [ "$(ls -A "$subrepo_name")" ]; then
            log "ERROR"  "目录：${subrepo_name} 不为空"
            return 1
        fi
    fi

    # clone 项目
    git clone $subrepo_url  $subrepo_name

}

fetch() {
    log "DEBUG"  "Executing fetch with params: $*"
    git fetch "$*"
}

del() {
    log "DEBUG"  "Executing del with params: $*"
    subrepo_name=$1

    # 检查参数
    if [ -z "$subrepo_name" ]; then
        log "DEBUG" "del 传入的subrepo_name参数为空"
        useage
        return 1
    fi

    
    # 删除配置
    config ".gitsubrepo" "delete" "$subrepo_name"

    # 删除目录
    if [ -d "$subrepo_name" ]; then
        rm -r $subrepo_name
    fi
}

pull() {
    log "DEBUG" "Executing pull with params: $*"
    git pull "$*"
}

add() {
    log "DEBUG"  "Executing add with params: $*"

    repository_url=$1 
    path=$2

    # 检查参数
    if [ -z "$repository_url" ]; then
        log "DEBUG" "add 传入的repository_url参数为空"
        useage
        return 1
    fi
    if [ -z "$path" ]; then
        log "DEBUG" "add 传入的path参数为空"
        useage
        return 1
    fi

    

    # 添加配置文件
    config ".gitsubrepo" "add"  "$path" "$repository_url"

}

checkout() {
    echo "Executing checkout with params: $*"
    # 在这里添加 add 操作的代码
    git checkout "$*"
}





# 检查是否至少有一个参数
if [ $# -lt 1 ]; then
    useage
    exit 1
fi

# 初始化一个空的数组来存储所有的 -p 参数值
params=()

# 循环遍历所有参数
while [[ "$1" != "" ]]; do
    # 将每个参数加入到数组中
    params+=("$1")
    # 移动到下一个参数
    shift
done

# 检查是否至少有两个参数
if [ ${#params[@]} -lt 2 ]; then
    useage
    exit 1
fi


# 输出获取的参数
for param in "${params[@]}"; do
    log "DEBUG" "With parameter: $param"
done


# 获取第一个参数作为命令
command=${params[0]}

# 获取最后一个参数作为 subrepo_name
subrepo_name=${params[${#params[@]} - 1]}

# 检查 subrepo_name 是不是在配置文件中的


# 移除数组中的第一个和最后一个元素
params_pass=("${params[@]:1:(${#params[@]} - 2)}")


# 输出获取的参数
log "DEBUG" "后数组: 命令:$command 子仓库:$subrepo_name"
for param in "${params_pass[@]}"; do
    log "DEBUG"  "With parameter: $param"
done


# 根据命令调用对应的函数
case $command in
    init)
        init "${params_pass[@]} $subrepo_name"
        ;;
    del)
        del "${params_pass[@]} $subrepo_name"
        ;;
    add)
        add "${params_pass[@]} $subrepo_name"
        ;;
    fetch)
        SAVED_PATH=$(pwd)
        cd $subrepo_name
        fetch "${params_pass[@]}"
        cd "$SAVED_PATH" 
        ;;
    checkout)
        SAVED_PATH=$(pwd)
        cd $subrepo_name
        checkout "${params_pass[@]}"
        cd "$SAVED_PATH" 
        ;;
    pull)
        SAVED_PATH=$(pwd)
        cd $subrepo_name
        pull "${params_pass[@]}"
        cd "$SAVED_PATH" 
        ;;
    *)
        echo "Unknown command: $command"
        exit 1
        ;;
esac
