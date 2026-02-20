#!/bin/bash
#==============================================================================
# 临时文件清理模块
#==============================================================================

cleanup_temp() {
    print_header "临时文件清理"
    
    local temp_size=0
    local freed=0
    
    # 1. /tmp 目录
    local tmp_size
    tmp_size=$(get_dir_size "/tmp")
    print_info "/tmp 占用: $(format_size $tmp_size)"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        temp_size=$((temp_size + tmp_size))
    else
        if ask_confirm "清理 /tmp 目录?"; then
            echo -n "清理 /tmp..."
            # 只清理超过 7 天的文件
            find /tmp -type f -atime +7 -delete 2>/dev/null
            find /tmp -type d -atime +7 -empty -delete 2>/dev/null
            local new_tmp_size
            new_tmp_size=$(get_dir_size "/tmp")
            freed=$((freed + tmp_size - new_tmp_size))
            TOTAL_FREED=$((TOTAL_FREED + freed))
            print_success "已清理 $(format_size $freed)"
        fi
    fi
    
    # 2. 用户缓存 ~/.cache
    local cache_size
    cache_size=$(get_dir_size "$HOME/.cache")
    print_info "用户缓存占用: $(format_size $cache_size)"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        temp_size=$((temp_size + cache_size))
    else
        if ask_confirm "清理用户缓存 ~/.cache?"; then
            # 排除重要缓存
            local important_cache=("npm" "yarn" "pip" "composer" "go" "cargo")
            local cleaned=0
            
            for cache_dir in "${important_cache[@]}"; do
                if [[ -d "$HOME/.cache/$cache_dir" ]]; then
                    mv "$HOME/.cache/$cache_dir" "$HOME/.cache/${cache_dir}.bak" 2>/dev/null
                fi
            done
            
            echo -n "清理缓存..."
            # 只清理超过 30 天的缓存
            find "$HOME/.cache" -type f -atime +30 -delete 2>/dev/null
            find "$HOME/.cache" -type d -atime +30 -empty -delete 2>/dev/null
            
            # 恢复重要缓存
            for cache_dir in "${important_cache[@]}"; do
                if [[ -d "$HOME/.cache/${cache_dir}.bak" ]]; then
                    mv "$HOME/.cache/${cache_dir}.bak" "$HOME/.cache/$cache_dir" 2>/dev/null
                fi
            done
            
            local new_cache_size
            new_cache_size=$(get_dir_size "$HOME/.cache")
            freed=$((cache_size - new_cache_size))
            TOTAL_FREED=$((TOTAL_FREED + freed))
            print_success "已清理 $(format_size $freed)"
        fi
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        TOTAL_FREED=$((TOTAL_FREED + temp_size))
    fi
    
    echo ""
}
