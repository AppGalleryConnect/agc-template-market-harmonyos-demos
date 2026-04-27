import { Constant } from 'module_base';
import { CustomTitle } from '../component/TitleBar';
import { CATERING_TABS_INFO } from '../constant/Index';
import { CateringTabBarData } from '../model/Index';
import { CateringPageVM } from '../viewmodel/CateringPageVM';

@Builder
export function CateringAndAccommodationBuilder() {
  CateringAndAccommodation();
}

@ComponentV2
export struct CateringAndAccommodation {
  vm: CateringPageVM = CateringPageVM.instance;
  @Local index: number = 0;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.vm.getCateringInfo(this.index)
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
      this.vm.getCateringInfo(this.index)
    })
    .width(Constant.FULL_PERCENT)
    .justifyContent(FlexAlign.Center);
  }

  build() {
    NavDestination() {
      Column() {
        CustomTitle({
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
      }
    }.hideTitleBar(true)
  }
}