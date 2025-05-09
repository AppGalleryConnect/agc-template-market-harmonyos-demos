import { Discovery } from 'discovery';
import { Personal } from 'personal';
import { MapPage } from 'map';
import { Shop } from 'shop';
import { Home } from 'home';
import { Constants } from 'constant';
import { CustomTabBar } from './CustomTabBar';
import { MainPageVM } from '../viewmodel/MainPageVM';

@Entry
@Component
struct Main {
  vm: MainPageVM = MainPageVM.instance;
  @Provide('homeTabIndex') homeTabIndex: number = 0;
  @Provide('orderTabIndex') orderTabIndex: number = 0;
  @Provide('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @State windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;

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
    Navigation(this.mainPathStack) {
      Flex({
        direction: FlexDirection.Column,
      }) {
        Tabs({ index: this.homeTabIndex }) {
          TabContent() {
            Home();
          };

          TabContent() {
            Discovery();
          };

          TabContent() {
            MapPage({ homeTabIndex: $homeTabIndex });
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

        CustomTabBar({ homeTabIndex: $homeTabIndex });
      }
      .width(Constants.FULL_SCREEN)
      .height(Constants.FULL_SCREEN)
      .padding({ bottom: this.windowBottomHeight })
      .backgroundColor(Color.White);
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack);
  }

  aboutToAppear() {
    this.vm.init();
  }
}