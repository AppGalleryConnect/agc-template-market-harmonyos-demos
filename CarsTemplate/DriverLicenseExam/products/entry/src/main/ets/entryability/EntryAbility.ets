import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { Logger, PreferencesUtil } from '@ohos_agcit/driver_license_exam_commonlib';
import { BusinessError } from '@kit.BasicServicesKit';
import { WantUtils } from '../util/WantUtils';
import { ShareService } from 'aggregated_share';
import { notificationManager } from '@kit.NotificationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CommonModel } from '@ohos_agcit/driver_license_exam_commonlib';
import { EXAM_MANAGER_TYPE, ROUTE_PARAM, Video, ExamService } from '@ohos_agcit/driver_license_exam_datasource'
import { LoneTakeAnimationsTransition } from 'module_transition'

const TAG: string = '[EntryAbility]';

export default class EntryAbility extends UIAbility {

  public onWindowStageCreate(windowStage: window.WindowStage): void {
    Logger.info(TAG, '%{public}s', 'Ability onWindowStageCreate');

    LoneTakeAnimationsTransition.init(windowStage);

    try {
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          Logger.error(TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
          return;
        }
        try {
          Logger.info(TAG, 'Succeeded in loading the content.');

          AppStorage.setOrCreate('windowStage', windowStage);

          // 获取应用主窗口
          let windowClass: window.Window = windowStage.getMainWindowSync();
          // 设置窗口全屏
          let isLayoutFullScreen = true;
          windowClass.setWindowLayoutFullScreen(isLayoutFullScreen).then(() => {
            Logger.info(TAG, 'Succeeded in setting the window layout to full-screen mode.');
          }).catch((err: BusinessError) => {
            Logger.error(TAG, 'Failed to set full-screen mode: %{public}s', JSON.stringify(err) ?? '');
          })

          // 获取布局避让的遮挡区域
          let type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR;
          let avoidArea = windowClass.getWindowAvoidArea(type);
          let bottomRectHeight = avoidArea.bottomRect.height;
          AppStorage.setOrCreate('bottomRectHeight', bottomRectHeight);

          type = window.AvoidAreaType.TYPE_SYSTEM;
          avoidArea = windowClass.getWindowAvoidArea(type);
          let topRectHeight = avoidArea.topRect.height;
          AppStorage.setOrCreate('topRectHeight', topRectHeight);

          notificationManager.requestEnableNotification(this.context).then(() => {
            hilog.info(0x0000, 'testTag', `[ANS] requestEnableNotification success`);
          }).catch((err: BusinessError) => {
            hilog.error(0x0000, 'testTag', `[ANS] requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
          });

          // 注册监听函数，动态获取避让区数据
          windowClass.on('avoidAreaChange', (data) => {
            try {
              if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
                let topRectHeight = data.area.topRect.height;
                AppStorage.setOrCreate('topRectHeight', topRectHeight);
              } else if (data.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
                let bottomRectHeight = data.area.bottomRect.height;
                AppStorage.setOrCreate('bottomRectHeight', bottomRectHeight);
              }
            } catch (e) {
              Logger.error(TAG, 'avoidAreaChange handler error: %{public}s', JSON.stringify(e) ?? '');
            }
          });

          this.setLightOrDarkMode(this.context)
        } catch (e) {
          Logger.error(TAG, 'loadContent post-success error: %{public}s', JSON.stringify(e) ?? '');
        }
      });
    } catch (e) {
      Logger.error(TAG, 'loadContent failed: %{public}s', JSON.stringify(e) ?? '');
    }
  }
  // 实例化分享服务
  private shareServiceImpl: ShareService =
    ShareService.create()
    // todo 填写微信开放平台配置的应用AppID
      .initWX('wxc92d9d6570127a32')
      // todo 填写QQ互联平台配置的应用AppID
      .initQQ(102061317);

  private setLightOrDarkMode(context:Context) {
    const preferencesUtil = PreferencesUtil.getInstance();
    const preference = preferencesUtil.getPreferences(context)
    const value = preferencesUtil.getPreferencesValue(preference, 'lightDarkMode') || 0;
    AppStorage.setOrCreate('lightDarkMode', value);
    if (value === 0) {
      context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } else if (value === 1) {
      context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
    } else if (value === 2) {
      context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    }
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    Logger.info(TAG, 'Ability onCreate');
    WantUtils.handlePushCall(want);
    this.shareServiceImpl.handleWant(want, this.context);
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.setLightOrDarkMode(this.context)
    Logger.info(TAG, 'Ability onNewWant');
    if (want.parameters && want.parameters.params) {
      let param:ESObject =  {};
      try {
        param = JSON.parse(want.parameters.params as string)
      } catch (e) {
      }

      if (param.message === 'practiceView') {
        const examService = ExamService.instance(this.context as Context)
        const par:ROUTE_PARAM = {
          title:'模拟考试',
          type: EXAM_MANAGER_TYPE.mock_exam,
          examManager: examService.getMockExamManager('模拟考试')
        }
        CommonModel.instance.navStack.replacePathByName('practiceView', par)
      } else if (param.message === 'orderPractice') {
        const param:ROUTE_PARAM = {
          title:'顺序练习',
          type: EXAM_MANAGER_TYPE.sequence
        }
        CommonModel.instance.navStack.replacePathByName('practiceView', param)
      }
    }
    WantUtils.handlePushWant(want);
    this.shareServiceImpl.handleWant(want, this.context);
  }


}
