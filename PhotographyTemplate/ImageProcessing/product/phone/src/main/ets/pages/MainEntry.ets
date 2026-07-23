import { CommonConstants } from 'commonlib';
import { MainEntryVM } from '../viewmodels/MainEntryVM';
import { TabListItem } from '../models/Types';


@Builder
export function MainEntryBuilder() {
  MainEntry();
}

@ComponentV2
struct MainEntry {
  @Local vm: MainEntryVM = new MainEntryVM();

  aboutToAppear(): void {
    if (this.vm.formModel.formCardId) {
      setTimeout(() => {
        this.vm.jumpToFormCardPage();
      }, 50)
    }
  }

  aboutToDisappear(): void {
    this.vm.offEvent();
  }

  build() {
    NavDestination() {
      Column() {
        Tabs({ barPosition: BarPosition.End, index: $$this.vm.curIndex }) {
          ForEach(this.vm.tabList, (item: TabListItem, index: number) => {
            TabContent() {
              item.component.builder();
            }
            .tabBar(this.tabBarBuilder(item, index))
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
          }, (item: TabListItem) => JSON.stringify(item));
        }
        .width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)
        .scrollable(false)
        .animationDuration(0)
        .vertical(this.vm.isTabVertical)
        .barPosition(this.vm.barPosition)
        .barWidth(this.vm.tabWidth)
        .barHeight(this.vm.tabHeight)
        .clip(true)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .hideTitleBar(true)
  }

  @Builder
  tabBarBuilder(item: TabListItem, index: number) {
    Column({ space: CommonConstants.SPACE_XXS }) {
      Image(this.vm.curIndex === index ? item.iconChecked : item.icon)
        .width($r('app.float.vp_24'))
        .height($r('app.float.vp_24'))
      Text(item.label)
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Caption_M'))
        .fontColor(this.vm.curIndex === index ?
          $r('sys.color.multi_color_01') : $r('sys.color.icon_secondary'));
    }
    .width(CommonConstants.FULL_PERCENT)
  }
}