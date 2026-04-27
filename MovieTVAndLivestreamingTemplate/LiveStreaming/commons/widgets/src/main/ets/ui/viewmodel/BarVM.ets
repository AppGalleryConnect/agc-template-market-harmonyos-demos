import { AppStorageV2 } from '@kit.ArkUI';
import { GlobalContext } from '@agctemplate/utils';
import { AppStorageKeys } from '../../const/AppStorageKeys';
import { AiBarHeight, StatusBarHeight } from '../avoid_area/AvoidArea';
import { BreakPoint } from '../break_point/BreakPoint';
import { BreakPointValue } from '../break_point/BreakPointType';

@ObservedV2
export class BarVM {
  // 用户信息
  @Trace currentBreakpoint: BreakPoint = AppStorageV2.connect(BreakPoint, AppStorageKeys.CURRENT_BREAK_POINT,
    () => new BreakPoint(BreakPointValue.SM))!;
  @Trace aiBarHeight: AiBarHeight = AppStorageV2.connect(AiBarHeight, AppStorageKeys.AI_BAR_HEIGHT,
    () => new AiBarHeight())!;
  @Trace statusBarHeight: StatusBarHeight = AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT,
    () => new StatusBarHeight())!;
  @Trace aiBarH: string = `${GlobalContext.getUIContext().px2vp(this.aiBarHeight.value)}vp`
  @Trace staBarH: string = `${GlobalContext.getUIContext().px2vp(this.statusBarHeight.value)}vp`
  private static _instance: BarVM;

  public static get instance() {
    if (!BarVM._instance) {
      BarVM._instance = new BarVM();
    }
    return BarVM._instance;
  }
}