export interface TopToolItem {
  type: string
  icon: ResourceStr
  enabledIcon?: ResourceStr
}

export interface MenuItem {
  id: number
  type: string
  title: ResourceStr
  normalIcon: ResourceStr
  activeIcon: ResourceStr
}

// 画笔类型接口
export interface BrushItem {
  id: number
  type: string
  name: ResourceStr
  icon: ResourceStr
}

//菜单项分类
export interface GroupItem {
  type: string
  name: ResourceStr
}

/**
 * 图片编辑页面路由参数
 */
export interface ImageRouterParams {
  uri: string
}