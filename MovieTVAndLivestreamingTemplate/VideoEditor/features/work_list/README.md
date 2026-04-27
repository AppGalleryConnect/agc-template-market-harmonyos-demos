# 工作列表页面 (WorkListPage)

## 功能概述

这是一个视频作品管理页面，支持展示已发布的视频作品和草稿，具有以下特性：

- 📱 折叠屏设备适配
- 🎬 视频缩略图网格展示
- 📝 标签页切换（视频作品/草稿）
- 🎯 底部导航栏
- ⏱️ 视频时长显示
- 📋 菜单操作

## 文件结构

```
src/main/ets/
├── views/
│   └── WorkListPage.ets          # 主页面组件
├── models/
│   └── VideoWork.ets             # 视频作品数据模型
├── components/
│   ├── VideoThumbnail.ets        # 视频缩略图组件
│   ├── VideoGrid.ets             # 视频网格布局组件
│   ├── SubTabBarStyle.ets        # 自定义标签栏样式
│   └── BottomNavigation.ets      # 底部导航栏组件
└── resources/
    └── ResourceTable.ets         # 资源定义
```

## 主要组件

### WorkListPage
主页面组件，负责：
- 折叠屏状态监听
- 数据加载和管理
- 页面布局和导航

### VideoThumbnail
视频缩略图组件，包含：
- 视频预览图
- 时长标签
- 菜单按钮
- 点击交互效果

### VideoGrid
网格布局组件，支持：
- 2列网格布局
- 响应式设计
- 滚动展示

## 使用方法

1. 在页面中导入 `WorkListPage` 组件
2. 确保添加必要的资源文件（图片、图标）
3. 根据需要修改 `VideoWorkData` 中的数据

## 资源要求

需要在 `src/main/resources/base/media/` 目录下添加以下资源文件：

- `video_thumbnail_*.png` - 视频缩略图
- `ic_more.png` - 更多菜单图标
- `ic_camera.png` - 相机图标
- `ic_gallery.png` - 相册图标
- `ic_profile.png` - 个人资料图标

## 自定义配置

### 修改网格列数
在 `VideoGrid.ets` 中修改 `columnsTemplate` 属性：
```typescript
.columnsTemplate('1fr 1fr 1fr') // 3列布局
```

### 添加新的视频数据
在 `VideoWorkData.ets` 中添加新的视频作品数据。

### 自定义标签页
在 `SubTabBarStyle.ets` 中修改样式和颜色。
