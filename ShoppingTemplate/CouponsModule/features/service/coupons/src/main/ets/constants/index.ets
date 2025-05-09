export const MY_TAB_BAR = ['全部', '待使用', '已使用', '已过期'];

export const SELECT_TAB_BAR = ['可用', '不可用'];

export class TabConstant {
  static readonly ACTIVE_COLOR: ResourceColor = $r('app.color.sys_brand_fuchsia');
  // 待选颜色: 同上
  static readonly FROZEN_COLOR: ResourceColor = 'rgba(0, 0, 0, 0.6)';
  // 导航区背景颜色
  static readonly TAB_BAR_BGCOLOR: ResourceColor = $r('app.color.sys_background_gary');
  // 内容背景颜色
  static readonly TAB_CONTENT_BGCOLOR: ResourceColor = $r('app.color.sys_background_gary');
  // 选中文字粗细
  static readonly ACTIVE_WEIGHT: number | string | FontWeight = FontWeight.Medium;
  // 待选文字粗细
  static readonly FROZEN_WEIGHT: number | string | FontWeight = FontWeight.Normal;
  // 动画时长
  static readonly ANIMATION_DURATION: number = 300;
  // 导航区高度
  static readonly TAB_BAR_HEIGHT: number = 56;
  // 条形高度
  static readonly LINE_HEIGHT: number = 2;
  // 条形距离顶部位置
  static readonly MARGIN_TOP: number = 44;
}