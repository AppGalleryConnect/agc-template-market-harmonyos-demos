import { Category } from '../model/Category';
import { ARGB } from '@common/customtypes';

export class CategoryBrowserConfig {

  // 剩余元素数量不满一行时, 会通过占位元素保证布局不受影响
  public static readonly CATEGORY_PLACEHOLDER_ITEM: Category = { id: '', icon: '', label: '' };

  // Swiper 触摸响应区高度的倍率, 使得页面在滑动过程中, 即便触摸点移出 Swiper 区域, 滑动交互依然可以继续维持
  public static readonly SWIPER_RES_REGION_RATE: number = 3;

  // 每页最多有几行元素
  public static readonly MAX_ROWS: number = 3;

  // 每页最多有几列元素
  public static readonly MAX_COLUMNS: number = 5;

  // 关键行的数量 (前 N 行为关键行, 会使用视觉风格更加突出的样式)
  public static readonly PRIMARY_ROW_COUNT: number = 2;

  // 类型标签容器的宽度
  public static readonly CATEGORY_TAG_WIDTH: number = 54;

  // 关键图标的大小
  public static readonly PRIMARY_ICON_SIZE: number = 48;

  // 图标大小
  public static readonly ICON_SIZE: number = 40;

  // 图标与文字的距离
  public static readonly ICON_LABEL_SPACING: number = 3.5;

  // 行间距 (对于每页的第 1 行, 其与容器上边缘的距离也会使用这个间距)
  public static readonly ROW_SPACING: number = 12;

  // 文本字体大小
  public static readonly LABEL_FONT_SIZE: number = 11;

  // 文本宽度 (文本宽度不会影响其它元素的布局, 可以设置一个相对较大的值保证内容显示完整)
  public static readonly LABEL_WIDTH: number = 1000;

  // 指示器容器高度
  public static readonly INDICATOR_CONTAINER_HEIGHT: number = 29.32;

  // 指示器间距
  public static readonly INDICATOR_SPACING: number = 8;

  // 指示器边框圆角半径
  public static readonly INDICATOR_BORDER_RADIUS: number = 2;

  // 指示器正常状态宽度
  public static readonly INDICATOR_WIDTH: number = 4;

  // 指示器正常状态高度
  public static readonly INDICATOR_HEIGHT: number = 3.7;

  // 指示器正常状态颜色
  public static readonly INDICATOR_COLOR_ARGB: ARGB = [0x19, 0x00, 0x00, 0x00];

  // 指示器选中状态宽度
  public static readonly INDICATOR_SELECTED_WIDTH: number = 12;

  // 指示器选中状态高度
  public static readonly INDICATOR_SELECTED_HEIGHT: number = 3.7;

  // 指示器选中状态颜色
  public static readonly INDICATOR_SELECTED_COLOR_ARGB: ARGB = [0xFF, 0xE6, 0x45, 0x66];

}
