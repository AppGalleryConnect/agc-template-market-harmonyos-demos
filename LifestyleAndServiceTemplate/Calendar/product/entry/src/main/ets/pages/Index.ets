import { PushCardInfo, PushUtils, SettingState, ThemeModel } from 'common';
import { TabContainer } from './TabContainer'
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { RouterModule } from 'router_module';
import { IndexVM } from '../viewmodel/IndexVM';

@Entry
@ComponentV2
struct Index {
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () => new ThemeModel())!;
  @Local settingState: SettingState = PersistenceV2.connect(SettingState, () => new SettingState())!;
  @Local pushCardInfo: PushCardInfo = AppStorageV2.connect(PushCardInfo, () => new PushCardInfo())!;
  vm: IndexVM = new IndexVM();

  @Monitor('pushCardInfo.id')
  pushSwitchChange() {
    PushUtils.interceptPushInfo()
  }

  @Monitor('settingState.updateSwitch')
  updateSwitchChange(monitor: IMonitor) {
    if (this.settingState.updateSwitch) {
      PushUtils.sendPushNotice(this.getUIContext().getHostContext() as common.UIAbilityContext, 'update')
    }
  }

  aboutToAppear(): void {
    this.vm.displayOrientationListener()
    this.vm.registerBreakpointListener(this.getUIContext());
    /**
     * 模拟推送消息延迟发送
     * */
    setTimeout(() => {
      PushUtils.sendPushNotice(this.getUIContext().getHostContext() as common.UIAbilityContext)
    }, 1000)
  }

  aboutToDisappear(): void {
    this.vm.unregisterBreakpointListener();
  }

  build() {
    Navigation(RouterModule.getStack()) {
      TabContainer()
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
  }
}