import { Want } from '@kit.AbilityKit';
import UIAbility from '@ohos.app.ability.UIAbility';
import { KeyboardAvoidMode } from '@ohos.arkui.UIContext';
import window from '@ohos.window';
import { LoneTakeAnimationsTransition } from 'module_transition';
import { UtilLog } from '@hw-agconnect/util-log';
import { BreakpointSystem, routerStack, WindowUtil } from 'lib_foundation';
import { splitNavStore } from '../utils/SplitNavStore';

const TAG: string = '[SecondAbility]';

/** 应用内分屏比较窗口 Ability */
export default class SecondAbility extends UIAbility {
  onCreate(want: Want): void {
    const productId = want.parameters?.productId as string | undefined;
    if (productId) {
      splitNavStore.productId = productId;
      const rawSlotId = want.parameters?.slotId as string | undefined;
      splitNavStore.slotId = rawSlotId && rawSlotId.length > 0 ? rawSlotId : undefined;
      splitNavStore.isSplitPage = true;
    }
  }

  onWindowStageActive(windowStage: window.WindowStage): void {
    routerStack.setActive('SecondAbility');
    WindowUtil.setActiveContext('SecondAbility');
  }

  onDestroy(): void {
    routerStack.isSplitActive = false;
    routerStack.setActive('EntryAbility');
    WindowUtil.setActiveContext('EntryAbility');
    // SecondAbility 窗口销毁时其上的监听器已随之失效，无需显式 off。
    // 重新绑定到 EntryAbility 主窗口，确保 EntryAbility 恢复全屏后
    // BreakpointSystem 能正确响应窗口尺寸变化并更新断点值。
    BreakpointSystem.register(WindowUtil.globalUIContext);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    try {
      windowStage.loadContent('views/Index', (): void => {
        try {
          windowStage
            .getMainWindowSync()
            .getUIContext()
            .setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET_WITH_CARET);
          LoneTakeAnimationsTransition.init(windowStage);
        } catch (err) {
          UtilLog.error(TAG, JSON.stringify(err));
        }
      });
    } catch (err) {
      UtilLog.error(TAG, 'loadContent failed: ' + JSON.stringify(err));
    }
  }
}
