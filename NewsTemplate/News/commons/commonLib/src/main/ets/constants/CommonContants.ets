export class CommonConstants {
  // 域名
  public static readonly BASE_URL = '';
  // 全屏宽度
  public static readonly FULL_WIDTH = '100%';
  // 全屏高度
  public static readonly FULL_HEIGHT = '100%';

  public static PREFERENCES_NAME = 'newsData.db';

  public static KEY_NAME = 'newsData';

  /**
   * Full percent.
   */
  public static readonly FULL_PERCENT: string = '100%';

  /**
   * Ninety percent.
   */
  public static readonly NINETY_PERCENT: string = '90%';

  /**
   * Common zero.
   */
  public static readonly ZERO: number = 0;

  /**
   * Font weight 500.
   */
  public static readonly FONT_WEIGHT_500: number = 500;

  /**
   * Font weight 400.
   */
  public static readonly FONT_WEIGHT_400: number = 400;

  /**
   * Maximum number of lines of text.
   */
  public static readonly MAX_LINES: number = 3;

  /**
   * Indicates the maximum number of addresses returned by reverse geocoding query..
   */
  public static readonly MAX_ITEMS: number = 1;

  /**
   * Layout weight.
   */
  public static readonly LAYOUT_WEIGHT: number = 1;

  /**
   * ListItem space.
   */
  public static readonly LIST_ITEM_SPACE: number = 14;

  /**
   * List space.
   */
  public static readonly LIST_SPACE: number = 3;

  /**
   * AlphabetIndexer itemSize.
   */
  public static readonly ITEM_SIZE: number = 20;

  /**
   * Text opacity.
   */
  public static readonly TEXT_OPACITY: number[] = [1, 0.4, 0.6, 0.05];

  /**
   * Device types.
   */
  public static readonly DEVICE_TYPES: string[] = ['2in1', 'tablet'];

  /**
   * Tab bar height for sm and md.
   */
  public static readonly TAB_BAR_HEIGHT: number = 35;

  /**
   * Bottom rect height.
   */
  public static readonly BOTTOM_RECT_HEIGHT: number = 24;

  /**
   * Grid horizontal gutter
   */
  public static readonly GRID_HORIZONTAL_GUTTER: string[] = ['24vp', '32vp'];

  /**
   * Grid vertical gutter
   */
  public static readonly GRID_VERTICAL_GUTTER: string[] = ['4vp', '16vp'];
}
