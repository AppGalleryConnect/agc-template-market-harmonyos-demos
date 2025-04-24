
export interface VerticalAnchor {
  anchor: string;
  align: VerticalAlign;
}

export interface HorizontalAnchor {
  anchor: string;
  align: HorizontalAlign;
}

export class ComponentConst {
  static FULL_PARENT = '100%';
  static AUTO_SIZE = 'auto';

  // 卡片常量
  static readonly CARD_PADDING_HORIZON = 16;
  static readonly CARD_PADDING_VERTICAL = 16;
  static readonly CARD_BG_COLOR: ResourceColor = Color.White;
  static readonly CARD_RADIUS_SMALL: Length = 8;
  static readonly CARD_RADIUS_MIDDLE: Length = 16;
  static readonly CARD_RADIUS_LARGE: Length = 32;
  static readonly CARD_SPACE_SMALL = 12;
  static readonly CARD_SPACE_LARGE = 24;

  // 页面常量
  static readonly PAGE_VERTICAL_PADDING = 12;
  static readonly PAGE_HORIZONTAL_PADDING = 16;

  // Swiper常量
  static readonly SWIPER_ITEM_SPACE = 4;

  // Tabs常量
  static readonly TABS_BAR_HEIGHT = 40;

  // Icon常量
  static readonly ICON_SIZE_TINY: SizeOptions = { width: 11, height: 11 };
  static readonly ICON_SIZE_S: SizeOptions = { width: 16, height: 16 };
  static readonly ICON_SIZE_XS: SizeOptions = { width: 24, height: 24 };
  static readonly ICON_SIZE_M: SizeOptions = { width: 40, height: 40 };
  static readonly ICON_SIZE_XM: SizeOptions = { width: 64, height: 64 };
  static readonly ICON_SIZE_XL: SizeOptions = { width: 120, height: 120 };

  // 动画常量
  static readonly animationLinearOutSlowIn: AnimateParam = { curve: Curve.LinearOutSlowIn, duration: 300 };

  // 相对布局绑定参数，不传anchor默认绑定父组件
  static readonly PARENT_ANCHOR = '__container__';
  public static bindBottom(anchor?: string): VerticalAnchor {
    return { anchor: anchor ?? ComponentConst.PARENT_ANCHOR, align: VerticalAlign.Bottom };
  }

  public static bindTop(anchor?: string): VerticalAnchor {
    return { anchor: anchor ?? ComponentConst.PARENT_ANCHOR, align: VerticalAlign.Top };
  }

  public static bindVerticalCenter(anchor?: string): VerticalAnchor {
    return { anchor: anchor ?? ComponentConst.PARENT_ANCHOR, align: VerticalAlign.Center };
  }

  public static bindStart(anchor?: string): HorizontalAnchor {
    return { anchor: anchor ?? ComponentConst.PARENT_ANCHOR, align: HorizontalAlign.Start };
  }

  public static bindEnd(anchor?: string): HorizontalAnchor {
    return { anchor: anchor ?? ComponentConst.PARENT_ANCHOR, align: HorizontalAlign.End };
  }

  public static bindHorizontalCenter(anchor?: string): HorizontalAnchor {
    return { anchor: anchor ?? ComponentConst.PARENT_ANCHOR, align: HorizontalAlign.Center };
  }
}