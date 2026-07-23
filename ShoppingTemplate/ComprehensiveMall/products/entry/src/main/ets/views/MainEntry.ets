import { hdsMaterial } from '@kit.UIDesignKit';
import { HdsTabs, HdsTabsController } from '@hms.hds.hdsBaseComponent';
import { UtilLog } from '@hw-agconnect/util-log';
import { BreakpointSystem, MotionUtil } from 'lib_foundation';
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
  private controller: HdsTabsController = new HdsTabsController();

  aboutToAppear(): void {
    this.vm.initData();
  }

  build() {
    NavDestination() {
      HdsTabs({
        barPosition: BarPosition.End,
        index: this.vm.curIndex,
        controller: this.controller,
      }) {
        ForEach(TAB_LIST, (item: TabListItem, index: number) => {
          TabContent() {
            item.component.builder();
          }
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          .tabBar(this.tabBarBuilder(item, index))
          .backgroundColor(Color.Transparent)
          .clip(false)
        }, (item: TabListItem, index: number) => index + '__' + item.label);
      }
      .scrollable(false)
      .barOverlap(true)
      .height($r('app.string.size_percent_full'))
      .animationDuration(0)
      .barHeight(56)
      .barFloatingStyle({
        adaptToHandedness: true,
        systemMaterialEffect: {
          materialType: hdsMaterial.MaterialType.ADAPTIVE,
          materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
        }
      })
      .onChange((index: number) => {
        this.vm.curIndex = index;
      })
      .expandSafeArea([SafeAreaType.SYSTEM],
        [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP, SafeAreaEdge.START, SafeAreaEdge.END])
    }
    .height($r('app.string.size_percent_full'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .hideTitleBar(true)
    .backgroundColor(
      BreakpointSystem.isTablet ? $r('app.color.background_color_grey') : $r('app.color.background_color_transparent'))
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
      MotionUtil.registerHoldingHandEvent()
    })
    .onHidden(() => {
      MotionUtil.unregisterHoldingHandEvent()
    })
  }

  @Builder
  tabBarBuilder(item: TabListItem, index: number) {
    Column() {
      SymbolGlyph(item.icon)
        .fontSize(24)
        .fontColor(this.vm.curIndex === index ? [$r('sys.color.multi_color_07')] : [$r('sys.color.icon_primary')])
      Text(item.label)
        .fontColor(this.vm.curIndex === index ? $r('sys.color.multi_color_07') : $r('sys.color.font_primary'))
        .fontSize($r('sys.float.Caption_M'))
        .fontWeight(FontWeight.Medium)
        .margin({ top: $r('app.float.space_xxs') });
    }
    .justifyContent(FlexAlign.Center)
    .width($r('app.string.size_percent_full'))
    .padding(4)
  }
}