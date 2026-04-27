/**
 * 悬浮导航栏样式配置（所有属性均可选，未设置时使用默认值）
 */
export interface FloatingNavBarStyle {
  // ===== 容器样式 =====
  /** 导航栏宽度，默认 '90%' */
  barWidth?: Length;
  /** 导航栏高度，默认 56 */
  barHeight?: number;
  /** 圆角半径，默认 32 */
  borderRadius?: number;
  /** 背景色，默认 'rgba(255, 255, 255, 0.10)' */
  backgroundColor?: string;
  /** 背景模糊风格，默认 BlurStyle.Thin */
  blurStyle?: BlurStyle;
  /** 边框宽度，默认 0.5 */
  borderWidth?: number;
  /** 边框颜色，默认 'rgba(255, 255, 255, 0.70)' */
  borderColor?: string;
  /** 水平内边距，默认 16 */
  paddingHorizontal?: number;

  // ===== 内容样式 =====
  /** 图标大小（文字图标的字号 / 图片图标的宽高），默认 22 */
  iconSize?: number;
  /** 标题字号，默认 12 */
  titleSize?: number;
  /** 选中颜色，默认 '#1890FF' */
  activeColor?: string;
  /** 未选中颜色，默认 '#999999' */
  inactiveColor?: string;

  // ===== 阴影 =====
  /** 阴影半径，默认 16 */
  shadowRadius?: number;
  /** 阴影颜色，默认 '#1A000000' */
  shadowColor?: string;
  /** 阴影 Y 轴偏移，默认 4 */
  shadowOffsetY?: number;
}
