import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AppResourceApi, ResourceData, ResourceDataResult } from 'common';
import { cloudFunction } from '@kit.CloudFoundationKit';
import { emitter } from '@kit.BasicServicesKit';

let preloadEvent: emitter.InnerEvent = {
  eventId: 1,
  priority: emitter.EventPriority.HIGH
};

export default class EntryAbility extends UIAbility {
  private widgetMsg: string = '';
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    // 获取卡片router事件中传递的targetPage参数
    if (want?.parameters?.params) {
      // want.parameters.params 对应 postCardAction() 中 params 内容
      let params: Record<string, Object> = JSON.parse(want.parameters.params as string);
      this.widgetMsg = params.message as string;
    }

    // 在应用启动时调用函数获取应用数据
    this.functionPreload();
  }

  // 如果UIAbility已在后台运行，在收到Router事件后会触发onNewWant生命周期回调
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    if (want?.parameters?.params) {
      // want.parameters.params 对应 postCardAction() 中 params 内容
      let params: Record<string, Object> = JSON.parse(want.parameters.params as string);
      this.widgetMsg = params.message as string;
      AppStorage.setOrCreate('widgetRouter', this.widgetMsg)
    }
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    AppStorage.setOrCreate('widgetRouter', this.widgetMsg)
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

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }

  functionPreload() {
    AppResourceApi.getResourceData(cloudFunction.LoadMode.PRELOAD).then((res) => {
      let result = res.result as ResourceDataResult
      if (result.ret.code === 0) {
        let resourceData = result.result as ResourceData
        emitter.emit(preloadEvent, {
          data: {
            resourceData: resourceData
          }
        })
        AppStorage.setOrCreate('resourceData', resourceData)
      } else {
        this.functionNormal()
      }
    }).catch(() => {
      this.functionNormal()
    })
  }

  functionNormal() {
    AppResourceApi.getResourceData(cloudFunction.LoadMode.NORMAL).then((res) => {
      let result = res.result as ResourceDataResult
      if (result.ret.code === 0) {
        let resourceData = result.result as ResourceData
        emitter.emit(preloadEvent, {
          data: {
            resourceData: resourceData
          }
        });
        AppStorage.setOrCreate('resourceData', resourceData)
      }
    })
  }
}
