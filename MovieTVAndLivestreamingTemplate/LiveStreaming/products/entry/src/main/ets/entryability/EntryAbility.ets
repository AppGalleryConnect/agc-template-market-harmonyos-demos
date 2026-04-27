import { AbilityConstant, ConfigurationConstant, UIAbility, Want, Configuration } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AppStorageV2, display, window } from '@kit.ArkUI';
import { RouterTable } from '../common/TabConstants';
import { emitter } from '@kit.BasicServicesKit';
import { GlobalContext, WindowManager } from '@agctemplate/utils';
import {
  AiBarHeight,
  AppStorageKeys,
  BreakPoint,
  BreakPointValue,
  DEFAULT_STATUS_BAR_HEIGHT,
  StatusBarHeight,
  ColorMode
} from '@agctemplate/widgets';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  private curBp: BreakPointValue = BreakPointValue.SM;
  private breakPoint = AppStorageV2.connect(BreakPoint, AppStorageKeys.CURRENT_BREAK_POINT,
    () => new BreakPoint(this.curBp))!;
  private statusBarHeight = AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT,
    () => new StatusBarHeight(DEFAULT_STATUS_BAR_HEIGHT))!;
  private aiBarHeight = AppStorageV2.connect(AiBarHeight, AppStorageKeys.AI_BAR_HEIGHT,
    () => new AiBarHeight(0))!;
  private currentColorMode: ColorMode = AppStorageV2.connect(ColorMode, 'colorMode', () => new ColorMode('跟随系统'))!

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    RouterTable.routerInit();
    // ȫ������Ϊǳɫģʽ
    let applicationContext = this.context.getApplicationContext();
    applicationContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    AppStorage.setOrCreate('context', this.context);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');

  }

  onConfigurationUpdate(newConfig: Configuration): void {
    this.currentColorMode.colorMode = newConfig.colorMode!;
    hilog.info(0x0000, 'testTag', 'the newConfig.colorMode is %{public}s',
      JSON.stringify(this.currentColorMode.colorMode) ?? '');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    AppStorage.setOrCreate('windowStage', windowStage);
    GlobalContext.initContext(this.context, windowStage);
    WindowManager.initWindowStage(windowStage);
    let windowClass = windowStage.getMainWindowSync();
    // ��ȡӦ������ʱ�Ĵ��ڳߴ�
    this.updateBreakpoint(windowClass.getWindowProperties().windowRect.width);
    this.updateAvoidArea(windowClass);
    this.windowClassListenEvent(windowClass);
    await WindowManager.setWindowLayoutFullScreen(true)
    WindowManager.setWindowSystemBarProperties({ statusBarColor: 'transparent', navigationBarColor: 'transparent' })


    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    let event: emitter.InnerEvent = {
      eventId: 2
    };
    let eventData: emitter.EventData = {
      data: {
        content: 'foreground',
        id: 2
      }
    };
    try {
      emitter.emit(event, eventData);
      hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
    } catch (e) {
    }
  }

  onBackground(): void {
    // Ability has back to background
    let event: emitter.InnerEvent = {
      eventId: 1
    };
    let eventData: emitter.EventData = {
      data: {
        content: 'background',
        id: 1
      }
    };
    try {
      emitter.emit(event, eventData);
      hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
    } catch (e) {
    }
  }

  private updateAvoidArea(windowClass: window.Window) {
    const avoidArea: window.AvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
    const navAvoidArea: window.AvoidArea =
      windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
    this.aiBarHeight.value = navAvoidArea?.bottomRect?.height ?? 0
    this.statusBarHeight.value = avoidArea?.topRect?.height || DEFAULT_STATUS_BAR_HEIGHT;
  }

  private windowClassListenEvent(windowClass: window.Window) {
    // ע��ص��������������ڳߴ�仯
    windowClass.on('windowSizeChange', (windowSize) => {
      this.updateBreakpoint(windowSize.width)
    })
    // ע��ص�����������״̬���͵ײ�AI bar�ĸ߶�
    windowClass.on('avoidAreaChange', (data) => {
      if (window.AvoidAreaType.TYPE_SYSTEM === data.type) {
        this.statusBarHeight.value = data?.area?.topRect?.height || DEFAULT_STATUS_BAR_HEIGHT;
      } else if (window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR === data.type) {
        this.aiBarHeight.value = data?.area?.bottomRect?.height ?? 0
      }
    });
  }

  private updateBreakpoint(windowWidth: number): void {
    // �����ȵĵ�λ��px����Ϊvp
    let windowWidthVp = windowWidth / display.getDefaultDisplaySync().densityPixels;
    let newBp: BreakPointValue;
    if (windowWidthVp < 600) {
      newBp = BreakPointValue.SM;
    } else if (windowWidthVp < 840) {
      newBp = BreakPointValue.MD;
    } else {
      newBp = BreakPointValue.LG;
    }
    if (this.curBp !== newBp) {
      this.curBp = newBp;
      // ʹ��״̬������¼��ǰ�ϵ�ֵ
      this.breakPoint.value = this.curBp
    }
  }
}