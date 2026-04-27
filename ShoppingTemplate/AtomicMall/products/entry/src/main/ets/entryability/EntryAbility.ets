import { Want } from '@kit.AbilityKit';
import UIAbility from '@ohos.app.ability.UIAbility';
import { KeyboardAvoidMode } from '@ohos.arkui.UIContext';
import window from '@ohos.window';
import { AccountUtils } from 'atomicservice_login';
import { ColorModeUtil, PushUtil, routerStack, WindowUtil } from 'lib_foundation';
import { LoneTakeAnimationsTransition } from 'module_transition';
import { UtilLog } from '@hw-agconnect/util-log';
import { SetupUtil } from '../utils/SetupUtil';

const TAG: string = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want): void {
    UtilLog.setGlobalConfig({
      tag: 'AtomicMall',
      domain: 0xff00,
      open: true,
      showStack: false,
    });
    UtilLog.info(TAG, 'set global log config success.');
    ColorModeUtil.applySavedColorMode(this.context);
    SetupUtil.handleWant(want);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // 元服务静默登录
    AccountUtils.silentLogin((data) => {
      if (data) {
        AppStorage.setOrCreate('userLoginInfo', data);
        UtilLog.info(TAG, 'silentLogin success.');
      }
    });
    windowStage.loadContent('views/Index', (): void => {
      try {
        windowStage
          .getMainWindowSync()
          .getUIContext()
          .setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET_WITH_CARET);
        PushUtil.getTokenSyn();
        LoneTakeAnimationsTransition.init(windowStage);
      } catch (err) {
        UtilLog.error(TAG, JSON.stringify(err));
      }
    });
  }

  onWindowStageActive(windowStage: window.WindowStage): void {
    routerStack.setActive('EntryAbility');
    WindowUtil.setActiveContext('EntryAbility');
  }

  onNewWant(want: Want): void {
    SetupUtil.handleWant(want);
    SetupUtil.jumpToTarget();
  }

  onShare(wantParam: Record<string, Object>): void {
    SetupUtil.onShare(wantParam)
  }
}
