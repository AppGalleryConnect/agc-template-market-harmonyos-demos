import { MediaService } from 'audio';
import { Constant } from 'common';
import { TABS_INFO, TabBarData } from '../model/TabBarInfo';
import { MainEntryVM } from '../viewmodel/MainEntryVM';
import { PageUtil } from 'common';
import { OrderPageVM } from 'order';

@Entry
@ComponentV2
struct Main {
  orderVm: OrderPageVM = OrderPageVM.instance;
  vm: MainEntryVM = MainEntryVM.instance;
  @Provider('homeTabIndex') homeTabIndex: number = 0;
  @Provider('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;

  aboutToAppear() {
    this.vm.init();
  }

  onPageShow(): void {
    let pageInfo = PageUtil.getPageInfo();
    if (pageInfo.index !== 0) {
      this.homeTabIndex = pageInfo.index;
    }
  }

  @Builder
  mainTabBar(title: ResourceStr, targetIndex: number, selectedImg: ResourceStr, normalImg: ResourceStr) {
    Column({ space: 4 }) {
      Image(this.homeTabIndex === targetIndex ? selectedImg : normalImg)
        .size({ width: 24, height: 24 });
      Text(title)
        .fontSize(10)
        .fontColor(this.homeTabIndex === targetIndex ? '#64BB5C' :
        Color.Black)
        .opacity(this.homeTabIndex === targetIndex ? 1 : 0.6);
    }.onClick(() => {
      this.homeTabIndex = targetIndex;
    })
    .width(Constant.FULL_PERCENT)
    .justifyContent(FlexAlign.Center);
  }

  build() {
    Navigation(this.mainPathStack) {
      Tabs({ index: this.homeTabIndex }) {
        ForEach(TABS_INFO, (item: TabBarData) => {
          TabContent() {
            item.component.builder();
          }.tabBar(this.mainTabBar(item.title, item.id, item.activeIcon, item.defaultIcon));
        }, (item: TabBarData) => JSON.stringify(item));
      }
      .padding({ bottom: this.windowBottomHeight })
      .scrollable(false)
      .animationDuration(0)
      .barPosition(BarPosition.End)
      .onChange(() => {
        if (this.homeTabIndex === 3) {
          this.orderVm.getOrderList();
        }
        MediaService.getInstance().releaseAvPlayer();
      });
    }.hideTitleBar(true);
  }
}