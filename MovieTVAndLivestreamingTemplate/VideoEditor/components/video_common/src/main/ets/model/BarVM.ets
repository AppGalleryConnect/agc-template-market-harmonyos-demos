import { AppStorageV2, window } from '@kit.ArkUI';
import { AppStorageKeys } from '../utils/AppStorageKeys';
import { AiBarHeight, StatusBarHeight } from './AvoidArea';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

@ObservedV2
export class BarVM {
  @Trace aiBarHeight: AiBarHeight = AppStorageV2.connect(AiBarHeight, AppStorageKeys.AI_BAR_HEIGHT,
    () => new AiBarHeight())!;
  @Trace statusBarHeight: StatusBarHeight = AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT,
    () => new StatusBarHeight())!;
  @Trace aiBarH: number = this.aiBarHeight.value
  @Trace staBarH: number = this.statusBarHeight.value
  private static _instance: BarVM;

  public static get instance() {
    if (!BarVM._instance) {
      BarVM._instance = new BarVM();
    }
    return BarVM._instance;
  }

  setStatusFontColor(color?: string) {
    try {
      let w: window.Window = (getContext() as common.UIAbilityContext).windowStage.getMainWindowSync()
      let sysBarProps: window.SystemBarProperties = {
        statusBarContentColor: color
      }
      w.setWindowSystemBarProperties(sysBarProps)
        .then(() => {
        }).catch((err: BusinessError) => {
      });
    } catch (err) {
    }
  }

}