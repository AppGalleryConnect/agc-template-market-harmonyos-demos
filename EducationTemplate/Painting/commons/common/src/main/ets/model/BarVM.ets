import { AppStorageV2 } from '@kit.ArkUI';
import { AppStorageKeys } from '../constant/AppStorageKeys';
import { AiBarHeight, StatusBarHeight } from './AvoidArea';

@ObservedV2
export class BarVM {
  @Trace aiBarHeight: AiBarHeight = AppStorageV2.connect(AiBarHeight, AppStorageKeys.AI_BAR_HEIGHT,
    () => new AiBarHeight())!;
  @Trace statusBarHeight: StatusBarHeight = AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT,
    () => new StatusBarHeight())!;
  // 底部导航栏
  @Trace aiBarH: number = this.aiBarHeight.value
  // 顶部状态栏
  @Trace staBarH: number = this.statusBarHeight.value
  private static _instance: BarVM;

  public static get instance() {
    if (!BarVM._instance) {
      BarVM._instance = new BarVM();
    }
    return BarVM._instance;
  }
}