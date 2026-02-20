#!/bin/bash
#==============================================================================
# Snap 清理模块
#==============================================================================

cleanup_snap() {
    print_header "Snap 清理"
    
    # 检查 snap 是否安装
    if ! command -v snap &> /dev/null; then
        print_info "Snap 未安装，跳过"
        return
    fi
    
    local snap_size
    snap_size=$(get_dir_size "/snap")
    
    if [[ $snap_size -eq 0 ]]; then
        print_info "Snap 占用为 0，无需清理"
        return
    fi
    
    print_info "当前 Snap 占用: $(format_size $snap_size)"
    
    # 显示当前 snap 列表
    echo -e "\n${YELLOW}已安装的 Snap:${NC}"
    snap list 2>/dev/null || print_warning "无法获取 snap 列表"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "预览模式: 将释放约 $(format_size $snap_size)"
        TOTAL_FREED=$((TOTAL_FREED + snap_size))
        return
    fi
    
    if ask_confirm "清理 Snap 旧版本和不需要的应用?"; then
        # 删除不需要的 Snap
        local unneeded_snaps=("firefox" "thunderbird" "wine-platform-9-devel-core22" "wine-platform-runtime-core22")
        
        for snap_name in "${unneeded_snaps[@]}"; do
            if snap list 2>/dev/null | grep -q "^${snap_name} "; then
                echo -n "删除 $snap_name..."
                if snap remove --purge "$snap_name" &> /dev/null; then
                    print_success "已删除"
                else
                    print_warning "跳过"
                fi
            fi
        done
        
        # 清理其他 snap 的旧版本
        echo -e "\n${YELLOW}清理其他应用的旧版本...${NC}"
        for snap_name in $(snap list 2>/dev/null | awk 'NR>1 {print $1}' | grep -v "^core" | grep -v "^bare"); do
            local revisions
            revisions=$(snap revisions "$snap_name" 2>/dev/null | wc -l)
            if [[ $revisions -gt 2 ]]; then
                echo -n "刷新 $snap_name..."
                if snap refresh "$snap_name" &> /dev/null; then
                    print_success "已更新到最新版本"
                else
                    print_warning "跳过"
                fi
            fi
        done
        
        # 清理缓存
        if [[ -d /var/lib/snapd/cache ]]; then
            local cache_size
            cache_size=$(get_dir_size "/var/lib/snapd/cache")
            if [[ $cache_size -gt 0 ]]; then
                echo -n "清理缓存..."
                rm -rf /var/lib/snapd/cache/* 2>/dev/null
                print_success "已清理 $(format_size $cache_size)"
            fi
        fi
        
        # 重新计算释放空间
        local new_size
        new_size=$(get_dir_size "/snap")
        local freed=$((snap_size - new_size))
        TOTAL_FREED=$((TOTAL_FREED + freed))
        
        print_success "Snap 清理完成，释放空间: $(format_size $freed)"
    fi
    
    echo ""
}
