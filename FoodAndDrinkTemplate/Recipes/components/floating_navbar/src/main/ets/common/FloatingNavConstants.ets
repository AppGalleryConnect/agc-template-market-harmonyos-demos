/**
 * 悬浮导航栏模块内部默认值（不对外暴露）
 * 颜色统一使用 #AARRGGBB 格式
 */
export class FloatingNavDefaults {
  // 容器默认值
  static readonly BORDER_RADIUS: number = 32;
  static readonly BACKGROUND_COLOR: string = '#1AFFFFFF';   // 白色 10% 透明
  static readonly BLUR_STYLE: BlurStyle = BlurStyle.Thin;
  static readonly BORDER_WIDTH: number = 0.5;
  static readonly BORDER_COLOR: string = '#B3FFFFFF'; // 白色 70% 透明

  // 内容默认值
  static readonly ICON_SIZE: number = 24;
  static readonly TITLE_SIZE: number = 10;
  static readonly ACTIVE_COLOR: string = '#FF1890FF'; // 主题蓝
  static readonly INACTIVE_COLOR: string = '#FF999999'; // 灰色

  // 阴影默认值
  static readonly SHADOW_RADIUS: number = 16;
  static readonly SHADOW_COLOR: string = '#1A000000'; // 黑色 10% 透明
  static readonly SHADOW_OFFSET_Y: number = 4;
  // 角标默认值
  static readonly BADGE_MAX_COUNT: number = 99;
  static readonly BADGE_BG_COLOR: string = '#FFFF4444'; // 红色
  static readonly BADGE_TEXT_COLOR: string = '#FFFFFFFF'; // 白色
  static readonly BADGE_FONT_SIZE: number = 10;
  static readonly BADGE_DOT_SIZE: number = 8;
}
