import { AccountUtil, FormCardRouteInfo, RouterMap, RouterModule, WindowConfig } from 'commonlib';
import { CardWrapper, ComponentConst, LoadingComponentWrapper, SegmentButtonAdapter, NavigateBar,
  SimpleCapsuleButton } from 'componentlib';
import { ClassSignInButton } from '../component/ClassSignInButton';
import { HomePageVM } from '../viewmodel/HomePageVM';
import { ItemRestriction, SegmentButtonOptions, SegmentButtonTextItem } from '@ohos.arkui.advanced.SegmentButton';
import { SimpleCourseInfo } from 'network/src/main/ets/models/response/QueryDayCourseResp';
import { DayCourseInfoCard } from '../component/DayCourseInfoCard';
import { AppStorageV2, promptAction } from '@kit.ArkUI';


@Builder
export function homePageBuilder() {
  HomePage()
}

@ComponentV2
struct HomePage {
  vm: HomePageVM = HomePageVM.instance;
  @Consumer('mainTabController') mainTabController: TabsController = new TabsController();
  @Consumer('windowConfig') windowConfig: WindowConfig = new WindowConfig();
  @Local formCardRouteInfo: FormCardRouteInfo = AppStorageV2.connect(FormCardRouteInfo, 'formCardRouteInfo', () => new FormCardRouteInfo())!;
  @Local abilityTabIndex: number = 0;

  @Monitor('formCardRouteInfo.path')
  formRoute(monitor: IMonitor) {
    const routePath = monitor.value()?.now as string ?? '';
    if (routePath === '') {
      return;
    }
    if (routePath === RouterMap.HOME) {
      RouterModule.clear();
      this.mainTabController.changeIndex(0);
      return;
    }
    if (!AccountUtil.getUserInfo().avatar) {
      RouterModule.clear();
      this.mainTabController.changeIndex(1);
      promptAction.showToast({
        message: '签到功能需关联华为账号',
      });
    } else {
      RouterModule.updateFormStack(routePath);
    }
    this.formCardRouteInfo.path = '';
  }

  courseTabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    fontColor: $r('app.color.system_color_grey_60'),
    selectedFontColor: Color.White,
    fontSize: $r('sys.float.Body_L'),
    selectedFontSize: $r('sys.float.Body_L'),
    selectedBackgroundColor: $r('sys.color.multi_color_09'),
    fontWeight: FontWeight.Bold,
    selectedFontWeight: FontWeight.Bold,
    buttonPadding: {
      top: $r('app.string.padding_xs'),
      bottom: $r('app.string.padding_xs'),
      left: $r('app.string.padding_xm'),
      right: $r('app.string.padding_xm'),
    },
    buttons: [
      { text: $r('app.string.today_schedule') },
      { text: $r('app.string.tomorrow_schedule') },
    ] as ItemRestriction<SegmentButtonTextItem>,
  });

  @Local courseTabIndex: number = 0;
  @Local courseInfoList: SimpleCourseInfo[] = [];

  @Monitor('vm.todayCourseList', 'vm.tomorrowCourseList')
  updateCourseInfoList() {
    if (this.courseTabIndex === 0) {
      this.courseInfoList = this.vm.todayCourseList ?? [];
    } else {
      this.courseInfoList = this.vm.tomorrowCourseList ?? [];
    }
  }

  aboutToAppear(): void {
    this.vm.initCourseInfo();
  }

  build() {
    Column() {
      // 标题
      NavigateBar({ title: $r('app.string.home_page') })

      Scroll() {
        Column() {
          Column({ space: ComponentConst.CARD_SPACE_SMALL }) {
            // 首页Banner
            Swiper() {
              ForEach([0, 0, 0, 0, 0], () => {
                Image($r('app.media.ic_banner'))
                  .objectFit(ImageFit.Fill)
                  .width(ComponentConst.FULL_PARENT)
                  .height(160)
              }, (item: number) => `${item}`)
            }
            .itemSpace(ComponentConst.SWIPER_ITEM_SPACE)
            .borderRadius(ComponentConst.CARD_RADIUS_MIDDLE)
            .indicator(Indicator.dot().selectedColor($r('sys.color.multi_color_09')))
            .id('home_banner')

            // 签到按钮
            ClassSignInButton()
              .onClick(() => {
                if (AccountUtil.getUserInfo().avatar) {
                  RouterModule.push({ url: RouterMap.CLASS_SIGN_IN });
                } else {
                  this.mainTabController.changeIndex(1);
                  promptAction.showToast({
                    message: '签到功能需关联华为账号',
                  });
                }
              })
          }
          .alignItems(HorizontalAlign.Start)
          .width(ComponentConst.FULL_PARENT)
          .padding({
            left: ComponentConst.PAGE_HORIZONTAL_PADDING,
            right: ComponentConst.PAGE_HORIZONTAL_PADDING,
          })

          Column({ space: ComponentConst.CARD_SPACE_SMALL }) {
            this.courseTabBuilder();
          }
          .alignItems(HorizontalAlign.Start)
          .width(ComponentConst.FULL_PARENT)
          .margin({ top: ComponentConst.CARD_SPACE_SMALL })
          .padding({
            left: ComponentConst.PAGE_HORIZONTAL_PADDING,
            right: ComponentConst.PAGE_HORIZONTAL_PADDING,
          })
        }
        .width(ComponentConst.FULL_PARENT)
      }
      .align(Alignment.TopStart)
      .width(ComponentConst.FULL_PARENT)
      .layoutWeight(1)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .padding({
        bottom: ComponentConst.PAGE_VERTICAL_PADDING,
      })
    }
    .alignItems(HorizontalAlign.Start)
    .width(ComponentConst.FULL_PARENT)
    .height(ComponentConst.FULL_PARENT)
  }

  @Builder courseTabBuilder() {
    CardWrapper() {
      RelativeContainer() {
        // 课表Tab顶部按钮栏
        SegmentButtonAdapter({
          options: this.courseTabOptions,
          tabSelectedIndexes: [0, 1],
          onItemClicked: (tabIndex: number) => {
            this.courseTabClick(tabIndex);
          },
        }).width('50%')
          .alignRules({
            middle: ComponentConst.bindHorizontalCenter(),
          })
          .id('course_segment')

        // 全部课程
        Column() {
          Image($r('app.media.ic_small_calendar_black'))
            .objectFit(ImageFit.Fill)
            .size(ComponentConst.ICON_SIZE_S)

          Text($r('app.string.home_all'))
            .fontSize($r('app.string.font_size_10'))
            .margin({ top: 3 })
        }
        .alignRules({
          center: ComponentConst.bindVerticalCenter('course_segment'),
          right: ComponentConst.bindEnd(),
        })
        .margin({ right: $r('app.string.padding_xs') })
        .onClick(() => {
          RouterModule.push({ url: RouterMap.COURSE_SCHEDULE });
        })
        .id('all_course_btn')

        Column() {
          LoadingComponentWrapper({ isLoading: this.vm.isLoading }) {
            if (this.vm.courseRequestSuccess) {
              this.courseInfoBuilder();
            } else {
              this.courseRequestFailBuilder();
            }
          }
        }
        .alignItems(HorizontalAlign.Start)
        .alignRules({ top: ComponentConst.bindBottom('course_segment') })
        .margin({ top: 22 })
        .width(ComponentConst.FULL_PARENT)
        .height(ComponentConst.AUTO_SIZE)
        .id('course_info_container')
      }
      .width(ComponentConst.FULL_PARENT)
      .height(ComponentConst.AUTO_SIZE)
    }
  }

  // 今日/明日课表详情
  @Builder courseInfoBuilder() {
    Column() {
      Text() {
        Span(this.courseTabIndex === 0 ? $r('app.string.today_schedule') : $r('app.string.tomorrow_schedule'))
          .fontColor(Color.Black)
        Span(` ${this.courseInfoList?.length ?? 0}`)
          .fontColor(this.courseInfoList?.length > 0 ? $r('sys.color.multi_color_09') : $r('app.color.system_color_grey_60'))
        Span($r('app.string.home_lesson'))
          .fontColor(this.courseInfoList?.length > 0 ? $r('sys.color.multi_color_09') : $r('app.color.system_color_grey_60'))
      }
      .fontSize($r('sys.float.Body_M'))
      .fontWeight(FontWeight.Bold)

      if (this.courseInfoList?.length > 0) {
        List({ space: ComponentConst.CARD_SPACE_SMALL }) {
          ForEach(this.courseInfoList, (item: SimpleCourseInfo) => {
            ListItem() {
              DayCourseInfoCard({
                dateTime: this.getDateTime(),
                courseInfo: item,
              })
            }
          }, (item: SimpleCourseInfo) => item.courseName)
        }
        .width(ComponentConst.FULL_PARENT)
        .margin({ top: ComponentConst.CARD_PADDING_VERTICAL })
      } else {
        this.courseEmptyBuilder();
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width(ComponentConst.FULL_PARENT)
    .height('auto')
  }

  // 请求失败界面
  @Builder courseRequestFailBuilder() {
    Column() {
      Image($r('app.media.ic_request_failed'))
        .objectFit(ImageFit.Fill)
        .size(ComponentConst.ICON_SIZE_XL)

      Text($r('app.string.get_course_failed'))
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('app.color.system_color_grey_40'))
        .margin({ top: $r('app.string.margin_s') })

      SimpleCapsuleButton({
        buttonBgColor: $r('sys.color.background_secondary'),
        iconSrc: $r('app.media.ic_resetting'),
        textContent: $r('app.string.click_retry'),
        textColor: $r('sys.color.multi_color_09'),
      })
        .margin({ top: $r('app.string.margin_xm') })
        .onClick(() => {
          this.vm.queryDayCourse(4);
        })
    }
    .width(ComponentConst.FULL_PARENT)
    .height('auto')
  }

  // 无课提示界面
  @Builder courseEmptyBuilder() {
    Column() {
      Image($r('app.media.ic_no_course'))
        .objectFit(ImageFit.Fill)
        .size(ComponentConst.ICON_SIZE_XL)

      Text($r('app.string.no_course_in_schedule'))
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('app.color.system_color_grey_40'))
        .margin({ top: $r('app.string.margin_s') })

      SimpleCapsuleButton({
        buttonBgColor: $r('sys.color.multi_color_09'),
        iconSrc: $r('app.media.ic_small_calendar_white'),
        textContent: $r('app.string.all_course'),
        textColor: Color.White,
      })
        .margin({ top: $r('app.string.margin_xm') })
        .onClick(() => {
          RouterModule.push({ url: RouterMap.COURSE_SCHEDULE });
        })
    }
    .width(ComponentConst.FULL_PARENT)
    .height('auto')
  }

  getDateTime(): Date {
    const time = new Date();
    if (this.courseTabIndex === 1) {
      time.setDate(time.getDate() + 1);
    }
    return time;
  }

  courseTabClick(index: number) {
    this.courseTabIndex = index;
    const curCourseList = index === 0 ? this.vm.todayCourseList : this.vm.tomorrowCourseList;
    this.courseInfoList = curCourseList ?? [];
  }
}