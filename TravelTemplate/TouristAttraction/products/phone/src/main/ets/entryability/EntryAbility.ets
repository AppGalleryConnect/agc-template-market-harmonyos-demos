import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { UIBase } from '@hw-agconnect/ui-base';
import { PageUtil } from 'common';
import { WindowSize } from 'types';
import { CustomShareParams, ShareInfo } from 'module_base';
import { UtilLog } from '@hw-agconnect/util-log';
import { RouterModule } from '../model/TabBarInfo';

export default class EntryAbility extends UIAbility {
  private pageIndex: number = 0;
  private currentWindowStage: window.WindowStage | null = null;
  private _windowSize: WindowSize = AppStorageV2.connect(WindowSize, 'WindowSize', () => new WindowSize())!;

  handleShare(want: Want) {
    // 接收方：从want中获取自定义参数，用于后续实现页面的路由跳转
    try {
      const shareParams: CustomShareParams = JSON.parse(want?.parameters?.custShareParam as string)
      if (shareParams) {
        const shareRouter: CustomShareParams = AppStorageV2.connect(CustomShareParams, () => new CustomShareParams())!;
        shareRouter.pageName = shareParams.pageName;
        shareRouter.goodId = shareParams.goodId;
        shareRouter.id = new Date().getTime();
      }
    } catch (e) {
      UtilLog.error(JSON.stringify(e))
    }
  }

  onShare(wantParams: Record<string, Object>) {
    // 指定页面支持分享按钮点击事件
    let currentName: string[] = RouterModule.getStack().getAllPathName()
    let showShareMenu = false
    if (currentName.length && RouterModule.SHARE_PAGES.includes(currentName[currentName.length-1])) {
      showShareMenu = true
    }
    // 分享方：从临时缓存中获取自定义参数来设置want
    const instance = AppStorageV2.connect(CustomShareParams, () => new CustomShareParams())!;
    const pageParams: CustomShareParams = {
      id: instance.id,
      pageName: instance.pageName,
      goodId: instance.goodId,
      goodName: instance.goodName,
    }

    const shareParams: ShareInfo = {
      showShareMenu,
      title: pageParams.goodName,
      description: pageParams.goodName,
      parameters: pageParams,
    };
    wantParams['atomicservice.param.key.shareInfo'] = shareParams;
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.handleShare(want);
    AppStorage.setOrCreate('context', this.context);
    UtilLog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    this.setWantParam(want);
  }

  setWantParam(want: Want) {
    if (want?.parameters?.params) {
      // want.parameters.params 对应 postCardAction() 中 params 内容
      try {
        let params: Record<string, Object> = JSON.parse(want.parameters.params as string);
        this.pageIndex = params.index as number;
        PageUtil.setPageInfo(this.pageIndex);
      } catch (paramError) {
        UtilLog.error(0x0000, 'testTag', 'Succeeded in get params.');
      }
    }
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.handleShare(want);
    this.setWantParam(want);
    if (this.currentWindowStage !== null) {
      this.onWindowStageCreate(this.currentWindowStage);
    }
  }

  onDestroy(): void {
    UtilLog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  monitorWindowSizeChange(windowStage: window.WindowStage) {
    let windowClass: window.Window | undefined = undefined;
    try {
      window.getLastWindow(this.context, (err, data) => {
        const errCode: number = err.code;
        if (errCode) {
          UtilLog.error(0x0000, 'testTag', 'Failed to obtain the top window. Cause: ' + err.message);
          return;
        }
        windowClass = data;
        this._windowSize.width =
          windowStage.getMainWindowSync().getUIContext().px2vp(windowClass.getWindowProperties().windowRect.width);
        try {
          windowClass.on('windowSizeChange', (data) => {
            this._windowSize.width = windowStage.getMainWindowSync().getUIContext().px2vp(data.width);
            this._windowSize.height = windowStage.getMainWindowSync().getUIContext().px2vp(data.height);
          });
        } catch (exception) {
          UtilLog.error(0x0000, 'testTag',
            'Failed to enable the listener for window size changes. Cause: ' + exception.message);
        }
        UtilLog.info(0x0000, 'testTag', 'Succeeded in obtaining the top window. Data: ' + data.toString());
      });
    } catch (exception) {
      UtilLog.error(0x0000, 'testTag', 'Failed to obtain the top window. Cause: ' + exception.message);
    }
  }

  async getWindowAvoidArea(windowStage: window.WindowStage) {
    let windowClass: window.Window = windowStage.getMainWindowSync(); // 获取应用主窗口
    await windowClass.setWindowLayoutFullScreen(true);
    let type = window.AvoidAreaType.TYPE_SYSTEM; // 以状态栏避让为例
    let avoidArea = windowClass.getWindowAvoidArea(type);
    let windowTopHeight = windowStage.getMainWindowSync().getUIContext().px2vp(avoidArea.topRect.height);
    AppStorage.setOrCreate('windowTopHeight', windowTopHeight);
    type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR; // 以导航条避让为例
    avoidArea = windowClass.getWindowAvoidArea(type);
    let windowBottomHeight = windowStage.getMainWindowSync().getUIContext().px2vp(avoidArea.bottomRect.height);
    AppStorage.setOrCreate('windowBottomHeight', windowBottomHeight);
  }


  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    // Main window is created, set main page for this ability
    UIBase.init(windowStage);
    UtilLog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      this.monitorWindowSizeChange(windowStage);
      this.getWindowAvoidArea(windowStage);
      if (err.code) {
        UtilLog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      UtilLog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    UtilLog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    UtilLog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    UtilLog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
};
