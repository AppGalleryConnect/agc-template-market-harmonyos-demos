import {
  BreakpointStorage,
  BreakpointSystem,
  BreakpointTypeEnum,
  MinorsMode,
  MinorsProtectionUtils,
  TabInfo
} from 'common';
import { UserInfo, fp2pxUtil } from 'base_common';
import { IndexData } from '../model/MainTab';
import { AppStorageV2 } from '@kit.ArkUI';
import { notificationManager } from '@kit.NotificationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';

@ComponentV2
export struct BookHomePage {
  @Provider('isDeleteShelf') isDeleteShelf: boolean = false;
  @Provider('currentIndexTab') currentIndexTab: number = 0;
  @Provider('tabController') tabsController: TabsController = new TabsController();
  @Provider('isHistory') isHistory: boolean = false
  @Provider('userInfo') userInfo: UserInfo | undefined = undefined;
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  @Local minorsMode: MinorsMode =
    AppStorageV2.connect(MinorsMode, 'isMinorsMode', () => new MinorsMode(MinorsProtectionUtils.getMinorsMode()))!

  aboutToAppear(): void {
    MinorsProtectionUtils.createSubscriber();
    let context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
    notificationManager.requestEnableNotification(context).then(() => {
      hilog.info(0x0000, 'testTag', `[ANS] requestEnableNotification success`);
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, 'testTag',
        `[ANS] requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
    });
  }

  @Builder
  tabBuilder(title: string, index: number, selectedImg: Resource, normalImg: Resource) {
    Column() {
      SymbolGlyph(selectedImg)
        .fontSize(fp2pxUtil(24))
        .fontColor(this.currentIndexTab === index ? [$r('app.color.font_overdue')] :
          [$r('sys.color.icon_secondary')])
      Text(title)
        .margin({ top: 4 })
        .fontSize(fp2pxUtil(10))
        .fontColor(this.currentIndexTab === index ? $r('app.color.font_overdue') : $r('app.color.tab_color_default'))
    }
    .justifyContent(FlexAlign.Center)
    .height(this.isTablet ? 100 : undefined)
    .width('100%')
    .onClick(() => {
      this.currentIndexTab = index;
      this.tabsController.changeIndex(this.currentIndexTab);
    })

  }

  @Computed
  get isTablet() {
    return BreakpointSystem.currentBreakpoint.value === BreakpointTypeEnum.LG
  }

  build() {
    NavDestination() {
      Tabs({
        barPosition: this.curBreakpoint.value === BreakpointTypeEnum.LG ? BarPosition.Start : BarPosition.End,
        index: this.currentIndexTab,
        controller: this.tabsController
      }) {
        ForEach(this.minorsMode.isMinorsMode ? IndexData.MINOR_TAB : IndexData.MAIN_TAB, (item: TabInfo) => {
          TabContent() {
            item.component?.builder();
          }
          .tabBar(this.tabBuilder(item.label, item.index, item.activeIcon, item.defaultIcon))
        }, (item: TabInfo) => item.index.toString()+item.label)
      }
      .clip(false)
      .height('100%')
      .backgroundColor($r('sys.color.background_secondary'))
      .padding({ bottom: 18 })
      .animationDuration(0)
      .scrollable(false)
      .barMode(this.isTablet ? BarMode.Scrollable : BarMode.Fixed)
      .vertical(this.isTablet)
      .barWidth(this.isTablet ? 96 : '100%')
      .barHeight(this.isDeleteShelf ? 0 : 'auto')
      .onAnimationStart((targetIndex: number) => {
        this.currentIndexTab = targetIndex;
      })
    }
    .onWillShow(() => {
      if (AppStorage.has('userInfo')) {
        this.userInfo = AppStorage.get('userInfo') as UserInfo;
      }
    })
    .hideTitleBar(true)
  }
}