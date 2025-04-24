import { Constant } from 'common';
import { TitleBar } from 'components';
import { CateringTabBarData, CATERING_TABS_INFO } from '../model/CateringTabInfo';
import { CateringPageVM } from '../viewmodel/CateringPageVM';

@Builder
export function CateringBuilder() {
  Catering();
}

@ComponentV2
export struct Catering {
  vm: CateringPageVM = CateringPageVM.instance;
  @Local index: number = 0;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.vm.getCateringInfo();
  }

  @Builder
  cateringTabBar(title: ResourceStr, targetIndex: number) {
    Column({ space: 4 }) {
      Text(title)
        .fontColor(this.index === targetIndex ? '#64BB5C' :
        Color.Black)
        .opacity(this.index === targetIndex ? 1 :
          0.6);

      if (this.index === targetIndex) {
        Divider().color('#64BB5C').strokeWidth(3).width(32);
      }
    }
    .onClick(() => {
      this.index = targetIndex;
    })
    .width(Constant.FULL_PERCENT)
    .justifyContent(FlexAlign.Center);
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '餐饮住宿', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Tabs({ index: this.index }) {
          ForEach(CATERING_TABS_INFO, (item: CateringTabBarData) => {
            TabContent() {
              item.component.builder();
            }.tabBar(this.cateringTabBar(item.title, item.id));
          }, (item: CateringTabBarData) => JSON.stringify(item));
        }.barPosition(BarPosition.Start).animationDuration(0).barWidth(160).onChange((value: number) => {
          this.index = value;
        });
      };
    }.hideTitleBar(true);
  }
}