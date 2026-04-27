import { Personal } from 'personal';
import { MapPage } from 'map';
import { Shop } from 'shop';
import { Home } from 'home';
import { Constants } from 'constant';
import { CustomTabBar } from './CustomTabBar';
import { MainPageVM } from '../viewmodel/MainPageVM';
import { PageGround } from 'travel_discovery';

@Builder
export function MainBuilder() {
  Main();
}

@ComponentV2
struct Main {
  vm: MainPageVM = MainPageVM.instance;
  @Provider('homeTabIndex') homeTabIndex: number = 0;
  @Provider('orderTabIndex') orderTabIndex: number = 0;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;

  @Builder
  tabBuilder(title: ResourceStr, targetIndex: number, selectedImg: Resource, normalImg: Resource) {
    Column({ space: 4 }) {
      Image(this.homeTabIndex === targetIndex ? selectedImg : normalImg)
        .size({ width: $r('app.float.tabBuilder_image_width'), height: $r('app.float.tabBuilder_image_height') });
      Text(title)
        .fontColor(this.homeTabIndex === targetIndex ? $r('app.color.keyword_type_font_color') :
        $r('app.color.text_normal_color'))
        .fontSize($r('app.float.tabBuilder_font_size'));
    }
    .width(Constants.FULL_SCREEN)
    .justifyContent(FlexAlign.Center);
  }

  build() {
    NavDestination() {
      Flex({
        direction: FlexDirection.Column,
      }) {
        Tabs({ index: this.homeTabIndex }) {
          TabContent() {
            Home();
          };

          TabContent() {
            PageGround({
              isShowBack: false,
            });
          };

          TabContent() {
            MapPage();
          };

          TabContent() {
            Shop();
          };

          TabContent() {
            Personal();
          };
        }
        .layoutWeight(1)
        .barHeight(0)
        .scrollable(false)
        .onChange((index) => {
          this.homeTabIndex = index;
        });

        CustomTabBar({
          homeTabIndex: this.homeTabIndex,
          changeIndex: (index: number) => {
            this.homeTabIndex = index;
          },
        });
      }
      .width(Constants.FULL_SCREEN)
      .height(Constants.FULL_SCREEN)
      .padding({ bottom: this.windowBottomHeight })
      .backgroundColor(Color.White);
    }
    .hideTitleBar(true)
  }

  aboutToAppear() {
    this.vm.init();
  }
}