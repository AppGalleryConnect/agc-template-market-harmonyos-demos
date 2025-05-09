import { NewsTypeModel } from '../model/NewsTypeModel';

export class HomeConstants {

  /**
   * TabBars un select text font weight.
   */
  public static readonly TAB_BARS_UN_SELECT_TEXT_FONT_WEIGHT: number = 400;

  /**
   * TabBars select text font weight.
   */
  public static readonly TAB_BARS_SELECT_TEXT_FONT_WEIGHT: number = 700;

  /**
   * TabBars bar height.
   */
  public static readonly TAB_BARS_BAR_HEIGHT: string = '3.6%';

  /**
   * TabBars horizontal padding.
   */
  public static readonly TAB_BARS_HORIZONTAL_PADDING: string = '2.2%';

  /**
   * TabBars bar width.
   */
  public static readonly TAB_BARS_BAR_WIDTH: string = '100%';

  /**
   * TabBars default news types.
   */
  public static readonly TAB_BARS_DEFAULT_NEWS_TYPES: NewsTypeModel[] = [
    { id: 0, name: '热门' },
    { id: 1, name: '本地' }
  ];

}