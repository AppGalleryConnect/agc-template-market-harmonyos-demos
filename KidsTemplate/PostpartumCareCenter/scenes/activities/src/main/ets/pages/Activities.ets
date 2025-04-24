import { CITY_LIST, CityItem, TitleTop, ACTIVITY_TYPE_LIST,
  ActivityTypeItem,
  CITY_LIST_ACTIVITY} from '@ohos_agcit/postpartum_care_center_uicomponents';
import { Logger } from '@ohos_agcit/postpartum_care_center_utils';
import { ActivityList } from '../view/ActivityList';
import { ActivityEntryVM } from '../viewmodel/ActivityEntryVM';


const TAG: string = 'ActivitiesEntry';

@Entry
@Preview
@ComponentV2
export struct Activities {
  vm: ActivityEntryVM = ActivityEntryVM.instance;
  @Local outerCurrentIndex: number = 0;
  @Local innerCurrentIndex: number = 0;
  private outerTabsController: TabsController = new TabsController();
  private innerTabsController: TabsController = new TabsController();

  async aboutToAppear() {
    Logger.info(TAG, '%{public}s', 'aboutToAppear');
    await this.vm.init();
  }

  @Builder
  outerTabBarBuilder(title: string, targetIndex: number) {
    Column() {
      Text(title)
        .fontFamily('HarmonyHeiTi')
        .fontWeight(this.outerCurrentIndex === targetIndex ? FontWeight.Bold : FontWeight.Regular)
        .fontSize($r('app.string.font_size_14'))
        .fontColor(this.outerCurrentIndex === targetIndex ? 'rgba(0,0,0,0.90)' : 'rgba(0,0,0,0.60)')
        .margin({ bottom: $r('app.string.margin_9') });
      Divider()
        .width(28)
        .strokeWidth(2)
        .color(this.outerCurrentIndex === targetIndex ? '#000000' : 'transparent')
        .opacity(this.outerCurrentIndex === targetIndex ? 1 : 0);
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
      this.outerCurrentIndex = targetIndex;
      this.outerTabsController.changeIndex(targetIndex); // 切换页签 页签在Tabs里的索引值，索引值从0开始。
      this.vm.cityName = title;
    });
  }

  @Builder
  innerTabBarBuilder(title: string, targetIndex: number) {
    Column() {
      Text(title)
        .fontFamily('HarmonyHeiTi')
        .fontWeight(this.innerCurrentIndex === targetIndex ? FontWeight.Medium : FontWeight.Regular)
        .fontSize($r('app.string.font_size_12'))
        .fontColor(this.innerCurrentIndex === targetIndex ? 'rgba(0,0,0,0.90)' : 'rgba(0,0,0,0.60)')
        .margin({ bottom: $r('app.string.margin_9') });
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
    .padding({ top: $r('app.string.padding_12'), bottom: $r('app.string.padding_12') })
    .height(40)
    .onClick(() => {
      this.innerCurrentIndex = targetIndex;
      this.innerTabsController.changeIndex(targetIndex); // 切换页签 页签在Tabs里的索引值，索引值从0开始。
      this.vm.type = title;
    });
  }

  build() {
    Column() {
      TitleTop({ title: $r('app.string.title_activity') })
        .margin({ bottom: $r('app.string.margin_xs') });

      Tabs({ barPosition: BarPosition.Start, controller: this.outerTabsController }) {
        ForEach(CITY_LIST_ACTIVITY, (item: CityItem) => {
          TabContent() {

            Tabs({ barPosition: BarPosition.Start, controller: this.innerTabsController }) {
              ForEach(ACTIVITY_TYPE_LIST, (type: ActivityTypeItem) => {
                TabContent() {
                  ActivityList();
                }
                .tabBar(this.innerTabBarBuilder(type.name, type.id));


              }, (type: string) => JSON.stringify(type));


            }
            .vertical(false)
            .barWidth('100%') //横向Tabs的barWidth的宽度
            .backgroundColor('#F1F3F5')
            .barMode(BarMode.Scrollable)
            .scrollable(false)
            .layoutWeight(1);



          }
          .tabBar(this.outerTabBarBuilder(item.name, item.id));
        }, (item: string) => JSON.stringify(item));

      }
      .vertical(false)
      .barWidth('100%') //横向Tabs的barWidth的宽度
      .backgroundColor('#F1F3F5')
      .barMode(BarMode.Scrollable)
      .scrollable(false)
      .layoutWeight(1);
      }
    .backgroundColor('#F1F3F5')
    .clip(false)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
  }
}
