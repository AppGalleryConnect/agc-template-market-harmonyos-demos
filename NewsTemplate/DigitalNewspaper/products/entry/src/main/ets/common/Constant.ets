/**
 * 常量
 */
export class Constant {
  // Percent
  public static readonly FULL_PERCENT: string = '100%';
  public static readonly HALF_PERCENT: string = '50%';
  // Padding
  public static readonly PADDING_XXS: number = 2;
  public static readonly PADDING_XS: number = 4;
  public static readonly PADDING_S: number = 8;
  public static readonly PADDING_M: number = 12;
  public static readonly PADDING_L: number = 16;
  public static readonly PADDING_XL: number = 20;
  public static readonly PADDING_XXL: number = 24;
  public static readonly PADDING_TIP: number = 40;
  public static readonly DEFAULT_AUTO = 'auto';
  // 时间显示器高度
  public static readonly DATA_BUTTON_HEIGHT: number = 40;
  // 报纸的宽高比
  public static readonly NEWSPAPER_RATIO: number = 0.675;
  // 宽屏的宽高比
  public static readonly WIDE_SCREEN_RATIO = 0.9;
  // 报纸底部堆叠高度
  public static readonly BOTTOM_LAYOUT_HEIGHT: number = 8;
  // 朗读图标大小
  public static readonly ICON_SIZE: number = 24;
  public static readonly ICON_ROW_SIZE: number = 48;
  // Swiper容器id
  public static readonly SWIPER_ID: string = 'swiper_image';
  // Swiper提示文字id
  public static readonly SWIPER_TIP_ID: string = 'swiper_tip';
}

export enum RouterMap {
  MAIN = 'Main', // 元服务主页面
  NEWS_DETAIL = 'NewsDetail', // 新闻详情页
}