import { RectInfoPx } from './ComponentAttrUtils';
import { LongTakeTransitionOptions } from './Options';
import { LongTakeTransitionType } from '../../../../Index';

export class LongTakeTransitionParam {
  public componentId: string = '';

  public transitionType: LongTakeTransitionType = LongTakeTransitionType.CardLongTake;

  // 响应点击事件的组件的区域和位置信息，单位为px
  public componentRectInfo: RectInfoPx = new RectInfoPx();

  public options: LongTakeTransitionOptions | undefined = undefined;

  constructor(componentRectInfo: RectInfoPx, options?: LongTakeTransitionOptions) {
    this.componentRectInfo = componentRectInfo;
    this.options = options;
  }
}