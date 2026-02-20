#!/bin/bash
#==============================================================================
# 应用程序缓存清理模块
#==============================================================================

cleanup_package_cache() {
    print_header "应用程序缓存清理"
    
    local total_size=0
    local freed=0
    
    # 1. npm 缓存
    if command -v npm &> /dev/null; then
        local npm_size
        npm_size=$(get_dir_size "$HOME/.npm")
        print_info "npm 缓存: $(format_size $npm_size)"
        
        if [[ "$DRY_RUN" == "true" ]]; then
            total_size=$((total_size + npm_size))
        else
            if ask_confirm "清理 npm 缓存?"; then
                echo -n "清理 npm 缓存..."
                if npm cache clean --force &> /dev/null; then
                    freed=$npm_size
                    TOTAL_FREED=$((TOTAL_FREED + freed))
                    print_success "已清理 $(format_size $freed)"
                else
                    print_warning "跳过"
                fi
            fi
        fi
    fi
    
    # 2. yarn 缓存
    if command -v yarn &> /dev/null; then
        local yarn_size
        yarn_size=$(get_dir_size "$HOME/.yarn/cache")
        [[ -z "$yarn_size" ]] && yarn_size=0
        print_info "yarn 缓存: $(format_size $yarn_size)"
        
        if [[ "$DRY_RUN" == "true" ]]; then
            total_size=$((total_size + yarn_size))
        else
            if ask_confirm "清理 yarn 缓存?"; then
                echo -n "清理 yarn 缓存..."
                if yarn cache clean &> /dev/null; then
                    freed=$yarn_size
                    TOTAL_FREED=$((TOTAL_FREED + freed))
                    print_success "已清理 $(format_size $freed)"
                else
                    print_warning "跳过"
                fi
            fi
        fi
    fi
    
    # 3. pip 缓存
    if command -v pip3 &> /dev/null; then
        local pip_size
        pip_size=$(get_dir_size "$HOME/.cache/pip")
        [[ -z "$pip_size" ]] && pip_size=0
        print_info "pip 缓存: $(format_size $pip_size)"
        
        if [[ "$DRY_RUN" == "true" ]]; then
            total_size=$((total_size + pip_size))
        else
            if ask_confirm "清理 pip 缓存?"; then
                echo -n "清理 pip 缓存..."
                # pip 没有直接清理缓存的命令，删除目录即可
                rm -rf "$HOME/.cache/pip"/* 2>/dev/null
                freed=$pip_size
                TOTAL_FREED=$((TOTAL_FREED + freed))
                print_success "已清理 $(format_size $freed)"
            fi
        fi
    fi
    
    # 4. composer 缓存
    if command -v composer &> /dev/null; then
        local composer_size
        composer_size=$(get_dir_size "$HOME/.composer/cache")
        [[ -z "$composer_size" ]] && composer_size=0
        print_info "composer 缓存: $(format_size $composer_size)"
        
        if [[ "$DRY_RUN" == "true" ]]; then
            total_size=$((total_size + composer_size))
        else
            if ask_confirm "清理 composer 缓存?"; then
                echo -n "清理 composer 缓存..."
                if composer clear-cache &> /dev/null; then
                    freed=$composer_size
                    TOTAL_FREED=$((TOTAL_FREED + freed))
                    print_success "已清理 $(format_size $freed)"
                else
                    print_warning "跳过"
                fi
            fi
        fi
    fi
    
    # 5. go 模块缓存
    if command -v go &> /dev/null; then
        local go_size
        go_size=$(get_dir_size "$HOME/go/pkg/mod")
        [[ -z "$go_size" ]] && go_size=0
        print_info "Go 模块缓存: $(format_size $go_size)"
        
        if [[ "$DRY_RUN" == "true" ]]; then
            total_size=$((total_size + go_size))
        else
            if ask_confirm "清理 Go 模块缓存?"; then
                echo -n "清理 Go 模块缓存..."
                go clean -cache &> /dev/null
                freed=$go_size
                TOTAL_FREED=$((TOTAL_FREED + freed))
                print_success "已清理 $(format_size $freed)"
            fi
        fi
    fi
    
    # 6. Rust cargo 缓存
    if command -v cargo &> /dev/null; then
        local cargo_size
        cargo_size=$(get_dir_size "$HOME/.cargo/registry/cache")
        [[ -z "$cargo_size" ]] && cargo_size=0
        print_info "Cargo 缓存: $(format_size $cargo_size)"
        
        if [[ "$DRY_RUN" == "true" ]]; then
            total_size=$((total_size + cargo_size))
        else
            if ask_confirm "清理 Cargo 缓存?"; then
                echo -n "清理 Cargo 缓存..."
                rm -rf "$HOME/.cargo/registry/cache"/* 2>/dev/null
                freed=$cargo_size
                TOTAL_FREED=$((TOTAL_FREED + freed))
                print_success "已清理 $(format_size $freed)"
            fi
        fi
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "预览模式: 可释放总计 $(format_size $total_size)"
    fi
    
    echo ""
}
