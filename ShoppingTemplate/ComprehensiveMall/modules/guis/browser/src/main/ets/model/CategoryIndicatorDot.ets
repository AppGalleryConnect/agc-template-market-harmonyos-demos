import { CategoryBrowserConfig as Config } from '../config/CategoryBrowserConfig';
import { CategoryUtils } from '../utils/CategoryUtils';

@ObservedV2
export class CategoryIndicatorDot {

  @Trace
  public color: ResourceColor = CategoryUtils.argbToHexColor(Config.INDICATOR_COLOR_ARGB);

  @Trace
  public width: number = Config.INDICATOR_WIDTH;

  @Trace
  public height: number = Config.INDICATOR_HEIGHT;

}
