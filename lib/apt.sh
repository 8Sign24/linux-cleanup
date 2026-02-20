#!/bin/bash
#==============================================================================
# APT 清理模块
#==============================================================================

cleanup_apt() {
    print_header "APT 清理"
    
    # 检查 apt 是否可用
    if ! command -v apt-get &> /dev/null; then
        print_info "APT 未安装，跳过"
        return
    fi
    
    local apt_size
    apt_size=$(get_dir_size "/var/cache/apt/archives")
    
    if [[ $apt_size -lt 1048576 ]]; then
        print_info "APT 缓存较小 ($((apt_size/1024))KB)，跳过"
        return
    fi
    
    print_info "当前 APT 缓存: $(format_size $apt_size)"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "预览模式: 将释放约 $(format_size $apt_size)"
        TOTAL_FREED=$((TOTAL_FREED + apt_size))
        return
    fi
    
    if ask_confirm "清理 APT 缓存?"; then
        echo -n "清理 apt 缓存..."
        if apt-get clean &> /dev/null; then
            local freed=$apt_size
            TOTAL_FREED=$((TOTAL_FREED + freed))
            print_success "已清理 $(format_size $freed)"
        else
            print_error "清理失败"
        fi
    fi
    
    # 清理 apt 列表（可选）
    local list_size
    list_size=$(get_dir_size "/var/lib/apt/lists")
    if [[ $list_size -gt 104857600 ]]; then # > 100MB
        print_warning "APT 列表较大: $(format_size $list_size)"
        if ask_confirm "清理 APT 列表缓存?"; then
            echo -n "清理 apt 列表..."
            if apt-get clean -y &> /dev/null && rm -rf /var/lib/apt/lists/* &> /dev/null; then
                TOTAL_FREED=$((TOTAL_FREED + list_size))
                print_success "已清理 $(format_size $list_size)"
            else
                print_error "清理失败"
            fi
        fi
    fi
    
    echo ""
}
