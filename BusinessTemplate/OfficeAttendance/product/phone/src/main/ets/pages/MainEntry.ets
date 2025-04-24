import { TAB_LIST } from '../constants/Constants';
import { AgencyTaskView } from '@ohos_agcit/office_attendance_agency';
import { ScheduleView } from '@ohos_agcit/office_attendance_schedule';
import { TabListItem } from '@ohos_agcit/office_attendance_agency';
import { CheckInView } from '@ohos_agcit/office_attendance_checkin';
import { CommonConstants, MainEntryVM } from '@ohos_agcit/office_attendance_common_lib';
import { MineView } from '@ohos_agcit/office_attendance_account';
import { router } from '@kit.ArkUI';


@Builder
export function mainEntryBuilder() {
  MainEntry();
}

@Entry
@ComponentV2
struct MainEntry {
  vm: MainEntryVM = MainEntryVM.instance;
  @Provider() isPageShow: boolean = false;
  @Provider() currentTabIndex: number = this.vm.curIndex;

  onPageShow(): void {
    this.isPageShow = true;
  }

  onPageHide(): void {
    this.isPageShow = false;
  }

  build() {
    Navigation(this.vm.navStack) {
      Tabs({ barPosition: BarPosition.End, index: this.vm.curIndex }) {
        TabContent() {
          CheckInView();
        }
        .tabBar(this.tabBarBuilder(TAB_LIST[0], 0));

        TabContent() {
          AgencyTaskView();
        }
        .tabBar(this.tabBarBuilder(TAB_LIST[1], 1));

        TabContent() {
          ScheduleView();
        }
        .tabBar(this.tabBarBuilder(TAB_LIST[2], 2));

        TabContent() {
          MineView({
            callback: () => {
              router.replaceUrl({ url: 'pages/Login' })
            }
          });
        }
        .tabBar(this.tabBarBuilder(TAB_LIST[3], 3));
      }
      .scrollable(false)
      .barHeight(80)
      .height(CommonConstants.FULL_HEIGHT)
      .animationDuration(0)
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.vm.curIndex = index;
        this.currentTabIndex = index;
      });
    }
    .title({ builder: this.titleBuilder(TAB_LIST[this.vm.curIndex]), height: 92 })
    .mode(NavigationMode.Stack)
  }

  @Builder
  titleBuilder(title: TabListItem) {
    Row() {
      Text(title.label)
        .fontWeight(FontWeight.Bold)
        .fontColor('rgba(0,0,0,0.90)')
        .fontSize($r('app.float.navigation_title_font_size'))
        .margin({ left: 16, top: 36 })
        .height(56)
    }
    .justifyContent(FlexAlign.Start)
    .backgroundColor(title.titleBackgroundColor)
    .width('100%')
    .height('100%')
    .alignItems(VerticalAlign.Bottom)
  }

  @Builder
  tabBarBuilder(item: TabListItem, index: number) {
    Column() {
      Image(this.vm.curIndex === index ? item.iconChecked : item.icon)
        .width($r('app.float.navigation_image_size'))
        .height($r('app.float.navigation_image_size')).margin({ top: $r('app.string.margin_xs') });
      Text(item.label)
        .fontColor(this.vm.curIndex === index ? $r('app.color.icon_color_highlight') :
        $r('app.color.icon_color_level2'))
        .fontSize($r('app.float.navigation_navi_size'))
        .height(14)
        .margin({ top: $r('app.string.margin_xs'), bottom: $r('app.string.margin_xs') });
    }.height(80).width('100%').justifyContent(FlexAlign.Start);
  }
}