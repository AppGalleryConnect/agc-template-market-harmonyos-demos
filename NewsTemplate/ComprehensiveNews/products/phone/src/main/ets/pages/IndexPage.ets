import { hdsMaterial } from '@kit.UIDesignKit';
import { HdsTabs } from '@hms.hds.hdsBaseComponent';
import { CommonConstants } from 'lib_common';
import { HomePageBuilder } from 'business_home';
import { MinePageBuilder } from 'business_mine';
import { VideoPageBuilder } from 'business_video';
import { InteractionPageBuilder } from 'business_interaction';
import { CustomTabBar } from '../components/CustomTabBar';
import { IndexPageViewModel } from '../viewmodels/IndexPageVM';
import { TabBarItem, TABS_INFO } from '../common/Constants';

@Builder
export function IndexPageBuilder() {
  IndexPage()
}

@ComponentV2
struct IndexPage {
  @Local vm: IndexPageViewModel = new IndexPageViewModel();
  @Provider() selectedIndex: number = 0;

  aboutToAppear(): void {
    this.vm.setTabChangeFunc(this.changeTab);
    this.vm.refreshUserInfo();
    this.vm.checkJumpNewsDetail();
    this.vm.checkContinueScene();
    this.vm.checkAppLinkingScene();
    this.vm.checkShortcutScene();
    this.vm.registerSubEmitter();
  }

  aboutToDisappear(): void {
    this.vm.unregisterSubEmitter();
  }

  @Monitor('selectedIndex')
  onChangeTabIndex() {
    this.vm.tabModel.selectedIndex = this.selectedIndex;
  }

  changeTab: (index: number) => void = (index) => {
    this.selectedIndex = index;
  }

  build() {
    NavDestination() {
      Column() {
        HdsTabs({
          barPosition: BarPosition.End,
          index: this.selectedIndex,
          controller: this.vm.controller,
        }) {
          TabContent() {
            HomePageBuilder()
          }
          .tabBar(this.tabBuilder(TABS_INFO[0]))

          TabContent() {
            VideoPageBuilder(this.vm.assignedVideoTabIndex)
          }
          .tabBar(this.tabBuilder(TABS_INFO[1]))

          TabContent() {
            InteractionPageBuilder()
          }
          .tabBar(this.tabBuilder(TABS_INFO[2]))

          TabContent() {
            MinePageBuilder()
          }
          .tabBar(this.tabBuilder(TABS_INFO[3]))
        }
        .barHeight(this.vm.tabBarHeight)
        .barOverlap(true)
        .scrollable(false)
        .animationDuration(0)
        .barFloatingStyle({
          barBottomMargin: 28, // 距离屏幕底部的边距
          adaptToHandedness: true,
          gradientMask: { maskColor: Color.Transparent },
          systemMaterialEffect: {
            materialType: hdsMaterial.MaterialType.ADAPTIVE, // 启用沉浸光感材质
            materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE // 悬浮页签自定义沉浸光感材质效果
          }
        })
        .onChange((index) => {
          this.selectedIndex = index;
        })
      }
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
      .backgroundColor(this.vm.pageBgColor)
    }
    .onWillShow(() => {
      this.vm.setHdsTabColor()
    })
    .onWillHide(() => {
      const actualColorMode = this.vm.settingInfo.getColorModeByName(this.vm.settingInfo.colorModeName);
      this.vm.contextModel.globalContext.getApplicationContext()
        .setColorMode(actualColorMode)
    })
    .hideTitleBar(true)
    .onBackPressed(() => {
      return this.vm.onBackPressed();
    })
  }

  @Builder
  tabBuilder(item: TabBarItem) {
    CustomTabBar({ item: item })
      .translate({ x: 0, y: this.vm.translateY })
      .animation({ duration: 200, curve: Curve.EaseInOut })
      .onAreaChange((_ov: Area, nv: Area) => {
        this.vm.tabModel.tabHeight = nv.height
      })
  }
}
