import { RouterMap, RouterUtils, HOT_COURSE_DATA, Course, BreakpointNameEnum,
  BreakpointModel } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { NumberUtil } from 'mine/src/main/ets/utils/NumberUtil';
import { HotCoursePageVM } from '../viewmodels/HotCoursePageVM';
import { AppStorageV2 } from '@kit.ArkUI';

@Builder
export function HotCoursePageBuilder() {
  HotCoursePage()
}

@ComponentV2
export struct HotCourse {
  @Param isShowTop: boolean = false
  @Param detailList: Course[] = this.isShowTop ?
    HOT_COURSE_DATA.slice(0, Math.min(4, HOT_COURSE_DATA.length)) : HOT_COURSE_DATA
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  @Computed
  get listLanes() {
    if ([BreakpointNameEnum.SM].includes(this.breakPointModel.currentBreakpoint)) {
      return 1;
    } else if ([BreakpointNameEnum.MD].includes(this.breakPointModel.currentBreakpoint)) {
      return 2;
    }
    return 3;
  }

  build() {
    List() {
      ForEach(this.detailList, (item: Course) => {
        ListItem() {
          Row() {
            Image(item.cover)
              .width(96)
              .height(54)
              .borderRadius(8)
              .margin({ right: 12 })
            Column() {
              Text(item.courseTitle)
                .maxLines(2)  // 限制最大行数
                .textOverflow({ overflow: TextOverflow.Ellipsis }) // 超出部分显示省略号
                .fontWeight(FontWeight.Medium)
                .fontSize($r('sys.float.Body_M'))
                .height(42)
                .margin({ bottom:2 })
              Row() {
                Text(`难度：${item.difficultyLevel}`)
                  .fontWeight(FontWeight.Regular)
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor('rgba(0, 0, 0, 0.4)')
                  .margin({ right: 12 })
                Image($r('app.media.ic_time'))
                  .width(12)
                  .height(12)
                  .margin({ right: 2 })
                Text(NumberUtil.getHourAndMinuteFormat(item.courseDuration))
                  .fontWeight(FontWeight.Regular)
                  .fontSize($r('sys.float.Body_S'))
                  .fontColor('rgba(0, 0, 0, 0.4)')
              }
              .height(16)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding({
            top: 18,
            bottom: 18,
            left: 12,
            right: 12
          })
          .onClick(() => RouterUtils.pushPathByName(RouterMap.COURSE_DETAIL_PAGE, item.id))
        }
      })
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .lanes(this.listLanes)
  }
}

@ComponentV2
struct HotCoursePage {
  vm: HotCoursePageVM = new HotCoursePageVM();
  scroller: Scroller = new Scroller()

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '热门课程',
        })

        Scroll(this.scroller) {
          Column() {
            HotCourse()
          }
          .height('100%')
          .margin({ left: 16, right: 16 })
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Vertical)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .margin({ bottom: 30 })
        .width('100%')
      }
      .width('100%')
      .backgroundColor($r('app.color.course_background'))
    }
    .hideTitleBar(true)
  }
}
