#!/bin/bash
#==============================================================================
# 配置文件
#==============================================================================

# 默认配置
export MODE="interactive"
export DRY_RUN=false

# 排除的 Snap 应用 (不会被删除)
export EXCLUDED_SNAPS=("core" "core18" "core20" "core22" "bare" "snapd" "snapd-desktop-integration")

# 排除的缓存目录 (清理时保留)
export EXCLUDED_CACHES=("npm" "yarn" "pip" "composer" "go" "cargo" "pnpm" "gradle" "m2")

# 临时文件保留天数
export TEMP_FILE_DAYS=7
export CACHE_FILE_DAYS=30

# 日志清理保留天数
export LOG_RETENTION_DAYS=7
