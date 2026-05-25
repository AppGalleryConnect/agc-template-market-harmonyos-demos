import { RouterMap, RouterUtils, PlanInfo, CourseDetailModel, BreakpointNameEnum, BreakpointModel } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { CourseFilterDialog } from '../viewmodels/CustomDialog';
import { AdvancedCourse } from './AdvancedCoursePage';
import { HotCourse } from './HotCoursePage';
import { AppStorageV2 } from '@kit.ArkUI';

let filter: string[] = [];

@Builder
export function CoursePageBuilder() {
  CoursePage()
}

AppStorage.setOrCreate<boolean>('0001', false)
AppStorage.setOrCreate<boolean>('0002', false)
AppStorage.setOrCreate<boolean>('0003', false)
AppStorage.setOrCreate<boolean>('0004', false)
AppStorage.setOrCreate<boolean>('0005', false)
AppStorage.setOrCreate<boolean>('0006', false)
AppStorage.setOrCreate<boolean>('0007', false)
AppStorage.setOrCreate<boolean>('0008', false)
AppStorage.setOrCreate<boolean>('0009', false)
AppStorage.setOrCreate<boolean>('0010', false)
AppStorage.setOrCreate<boolean>('0011', false)

@ComponentV2
export struct CoursePage {
  @Local isShowCourseFilterDialog: boolean = false
  @Local isShowCourseFilterDialogOnTop: boolean = false
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  scroller: Scroller = new Scroller()

  async aboutToAppear() {
    AppStorage.setOrCreate<String[]>('FilterList', [])
    filter = []
  }

  @Computed
  get searchOnBetween() {
    if ([BreakpointNameEnum.MD, BreakpointNameEnum.LG,
      BreakpointNameEnum.XL].includes(this.breakPointModel.currentBreakpoint)) {
      return false;
    }
    return true;
  }

  @Builder
  CourseFilterDialogBuilder() {
    Column() {
      // 可滚动的内容区域
      Scroll() {
        Column() {
          CourseFilterDialog({ filter: filter })
        }
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .layoutWeight(1) // 占据剩余空间，让底部按钮固定

      // 固定在底部的按钮
      Row() {
        Text('筛选课程')
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
      }
      .justifyContent(FlexAlign.Center)
      .margin({ top: 10 })
      .padding({ left: 16, right: 16, top: 9, bottom: 9 })
      .width('100%')
      .height(40)
      .borderRadius(20)
      .backgroundColor($r('app.color.app_theme'))
      .onClick(() => {
        if (filter.length === 0) {
          AppStorage.setOrCreate<String[]>('FilterList', [])
          this.isShowCourseFilterDialog = false;
          this.isShowCourseFilterDialogOnTop = false;
        } else {
          this.isShowCourseFilterDialog = false;
          this.isShowCourseFilterDialogOnTop = false;
          AppStorage.setOrCreate<String[]>('FilterList', filter)
          RouterUtils.pushPathByName(RouterMap.FILTER_PAGE)
        }
      })
    }
    .height('100%')
    .padding({
      left: 16,
      right: 16,
      bottom: 18
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  hotCourseListBuilder() {
    Column() {
      Row() {
        Text('热门课程')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
        Image($r('app.media.ic_right'))
          .opacity(0.4)
          .width(12)
          .height(24)
          .onClick(() => {
            RouterUtils.pushPathByName(RouterMap.HOT_COURSE_PAGE)
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding({ top: 24, bottom: 8 })

    HotCourse({ isShowTop: true })
  }

  @Builder
  advancedCourseListBuilder() {
    Column() {
      Row() {
        Text('进阶课程')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
        Image($r('app.media.ic_right'))
          .fillColor($r('sys.color.black'))
          .width(12)
          .height(24)
          .opacity(0.4)
          .onClick(() => {
            RouterUtils.pushPathByName(RouterMap.ADVANCED_COURSE_PAGE);
          })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
    }
    .width('100%')
    .padding({ top: 24, bottom: 8 })

    AdvancedCourse({ isShowTop: true })
  }

  @Builder
  searchAndFilterOnTop() {
    Row() {
      Row() {
        Image($r('app.media.ic_search'))
          .margin({ right: 6 })
          .width(16)
        Text('搜索')
          .fontSize($r('sys.float.Body_L'))
          .fontColor('rgba(0, 0, 0, 0.6)')
          .lineHeight(21)
      }
      .backgroundColor('#0d000000')
      .borderRadius(20)
      .layoutWeight(1)
      .margin({
        right: 8
      })
      .padding({
        left: 12,
        right: 54,
        top: 7,
        bottom: 10
      })
      .onClick(() => {
        RouterUtils.pushPathByName(RouterMap.COURSE_SEARCH)
      })

      Column() {
        Image($r('app.media.ic_filter'))
          .width(40)
          .height(40)
      }
      .onClick(() => {
        this.isShowCourseFilterDialogOnTop = true
      })
      .bindSheet($$this.isShowCourseFilterDialogOnTop, this.CourseFilterDialogBuilder(), {
        dragBar: false,
        showClose: true,
        preferType: SheetType.CENTER,
        title: { title: '筛选' },
        height: '90%',
        backgroundColor: '#fff',
        onDisappear: () => {
          this.isShowCourseFilterDialogOnTop = false;
        }
      })
    }
    .width('60%')
    .margin({
      bottom: 12
    })
    .padding({ left: 16, right: 16 })
    .visibility(this.searchOnBetween ? Visibility.None : Visibility.Visible)
  }

  @Builder
  searchAndFilter() {
    Row() {
      Row() {
        Image($r('app.media.ic_search'))
          .width(16)
          .margin({ right: 6 })
        Text('搜索')
          .lineHeight(21)
          .fontSize($r('sys.float.Body_L'))
          .fontColor('rgba(0, 0, 0, 0.6)')
      }
      .margin({
        right: 8
      })
      .onClick(() => {
        RouterUtils.pushPathByName(RouterMap.COURSE_SEARCH)
      })
      .padding({
        left: 12,
        right: 54,
        top: 7,
        bottom: 10
      })
      .borderRadius(20)
      .layoutWeight(1)
      .backgroundColor('#0d000000')

      Column() {
        Image($r('app.media.ic_filter'))
          .width(40)
          .height(40)
      }
      .bindSheet($$this.isShowCourseFilterDialog, this.CourseFilterDialogBuilder(), {
        dragBar: false,
        showClose: true,
        height: '90%',
        title: { title: '筛选' },
        backgroundColor: '#fff',
        preferType: SheetType.CENTER,
        onDisappear: () => {
          this.isShowCourseFilterDialog = false;
        }
      })
      .onClick(() => {
        this.isShowCourseFilterDialog = true
      })
    }
    .width('100%')
    .margin({
      bottom: 12
    })
    .padding({ left: 16, right: 16 })
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '课程',
          isSubTitle: false,
          rightPartBuilder: () => {
            this.searchAndFilterOnTop()
          },
        })

        if (this.searchOnBetween) {
          this.searchAndFilter()
        }

        Scroll(this.scroller) {
          Column() {
            // 热门课程
            this.hotCourseListBuilder()

            // 进阶课程
            this.advancedCourseListBuilder()
          }
          .margin({ left: 16, right: 16, bottom: 20 })
        }
        .edgeEffect(EdgeEffect.Spring)
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .height('100%')
      .width('100%')
      .backgroundColor($r('app.color.course_background'))
    }
  }
}
