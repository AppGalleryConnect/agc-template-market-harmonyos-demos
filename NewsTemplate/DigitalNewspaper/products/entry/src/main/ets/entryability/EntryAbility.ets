import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { UtilLog } from '@hw-agconnect/util-log';
import { CustomShareParams, RouterModule, ShareInfo } from 'lib_foundation';
import { FormCardRouter } from '../widget/common/Types';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    UtilLog.setGlobalConfig({
      tag: 'DigitalNewsPaper', // 指定日志标识
      domain: 0xff00, // 日志对应的领域标识
      open: true,
      showStack: false,
    })
    this.handleShare(want);
    this.handleFormCardCall(want);
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onNewWant');
    this.handleShare(want);
    this.handleFormCardCall(want);
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
      this.setColorMode();
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }


  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }

  setColorMode() {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (error) {
      UtilLog.error('setColorMode', `Failed to set color mode. Code is ${error.code}, message is ${error.message}`);
    }
  }

  onShare(wantParams: Record<string, Object>) {
    // 指定页面支持分享按钮点击事件
    let currentName: string[] = RouterModule.getStack().getAllPathName();
    let showShareMenu = false;
    if (currentName.length && ['Main', 'NewsDetail'].includes(currentName[currentName.length - 1])) {
      showShareMenu = true;
    }
    const shareParams: ShareInfo = {
      showShareMenu: showShareMenu,
      title: '数字报元服务分享',
      description: '数字报元服务分享',
      parameters: {} as CustomShareParams,
    };
    // 分享方：从临时缓存中获取自定义参数来设置want
    const instance = AppStorageV2.connect(CustomShareParams, 'shareInstance', () => new CustomShareParams())!;
    if (instance.newsId || instance.sourceId) {
      const pageParams: CustomShareParams = {
        id: instance.id,
        pageName: instance.pageName,
        newspaperId: instance.newspaperId,
        sourceId: instance.sourceId,
        sourceName: instance.sourceName,
        newsId: instance.newsId,
        newsTitle: instance.newsTitle,
      }
      shareParams.title = instance.newsId ? pageParams.newsTitle : pageParams.sourceName;
      shareParams.description = instance.newsId ? pageParams.newsTitle : pageParams.sourceName;
      ;
      shareParams.parameters = pageParams;
    }

    wantParams['atomicservice.param.key.shareInfo'] = shareParams;
  }

  handleShare(want: Want) {
    // 接收方：从want中获取自定义参数，用于后续实现页面的路由跳转
    const paramStr = want?.parameters?.custShareParam as string;
    const shareParams: CustomShareParams = JSON.parse(paramStr || '{}');
    const shareRouter: CustomShareParams =
      AppStorageV2.connect(CustomShareParams, 'handleShare', () => new CustomShareParams())!;
    shareRouter.id = new Date().getTime();
    shareRouter.pageName = '';
    shareRouter.newsId = '';
    if (shareParams?.newsId || shareParams?.sourceId) {
      shareRouter.pageName = shareParams.pageName;
      shareRouter.newsId = shareParams.newsId;
      shareRouter.sourceId = shareParams.sourceId;
      shareRouter.sourceName = shareParams.sourceName;
      shareRouter.newspaperId = shareParams.newspaperId;
    }
  }

  handleFormCardCall(want: Want) {
    if (want?.parameters?.source === 'FormCard') {
      const formCardRouter: FormCardRouter =
        AppStorageV2.connect(FormCardRouter, () => new FormCardRouter())!;
      formCardRouter.id = new Date().getTime();
      formCardRouter.pageUrl = want?.parameters?.pageUrl as string ?? '';
      formCardRouter.newsId = want?.parameters?.newsId as string ?? '';
      formCardRouter.newsTitle = want?.parameters?.newsTitle as string ?? '';
    }
  }
}
