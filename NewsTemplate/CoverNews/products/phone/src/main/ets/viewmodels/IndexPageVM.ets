import { common } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import {
  BaseViewModel,
  CommonConstants,
  Logger,
  RouterMap,
  RouterUtils,
  NewsDetailRouter,
} from 'lib_common';
import { TabBarType } from '../models/TabModel';

const TAG = '[IndexPageVM]';

@ObservedV2
export class IndexPageVM extends BaseViewModel {
  @Trace selectedIndex: number = 0;
  @Trace tabController: TabsController = new TabsController();
  @Trace newsDetailRouter: NewsDetailRouter = AppStorageV2.connect(NewsDetailRouter, () => new NewsDetailRouter())!;
  public uiContext: UIContext | undefined = undefined;

  @Monitor('newsDetailRouter.id')
  onJumpNewsDetail() {
    if (this.newsDetailRouter.id && this.newsDetailRouter.newsId) {
      this.backToHomePage();
      RouterUtils.pushPathByName(RouterMap.NEWS_DETAIL_PAGE, this.newsDetailRouter.newsId)
      this.newsDetailRouter.id = 0;
    }
  }

  @Monitor('breakPointModel.currentBreakpoint')
  onBreakPointChange() {
    const currentPage = RouterUtils.getStack().getAllPathName().pop();
    if (currentPage === RouterMap.INDEX_PAGE) {
      this.setWindowFullScreen(this.breakPointModel.isTabVertical)
    }
  }

  backToHomePage() {
    const currentPage = RouterUtils.getStack().getAllPathName().pop();
    if (currentPage !== RouterMap.INDEX_PAGE) {
      RouterUtils.popToName(RouterMap.INDEX_PAGE, undefined, false);
    }
  }

  setUIContext(uiContext: UIContext) {
    this.uiContext = uiContext;
  }

  async setWindowFullScreen(isFull: boolean) {
    try {
      const uiAbilityContext = (this.uiContext?.getHostContext() as common.UIAbilityContext)
      await uiAbilityContext.windowStage.getMainWindowSync().setWindowLayoutFullScreen(isFull)
    } catch (error) {
      Logger.error(TAG, `Failed to setWindowLayoutFullScreen, error: ${JSON.stringify(error)}`);
    }
  }

  @Computed
  get showDivider(): DividerStyle | null {
    if (!this.breakPointModel.isTabVertical) {
      return null;
    }
    if ([TabBarType.HOME].includes(this.selectedIndex)) {
      return null;
    }
    return {
      strokeWidth: '1px',
      color: $r('sys.color.comp_divider'),
      startMargin: 0,
      endMargin: 0,
    } as DividerStyle
  }



  @Computed
  get barPosition() {
    if (this.breakPointModel.isTabVertical) {
      return BarPosition.Start;
    }
    return BarPosition.End;
  }

  @Computed
  get tabWidth(): Length {
    if (this.breakPointModel.isTabVertical) {
      return CommonConstants.LEFT_TAB_BAR_WIDTH;
    }
    return CommonConstants.FULL_PERCENT;
  }

  @Computed
  get tabHeight(): Length {
    if (this.breakPointModel.isTabVertical) {
      return CommonConstants.LEFT_TAB_BAR_ITEM_HEIGHT * 2;
    }
    return CommonConstants.BOTTOM_TAB_BAR_HEIGHT;
  }
}