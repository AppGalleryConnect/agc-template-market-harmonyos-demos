import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { serviceNotification } from '@kit.PushKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { RouterUtil } from 'common';
import { formInfo } from '@kit.FormKit';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    this.processWantData(want);
  }

  onNewWant(want: Want): void {
    this.processWantData(want);
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  async onForeground(): Promise<void> {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
    try {
      await this.requestSubscribeNotification();
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      hilog.error(0x0000, 'testTag', 'Request subscribe notification failed: %{public}d %{public}s', e.code, e.message);
    }
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }

  async requestSubscribeNotification() {
    try {
      // 预约挂号成功提醒、挂号取消提醒模板ID
      let entityIds: string[] = ['16890706FC027600', '168908466B026E80'];
      let type: serviceNotification.SubscribeNotificationType =
        serviceNotification.SubscribeNotificationType.SUBSCRIBE_WITH_HUAWEI_ID;
      const res: serviceNotification.RequestResult =
        await serviceNotification.requestSubscribeNotification(this.context, entityIds, type);
      hilog.info(0x0000, 'testTag', 'Succeeded in requesting serviceNotification: %{public}s',
        JSON.stringify(res.entityResult));
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      hilog.error(0x0000, 'testTag', 'Failed to request serviceNotification: %{public}d %{public}s', e.code, e.message);
    }
  }

  processWantData(want: Want) {
    let data = want.parameters;
    // 收到挂号推送消息，进入挂号记录页面
    if (data?.type === 'appointmentPush') {
      RouterUtil.pushPathByName('AppointmentOrderListPage')
    }
    if (data?.[formInfo.FormParam.IDENTITY_KEY] !== undefined) {
      let hasData: boolean = (JSON.parse(data.params as string))?.hasData;
      if (hasData) {
        RouterUtil.pushPathByName('AppointmentOrderListPage')
      } else {
        RouterUtil.pushPathByName('AppointmentMainPage')
      }
    }
  }
}
