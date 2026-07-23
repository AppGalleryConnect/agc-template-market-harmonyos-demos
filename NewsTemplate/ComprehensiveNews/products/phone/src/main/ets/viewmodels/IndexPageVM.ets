import { AppStorageV2 } from '@kit.ArkUI';
import { HdsTabsController } from '@kit.UIDesignKit';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { emitter } from '@kit.BasicServicesKit';
import {
  BaseViewModel,
  ContinueModel,
  EventEnum,
  RouterMap,
  RouterParams,
  RouterToNews,
  RouterUtils,
  ShortcutKey,
  TabBarType,
  VideoType,
} from 'lib_common';
import { AccountApi } from 'lib_account';
import { BaseNewsServiceApi } from 'lib_news_api';
import { EventMap } from 'module_audioplayer';
import { AppLinkingRouter, FormCardRouter, ShortcutRouter } from '../common/Types';
import { NEWS_DETAIL_PAGE } from '../common/Constants';

@ObservedV2
export class IndexPageViewModel extends BaseViewModel {
  @Trace translateY: string | number = '';
  @Trace firstBackTime: number = 0;
  @Trace formCardModel: FormCardRouter = AppStorageV2.connect(FormCardRouter, () => new FormCardRouter())!;
  @Trace appLinkRouter: AppLinkingRouter = AppStorageV2.connect(AppLinkingRouter, () => new AppLinkingRouter())!;
  @Trace shortcutRouter: ShortcutRouter = AppStorageV2.connect(ShortcutRouter, () => new ShortcutRouter())!;
  @Trace continueModel: ContinueModel = AppStorageV2.connect(ContinueModel, () => new ContinueModel())!;
  @Trace assignedVideoTabIndex: number = VideoType.CHOICE;
  controller: HdsTabsController = new HdsTabsController();
  private changeTabIndex: (index: number) => void = () => {
  };

  @Monitor('tabModel.showTabBar')
  onChangeShowTabBar(monitor: IMonitor) {
    const isShowCustomTabBar = monitor.value()?.now as boolean;
    if (isShowCustomTabBar) {
      this.translateY = '';
    } else {
      this.translateY = '100%';
    }
  }

  @Monitor('tabModel.isTabVertical')
  onShowChangeTabBar(monitor: IMonitor) {
    const isShowCustomTabBar = monitor.value()?.now as boolean
    if (isShowCustomTabBar) {
      this.translateY = '';
      this.tabModel.showTabBar = true;
    }
  }

  @Monitor('formCardModel.id')
  onFormCardClick() {
    this.checkJumpNewsDetail();
  }

  @Monitor('continueModel.id')
  onContinueSceneChange() {
    this.checkContinueScene();
  }

  @Monitor('appLinkRouter.id')
  onAppLinkingClick() {
    this.checkAppLinkingScene();
  }

  @Monitor('shortcutRouter.pageName')
  onShortcutClick() {
    this.checkShortcutScene();
  }

  setTabChangeFunc(func: (index: number) => void) {
    this.changeTabIndex = func;
  }

  refreshUserInfo() {
    new AccountApi().queryUserInfo();
  }

  private subWindowCallback = (eventData: emitter.GenericEventData<string>): void => {
    const params: Record<string, string | boolean | undefined> = {
      'avId': eventData?.data,
      'subWindow': true,
      'isCreateSubWindow': true,
    }
    RouterUtils.pushPathByName(RouterMap.AUDIO_DETAILS, params)
  }

  registerSubEmitter() {
    emitter.off(EventMap.ON_SUB_WINDOW, this.subWindowCallback);
    emitter.on(EventMap.ON_SUB_WINDOW, this.subWindowCallback);
  }

  unregisterSubEmitter() {
    emitter.off(EventMap.ON_SUB_WINDOW, this.subWindowCallback);
  }

  backToHomePage() {
    const currentPage = RouterUtils.getStack().getAllPathName().pop();
    if (currentPage !== RouterMap.INDEX_PAGE) {
      RouterUtils.popToName(RouterMap.INDEX_PAGE, undefined, false);
    }
  }

  checkJumpNewsDetail() {
    if (this.formCardModel.id && this.formCardModel.newsId && this.formCardModel.pageUrl === NEWS_DETAIL_PAGE) {
      this.backToHomePage();
      const routerParams: RouterParams<null> = {
        'type': this.formCardModel.newsType,
        'newsId': this.formCardModel.newsId,
      };
      RouterToNews.pushToNewsDetails(routerParams);
      this.formCardModel.id = 0;
    }
  }

  async checkContinueScene() {
    if (this.continueModel.id && this.continueModel.newsId) {
      const news = await BaseNewsServiceApi.queryNews(this.continueModel.newsId);
      if (!news) {
        this.continueModel.id = 0;
        this.contextModel.showToast({ message: '新闻内容不存在，无法流转' });
        return;
      }
      this.backToHomePage();
      const routerParams: RouterParams<null> = {
        'type': this.continueModel.newsType,
        'newsId': this.continueModel.newsId,
      };
      RouterToNews.pushToNewsDetails(routerParams);
      this.continueModel.id = 0;
    }
  }

  checkAppLinkingScene() {
    if (this.appLinkRouter.id && this.appLinkRouter.newsId) {
      this.backToHomePage();
      const routerParams: RouterParams<null> = {
        newsId: this.appLinkRouter.newsId,
        type: this.appLinkRouter.newsType,
      };
      RouterToNews.pushToNewsDetails(routerParams);
      this.appLinkRouter.id = 0;
    }
  }

  checkShortcutScene() {
    if (this.shortcutRouter.pageName) {
      this.backToHomePage();
      switch (this.shortcutRouter.pageName) {
        case ShortcutKey.TV:
          // 针对视频页面未初始化的场景
          this.assignedVideoTabIndex = VideoType.TELEVISION;
          // 切换到视频Tab
          this.changeTabIndex(TabBarType.VIDEO);
          // 处理视频页面已经初始化的场景
          emitter.emit(EventEnum.VIDEO_TAB_CHANGE, { data: { pageName: ShortcutKey.TV } });
          break;
        case ShortcutKey.AUDIO:
          this.assignedVideoTabIndex = VideoType.BROADCAST;
          this.changeTabIndex(TabBarType.VIDEO);
          emitter.emit(EventEnum.VIDEO_TAB_CHANGE, { data: { pageName: ShortcutKey.AUDIO } });
          break;
        case ShortcutKey.DIGITAL_NEWS:
          RouterUtils.pushPathByName(RouterMap.DIGITAL_NEWSPAPER, null, undefined, false);
          break;
      }
      this.shortcutRouter.pageName = '';
    }
  }

  onBackPressed() {
    // 视频tab，返回前要重置showTabBar状态
    if (this.tabModel.selectedIndex === TabBarType.VIDEO) {
      if (this.videoExtraInfoModel.isDisplayChange) {
        this.videoExtraInfoModel.isDisplayChange = false;
        return true;
      }
      this.tabModel.showTabBar = true;
    }
    const nowTime = Date.now();
    if (nowTime - this.firstBackTime < 1500) {
      return false;
    } else {
      this.firstBackTime = nowTime;
      this.contextModel.showToast({ message: '再按一次退出' });
      return true;
    }
  }

  // 存在隐藏Tab的场景
  @Computed
  get hideTabScene() {
    return this.tabModel.selectedIndex === TabBarType.VIDEO &&
      [VideoType.FOLLOW, VideoType.CHOICE].includes(this.tabModel.videoCurrentTabIndex);
  }

  setHdsTabColor() {
    const actualColorMode = this.settingInfo.getColorModeByName(this.settingInfo.colorModeName);
    const darkBar = this.tabModel.selectedIndex === 1 &&
      [VideoType.FOLLOW, VideoType.CHOICE].includes(this.tabModel.videoCurrentTabIndex);
    const isDarkEnable =
      darkBar || this.settingInfo.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK ? true : false;
    this.contextModel.globalContext.getApplicationContext()
      .setColorMode(isDarkEnable ? ConfigurationConstant.ColorMode.COLOR_MODE_DARK : actualColorMode);
  }

  @Computed
  get pageBgColor(): ResourceColor {
    if (this.hideTabScene) {
      return Color.Black;
    }
    return $r('sys.color.background_secondary');
  }

  @Computed
  get tabBarHeight() {
    return this.tabModel.showTabBar ? 56 : 0;
  }
}