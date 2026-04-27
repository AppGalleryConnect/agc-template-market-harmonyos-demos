import { UtilLog } from '@hw-agconnect/util-log';
import { BreakpointSystem } from 'lib_foundation';
import { TAB_LIST } from '../commons/Constants';
import { TabListItem } from '../commons/Types';
import { MainEntryVM } from '../viewmodels/MainEntryVM';

@Builder
export function MainEntryBuilder() {
  MainEntry()
}

@ComponentV2
struct MainEntry {
  vm: MainEntryVM = new MainEntryVM();
  private controller: TabsController = new TabsController();

  aboutToAppear(): void {
    this.vm.initData();
  }

  build() {
    NavDestination() {
      Tabs({
        barPosition: BreakpointSystem.isTablet ? BarPosition.Start : BarPosition.End,
        index: this.vm.curIndex,
        controller: this.controller,
      }) {
        ForEach(TAB_LIST, (item: TabListItem, index: number) => {
          TabContent() {
            item.component.builder();
          }
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
          .tabBar(this.tabBarBuilder(item, index))
          .clip(false)
        }, (item: TabListItem, index: number) => index + '__' + item.label);
      }
      .scrollable(false)
      .height($r('app.string.size_percent_full'))
      .animationDuration(0)
      .divider({ strokeWidth: '1px' })
      .barMode(BreakpointSystem.isTablet ? BarMode.Scrollable : BarMode.Fixed)
      .vertical(BreakpointSystem.isTablet)
      .barWidth(BreakpointSystem.isTablet ? 96 : '100%')
      .onChange((index: number) => {
        this.vm.curIndex = index;
      })
      .expandSafeArea([SafeAreaType.SYSTEM],
        [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP, SafeAreaEdge.START, SafeAreaEdge.END])
      .barOverlap(!BreakpointSystem.isTablet)
    }
    .hideTitleBar(true)
    .backgroundColor(BreakpointSystem.isTablet ?
      $r('app.color.background_color_grey') :
      $r('app.color.background_color_transparent'))
    .onBackPressed(() => {
      let nowTime = Date.now();
      if (nowTime - this.vm.firstBackTime < 1500) {
        return false;
      } else {
        this.vm.firstBackTime = nowTime;
        try {
          this.getUIContext().getPromptAction().showToast({ message: '再按一次退出' })
        } catch (error) {
          UtilLog.error('interrupt back to desk error.')
          return false
        }
        return true;
      }
    })
    .onShown(() => {
    })
    .onHidden(() => {
    })
  }

  @Builder
  tabBarBuilder(item: TabListItem, index: number) {
    Column() {
      Image(this.vm.curIndex === index ? item.iconChecked : item.icon)
        .fillColor(this.vm.curIndex === index ? $r('app.color.theme_color') : $r('app.color.font_color_level3'))
        .width(24)
        .height(24);
      Text(item.label)
        .fontColor(this.vm.curIndex === index ? $r('app.color.theme_color') :
          $r('app.color.font_color_level3'))
        .fontSize($r('app.float.font_size_10'))
        .margin({ top: $r('app.float.space_xs') });
    }
    .width($r('app.string.size_percent_full'))
    .height(BreakpointSystem.isTablet ? 100 : undefined)
  }
}