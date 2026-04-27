/**
 * 角标配置
 */
export interface NavBadge {
  /** 角标类型：红点 或 数字 */
  type: 'dot' | 'number';

  /** type 为 'number' 时显示的数字，超过 maxCount 显示 maxCount+ */
  count?: number;

  /** 数字角标上限，默认 99 */
  maxCount?: number;
}

/**
 * 悬浮导航栏 - 导航项数据模型
 */
export interface NavItemModel {
  /** 显示标题 */
  title: string;

  /** 图标：支持 emoji 字符串 或 Resource 图片资源 */
  icon: string | Resource;

  /** 选中态图标（可选，未设置时复用 icon） */
  selectedIcon?: string | Resource;

  /** 角标配置（可选） */
  badge?: NavBadge;
}
