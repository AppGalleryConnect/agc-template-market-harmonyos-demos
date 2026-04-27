// export class RouteMap {
//   // 地址管理页面
//   public static ADDRESS_MANAGE_PAGE: string = 'AddressManagePage';
//
//   // 地址编辑页面
//   public static ADDRESS_EDIT_PAGE: string = 'AddressEditPage';
// }

export class IStyle {
  // 底部导航栏高度
  public static readonly BOTTOM_NAV_HEIGHT: number = 48;

  // 底部导航栏模糊选项 (开启模糊时生效)
  public static readonly BOTTOM_NAV_BLUR_STYLE_OPTION: BackgroundBlurStyleOptions =
    { scale: 0.9 };

  // 元服务胶囊高度
  public static readonly MENU_BAR_HEIGHT: number = 36;

  // 元服务胶囊宽度
  public static readonly MENU_BAR_WIDTH: number = 80.92;

  // 元服务胶囊边框宽度
  public static readonly MENU_BAR_BORDER_WIDTH: Length = $r(
    'sys.float.border_small',
  );

  // 元服务胶囊边框圆角半径
  public static readonly MENU_BAR_BORDER_RADIUS: number = 18;

  // 元服务胶囊与屏幕右边缘的距离
  public static readonly MENU_BAR_MARGIN_RIGHT: number = 8;

  // 标题栏高度
  public static readonly TITLE_BAR_HEIGHT: number = 56;

  // 标题栏返回按钮宽度
  public static readonly TITLE_BAR_BACK_BTN_WIDTH: number = 42;

  // 标题栏返回按钮内嵌图标高度
  public static readonly TITLE_BAR_BACK_ICON_HEIGHT: number = 22;

  // 分割线高度
  public static readonly DIVIDER_HEIGHT: number = 1;

  // 卡片间距
  public static readonly CARD_GAP: number = 10;
}

export class IColor {
  // 纯白色
  public static readonly WHITE: ResourceStr = '#FFFFFFFF';

  // 淡灰色 85% 透明
  public static readonly GRAY_LIGHT_TRANSPARENT_85: ResourceStr = '#D9FAFAFA';

  // 超淡灰色 95% 透明 (用于背景色)
  public static readonly BACKGROUND: ResourceStr = '#F2F1F3F5';

  // 高亮红粉色 (用于主题色)
  public static readonly THEME_PRIMARY: ResourceStr = '#FFE64566';

  // 黑色 5% 透明
  public static readonly BLACK_TRANSPARENT_5: ResourceStr = '#0D000000';

  // 黑色 40% 透明
  public static readonly BLACK_TRANSPARENT_40: ResourceStr = '#66000000';

  // 黑色 60% 透明
  public static readonly BLACK_TRANSPARENT_60: ResourceStr = '#99000000';

  // 黑色 90% 透明
  public static readonly BLACK_TRANSPARENT_90: ResourceStr = '#E6000000';
}

export class IFontSize {
  public static readonly TITLE: string = '18vp';

  public static readonly SUB_TITLE: string = '16vp';

  public static readonly BODY: string = '14vp';

  public static readonly CAPTION: string = '12vp';

  public static readonly TINY: string = '10vp';
}

export enum Operation {
  CREATE,
  EDIT,
}

export enum ViewModelState {
  UNINITIALIZED = 'UNINITIALIZED',
  READY = 'READY',
  INIT_FAILED = 'INIT_FAILED',
}

export enum LoadMode {
  INIT = 'INIT',
  REFRESH = 'REFRESH',
  LOAD_MORE = 'LOAD_MORE',
}
