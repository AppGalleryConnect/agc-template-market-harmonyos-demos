import { CITY_LIST, CityItem, MainEntryVM, TitleTop } from '@ohos_agcit/postpartum_care_center_uicomponents';
import { StoreList } from '../view/StoreList';

@Entry
@Preview
@ComponentV2
export struct Stores {
  vm: MainEntryVM = MainEntryVM.instance;
  @Local currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();

  @Builder
  tabBarBuilder(title: string, targetIndex: number) {
    Column() {
      Text(title)
        .fontFamily('HarmonyHeiTi')
        .fontWeight(this.currentIndex === targetIndex ? FontWeight.Bold : FontWeight.Regular)
        .fontSize($r('app.string.font_size_14'))
        .fontColor(this.currentIndex === targetIndex ? 'rgba(0,0,0,0.90)' : 'rgba(0,0,0,0.60)')
        .margin({ bottom: $r('app.string.margin_9') });
      Divider()
        .width(28)
        .strokeWidth(2)
        .color(this.currentIndex === targetIndex ? '#000000' : 'transparent')
        .opacity(this.currentIndex === targetIndex ? 1 : 0);
    }
    .margin(targetIndex === 0 ?
      {
        left: $r('app.string.margin_ms'),
        right: $r('app.string.margin_s'),
      } :
      {
        left: $r('app.string.margin_s'),
        right: $r('app.string.margin_s'),
      },
    )
    .padding({ top: $r('app.string.padding_14'), bottom: $r('app.string.padding_4') })
    .height(48)
    .onClick(() => {
      this.currentIndex = targetIndex;
      this.tabsController.changeIndex(targetIndex); // 切换页签 页签在Tabs里的索引值，索引值从0开始。
    });
  }

  build() {
    Column() {
      TitleTop({ title: $r('app.string.title_store') })
        .margin({ bottom: $r('app.string.margin_xs') });
      Tabs({ barPosition: BarPosition.Start, controller: this.tabsController }) {
        ForEach(CITY_LIST, (item: CityItem) => {
          TabContent() {
            StoreList({ cityName: item.name });
          }
          .tabBar(this.tabBarBuilder(item.name, item.id));
        }, (item: string) => JSON.stringify(item));
      }
      .vertical(false)
      .barWidth('100%') //横向Tabs的barWidth的宽度
      .barMode(BarMode.Scrollable)
      .backgroundColor('#F1F3F5')
      .scrollable(false)
      .layoutWeight(1);
    }
    .backgroundColor('#F1F3F5')
    .clip(false)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
  }
}