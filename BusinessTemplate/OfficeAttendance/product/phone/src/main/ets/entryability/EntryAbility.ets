import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import {
  DataPreferencesUtils,
  GlobalRegister,
  Logger,
  MainEntryVM,
  TabIndex,
  WindowUtil
} from '@ohos_agcit/office_attendance_common_lib';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { CheckInChannelUtil } from '@ohos_agcit/office_attendance_checkin';

const TAG: string = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  private vm: MainEntryVM = MainEntryVM.instance;
  private windowUtil?: WindowUtil = WindowUtil.getInstance();
  private onWindowSizeChange: (windowSize: window.Size) => void = () => {
    this.windowUtil!.updateWidthBp();
  }

  public onWindowStageCreate(windowStage: window.WindowStage): void {
    Logger.info(TAG, '%{public}s', 'Ability onWindowStageCreate');

    this.windowUtil?.setWindowStage(windowStage);
    windowStage.loadContent('pages/Login', (err) => {
      if (err.code) {
        Logger.error(TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      Logger.info(TAG, 'Succeeded in loading the content.');
    });
    let windowClass: window.Window | undefined = undefined;
    GlobalRegister.init(this.context);
    DataPreferencesUtils.init(this.context, {
      name: 'officeAttendance'
    });
    windowStage.getMainWindow((err: BusinessError, data: window.Window) => {
      if (err.code) {
        Logger.error(TAG, 'Failed to get the main window. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      this.windowUtil!.updateWidthBp();
      data.on('windowSizeChange', this.onWindowSizeChange);
      windowClass = data;
      if (deviceInfo.deviceType === '2in1') {
        data.setWindowDecorVisible(false);
        data.setWindowDecorHeight(64);
      } else {
        windowClass.setWindowLayoutFullScreen(true);
      }
    });
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.OnServiceCardRouterMessage(want);
  }


  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.OnServiceCardRouterMessage(want);
  }

  private OnServiceCardRouterMessage(want: Want) {
    if (want?.parameters?.params) {
      this.vm.curIndex = TabIndex.CHECKIN; // 简化处理，来自卡片的点击事件都是跳转到打卡页
      try {
        let message: string = (JSON.parse(want.parameters?.params as string))?.message;
        if (message === 'Button') {
          CheckInChannelUtil.set();
        }
      } catch (err) {
        Logger.error(TAG, 'parse parameters failed')
      }
    }
  }
}
