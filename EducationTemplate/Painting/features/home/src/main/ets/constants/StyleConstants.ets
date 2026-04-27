import { TopToolItem, MenuItem, BrushItem, GroupItem } from '../types/StyleType'

//颜色分组类型
export const colorGroupList: GroupItem[] = [
  {
    type: 'Recent',
    name: $r('app.string.recent_colors')
  },
  {
    type: 'Regular',
    name: $r('app.string.regular_colors')
  },
  {
    type: 'Custom',
    name: $r('app.string.custom_colors')
  }
]

//背景分组类型
export const backgroundGroupList: GroupItem[] = [
  {
    type: 'Album',
    name: $r('app.string.background_album')
  },
  {
    type: 'SolidColor',
    name: $r('app.string.background_solid_color')
  },
  {
    type: 'Gradient',
    name: $r('app.string.background_gradient')
  }
]


// 画笔类型列表
export const brushTypesList: BrushItem[] = [
  {
    id: 0,
    type: 'ballpoint',
    name: $r('app.string.brush_ballpoint'),
    icon: $r('app.media.ic_brush_ballpoint')
  },
  {
    id: 1,
    type: 'pencil',
    name: $r('app.string.brush_pencil'),
    icon: $r('app.media.ic_brush_pencil')
  },
  {
    id: 2,
    type: 'fountain',
    name: $r('app.string.brush_fountain'),
    icon: $r('app.media.ic_brush_fountain')
  },
  {
    id: 3,
    type: 'marker',
    name: $r('app.string.brush_marker'),
    icon: $r('app.media.ic_brush_marker')
  },
  {
    id: 4,
    type: 'pixel',
    name: $r('app.string.brush_pixel'),
    icon: $r('app.media.ic_brush_pixel')
  },
  {
    id: 5,
    type: 'charcoal',
    name: $r('app.string.brush_charcoal'),
    icon: $r('app.media.ic_brush_charcoal')
  },
  {
    id: 6,
    type: 'crayon',
    name: $r('app.string.brush_crayon'),
    icon: $r('app.media.ic_brush_crayon')
  },
  {
    id: 7,
    type: 'watercolor',
    name: $r('app.string.brush_watercolor'),
    icon: $r('app.media.ic_brush_watercolor')
  }
]

// 图形类型列表
export const shapeTypesList: MenuItem[] = [
  {
    id: 0,
    type: 'circle',
    title: $r('app.string.shape_circle'),
    normalIcon: $r('app.media.ic_shape_circle'),
    activeIcon: $r('app.media.ic_shape_circle_active')
  },
  {
    id: 1,
    type: 'rectangle',
    title: $r('app.string.shape_rectangle'),
    normalIcon: $r('app.media.ic_shape_rectangle'),
    activeIcon: $r('app.media.ic_shape_rectangle_active')
  },
  {
    id: 2,
    type: 'line',
    title: $r('app.string.shape_line'),
    normalIcon: $r('app.media.ic_shape_line'),
    activeIcon: $r('app.media.ic_shape_line_active')
  }
]

// 顶部返回按钮
export const backButton: TopToolItem = {
  type: 'back',
  icon: $r('app.media.ic_back')
}

// 顶部操作按钮（清空、撤销、重做、保存）
export const topActionsList: TopToolItem[] = [
  {
    type: 'clear',
    icon: $r('app.media.ic_clear')
  },
  {
    type: 'undo',
    icon: $r('app.media.ic_undo_disabled'),
    enabledIcon: $r('app.media.ic_undo_enabled')
  },
  {
    type: 'redo',
    icon: $r('app.media.ic_redo_disabled'),
    enabledIcon: $r('app.media.ic_redo_enabled')
  },
  {
    type: 'save',
    icon: $r('app.media.ic_save')
  }
]

// 底部工具栏按钮
export const canvasToolsList: MenuItem[] = [
  {
    id: 0,
    type: 'brush',
    title: $r('app.string.menu_item_brush'),
    normalIcon: $r('app.media.ic_brush'),
    activeIcon: $r('app.media.ic_brush_active')
  },
  {
    id: 1,
    type: 'color',
    title: $r('app.string.menu_item_color'),
    normalIcon: $r('app.media.ic_color'),
    activeIcon: $r('app.media.ic_color_active')
  },
  {
    id: 2,
    type: 'eraser',
    title: $r('app.string.menu_item_eraser'),
    normalIcon: $r('app.media.ic_eraser'),
    activeIcon: $r('app.media.ic_eraser_active')
  },
  {
    id: 3,
    type: 'shape',
    title: $r('app.string.menu_item_shape'),
    normalIcon: $r('app.media.ic_shape'),
    activeIcon: $r('app.media.ic_shape_active')
  },
  {
    id: 4,
    type: 'background',
    title: $r('app.string.menu_item_background'),
    normalIcon: $r('app.media.ic_background'),
    activeIcon: $r('app.media.ic_background_active')
  }
]