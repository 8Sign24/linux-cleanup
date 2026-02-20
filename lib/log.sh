#!/bin/bash
#==============================================================================
# 日志清理模块
#==============================================================================

cleanup_log() {
    print_header "日志清理"
    
    local log_size
    log_size=$(get_dir_size "/var/log")
    
    if [[ $log_size -lt 1048576 ]]; then
        print_info "日志占用较小 ($((log_size/1024))KB)，跳过"
        return
    fi
    
    print_info "当前日志占用: $(format_size $log_size)"
    
    # 显示大日志文件
    echo -e "\n${YELLOW}大日志文件:${NC}"
    find /var/log -type f -size +10M -exec ls -lh {} \; 2>/dev/null | head -10
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "预览模式: 将释放约 $(format_size $log_size)"
        TOTAL_FREED=$((TOTAL_FREED + log_size))
        return
    fi
    
    if ask_confirm "清理系统日志?"; then
        # 清理 journal 日志
        if command -v journalctl &> /dev/null; then
            local journal_size
            journal_size=$(get_dir_size "/var/log/journal")
            if [[ $journal_size -gt 0 ]]; then
                echo -n "清理 journal 日志..."
                journalctl --vacuum-time=7d &> /dev/null
                local new_journal_size
                new_journal_size=$(get_dir_size "/var/log/journal")
                local freed=$((journal_size - new_journal_size))
                TOTAL_FREED=$((TOTAL_FREED + freed))
                print_success "已清理 $(format_size $freed)"
            fi
        fi
        
        # 清理旧日志
        echo -n "清理旧日志文件..."
        find /var/log -type f -name "*.gz" -mtime +30 -delete 2>/dev/null
        find /var/log -type f -name "*.1" -mtime +7 -delete 2>/dev/null
        find /var/log -type f -name "*.log" -mtime +7 -size +10M -truncate 2>/dev/null
        print_success "已清理"
        
        # 重新计算
        local new_size
        new_size=$(get_dir_size "/var/log")
        local freed=$((log_size - new_size))
        TOTAL_FREED=$((TOTAL_FREED + freed))
        
        print_success "日志清理完成，释放空间: $(format_size $freed)"
    fi
    
    echo ""
}
