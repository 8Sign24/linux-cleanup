#!/bin/bash
#==============================================================================
# 旧内核清理模块
#==============================================================================

cleanup_kernel() {
    print_header "旧内核清理"
    
    # 获取当前内核版本
    local current_kernel
    current_kernel=$(uname -r)
    print_info "当前内核: $current_kernel"
    
    # 列出已安装的内核
    echo -e "\n${YELLOW}已安装的内核:${NC}"
    dpkg -l 'linux-*' 2>/dev/null | grep '^ii' | awk '{print $2, $3}' | head -10
    
    # 计算旧内核占用
    local kernel_size
    kernel_size=$(get_dir_size "/boot")
    
    if [[ $kernel_size -lt 1048576 ]]; then
        print_info "/boot 占用较小，跳过"
        return
    fi
    
    print_info "/boot 占用: $(format_size $kernel_size)"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        # 估算可释放空间
        local old_kernel_size
        old_kernel_size=$(du -sb /boot 2>/dev/null | cut -f1)
        # 假设可以释放一半
        local estimated_freed=$((old_kernel_size / 2))
        print_info "预览模式: 可释放约 $(format_size $estimated_freed)"
        TOTAL_FREED=$((TOTAL_FREED + estimated_freed))
        return
    fi
    
    if ask_confirm "清理旧内核?"; then
        # 使用 apt 清理旧内核
        echo -n "清理旧内核..."
        if command -v apt-get &> /dev/null; then
            # 保留当前内核，清理其他
            apt-get autoremove -y &> /dev/null
            local freed
            freed=$((kernel_size - $(get_dir_size "/boot")))
            TOTAL_FREED=$((TOTAL_FREED + freed))
            print_success "已清理 $(format_size $freed)"
        else
            print_warning "无法使用 apt-get"
        fi
    fi
    
    echo ""
}
