# Linux Cleanup Tool - 功能规划

## 项目名称
`linux-cleanup` - Linux 系统清理工具

## 核心功能模块

### 1. Snap 清理
- 清理所有 Snap 旧版本
- 删除不需要的 Snap 应用 (Firefox, Thunderbird, Wine 等)
- 清理 Snap 缓存

### 2. APT 清理
- 清理 apt 缓存 (/var/cache/apt/archives)
- 清理 apt 列表缓存
- 清理不再需要的依赖包

### 3. 日志清理
- 清理系统日志 (/var/log)
- 清理旧日志轮转文件
- 清理 journal 日志

### 4. 临时文件清理
- 清理 /tmp 目录
- 清理用户缓存 (~/.cache)
- 清理缩略图缓存

### 5. 旧内核清理
- 列出并清理旧内核
- 清理相关模块

### 6. 包管理器缓存 (可选)
- npm 缓存清理
- yarn 缓存清理
- pip 缓存清理

### 7. 大文件查找 (可选)
- 查找占用空间大的文件
- 查找重复文件

## 架构设计

```
linux-cleanup/
├── bin/
│   └── cleanup.sh          # 主入口
├── lib/
│   ├── snap.sh             # Snap 清理模块
│   ├── apt.sh              # APT 清理模块
│   ├── log.sh              # 日志清理模块
│   ├── temp.sh             # 临时文件模块
│   ├── kernel.sh           # 旧内核模块
│   ├── package-cache.sh    # 包管理器缓存模块
│   └── utils.sh            # 公共函数
├── config/
│   └── config.sh           # 配置文件
├── README.md
└── LICENSE
```

## 交互模式

- 支持交互模式：每个清理操作前询问用户
- 支持静默模式：自动清理所有
- 支持预览模式：只显示占用，不清理
- 支持指定模块：只清理特定模块

## 输出

- 清理前显示预计释放空间
- 清理后显示实际释放空间
- 详细日志记录清理了哪些文件
