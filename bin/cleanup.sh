#!/bin/bash
#==============================================================================
# Linux Cleanup Tool - 主入口
# 
# 功能：清理 Linux 系统垃圾，释放磁盘空间
# 
# 使用方法：
#   ./cleanup.sh                 # 交互模式
#   ./cleanup.sh --preview       # 预览模式（只显示不清理）
#   ./cleanup.sh --silent       # 静默模式（自动清理所有）
#   ./cleanup.sh --module snap   # 只清理指定模块
#==============================================================================

set -e

# 脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"
source "${SCRIPT_DIR}/config/config.sh"

# 默认配置
MODE="interactive"
MODULE=""
DRY_RUN=false
USER_ONLY=false

#------------------------------------------------------------------------------
# 解析参数
#------------------------------------------------------------------------------
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--preview)
                MODE="preview"
                DRY_RUN=true
                shift
                ;;
            -s|--silent)
                MODE="silent"
                shift
                ;;
            -i|--interactive)
                MODE="interactive"
                shift
                ;;
            -m|--module)
                MODULE="$2"
                shift 2
                ;;
            -u|--user-only)
                USER_ONLY=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                echo_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

show_help() {
    cat << EOF
Linux Cleanup Tool - Linux 系统清理工具

使用方法:
    $(basename $0) [选项]

选项:
    -p, --preview       预览模式 - 只显示占用，不清理
    -s, --silent        静默模式 - 自动清理所有
    -i, --interactive   交互模式 - 每个操作询问确认 (默认)
    -u, --user-only    用户模式 - 无需 sudo，只清理用户目录
    -m, --module <name> 只清理指定模块
    -h, --help          显示帮助

可用模块:
    snap       - Snap 清理 (需要 sudo)
    apt        - APT 清理 (需要 sudo)
    log        - 日志清理 (需要 sudo)
    temp       - 临时文件清理
    kernel     - 旧内核清理 (需要 sudo)
    cache      - 应用程序缓存
    all        - 清理所有模块

示例:
    $(basename $0)                  # 交互模式 (需要 sudo)
    $(basename $0) --user-only      # 用户模式 (无需 sudo)
    $(basename $0) --preview        # 预览占用
    $(basename $0) --silent         # 自动清理
    $(basename $0) -m snap          # 只清理 snap
EOF
}

#------------------------------------------------------------------------------
# 主函数
#------------------------------------------------------------------------------
main() {
    parse_args "$@"
    
    print_banner
    
    if [[ "$USER_ONLY" == "true" ]]; then
        echo -e "${YELLOW}用户模式 (无需 sudo)${NC}"
    else
        echo -e "${YELLOW}系统模式 (需要 sudo)${NC}"
    fi
    echo "模式: $MODE"
    echo ""
    
    # 要清理的模块
    local modules=()
    
    if [[ "$USER_ONLY" == "true" ]]; then
        # 用户模式 - 只清理用户目录
        modules=(temp cache)
    else
        if [[ -n "$MODULE" ]]; then
            if [[ "$MODULE" == "all" ]]; then
                modules=(snap apt log temp kernel cache)
            else
                modules=("$MODULE")
            fi
        else
            modules=(snap apt log temp kernel cache)
        fi
    fi
    
    # 执行清理
    for mod in "${modules[@]}"; do
        case $mod in
            snap)
                source "${SCRIPT_DIR}/lib/snap.sh"
                cleanup_snap
                ;;
            apt)
                source "${SCRIPT_DIR}/lib/apt.sh"
                cleanup_apt
                ;;
            log)
                source "${SCRIPT_DIR}/lib/log.sh"
                cleanup_log
                ;;
            temp)
                source "${SCRIPT_DIR}/lib/temp.sh"
                cleanup_temp
                ;;
            kernel)
                source "${SCRIPT_DIR}/lib/kernel.sh"
                cleanup_kernel
                ;;
            cache)
                source "${SCRIPT_DIR}/lib/package-cache.sh"
                cleanup_package_cache
                ;;
        esac
    done
    
    print_summary
}

main "$@"
