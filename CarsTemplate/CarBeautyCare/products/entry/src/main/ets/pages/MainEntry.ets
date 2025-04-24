import { TAB_LIST } from '../constants/Constants';
import { HomeView } from './home/HomeView';
import { MineView } from './mine/MineView';
import { CarView } from './car/CarView';
import { TabListItem } from '../types/Types';
import { CommonModel, CommonConstants, StringUtil, ObjectUtil } from '@ohos_agcit/car_beauty_care_commonlib';
import { emitter } from '@kit.BasicServicesKit';

@Entry({ routeName: 'mainPage' })
@ComponentV2
struct MainEntry {
  vm: CommonModel = CommonModel.instance;
  bottomRectHeight: number = 0;
  @Provider('appPathStack') appPathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.bottomRectHeight = AppStorage.get('bottomRectHeight') || 0;
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Row() {
        Image($r('app.media.bg'))
          .width(CommonConstants.FULL_WIDTH)
          .height(220);
      }
      .width(CommonConstants.FULL_WIDTH)
      .height(CommonConstants.FULL_HEIGHT)
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: [['#E8F2F5', 0.0], ['#F1F3F5', 0.3], ['#F1F3F5', 0.7], ['#fff', 1.0]],
      })
      .alignItems(VerticalAlign.Top);


      Navigation(this.appPathStack) {
        Column() {
          Tabs({ barPosition: BarPosition.End, index: this.vm.curIndex }) {
            TabContent() {
              HomeView();
            }
            .tabBar(this.tabBarBuilder(TAB_LIST[0], 0));

            TabContent() {
              CarView();
            }
            .tabBar(this.tabBarBuilder(TAB_LIST[1], 1));

            TabContent() {
              MineView();
            }
            .tabBar(this.tabBarBuilder(TAB_LIST[2], 2));
          }
          .scrollable(false)
          .height(CommonConstants.FULL_HEIGHT)
          .animationDuration(0)
          .barMode(BarMode.Fixed)
          .onChange((index: number) => {
            this.vm.curIndex = index;
          });
        }
        .backgroundColor(Color.White);
      }
      .hideTitleBar(true)
      .hideToolBar(true)
      .hideBackButton(true)
      .mode(NavigationMode.Stack)
      .padding({
        bottom: px2vp(this.bottomRectHeight),
      });
    };

  }

  @Builder
  tabBarBuilder(item: TabListItem, index: number) {
    Column() {
      Image(this.vm.curIndex === index ? item.iconChecked : item.icon)
        .width(24)
        .height(24);
      Text(item.label)
        .fontColor(this.vm.curIndex === index ? $r('app.color.icon_color_highlight') :
          'rgba(0,0,0,0.6)')
        .fontSize($r('app.string.font_size_10'))
        .margin({ top: $r('app.string.margin_xs') });

    }.width(CommonConstants.FULL_WIDTH);
  }
}