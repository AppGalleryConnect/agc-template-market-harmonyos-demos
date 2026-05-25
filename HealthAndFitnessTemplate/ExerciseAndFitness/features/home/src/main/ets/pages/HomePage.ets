import { BreakpointModel, BreakpointNameEnum, Course, KNOWLEDGE_DRAW_DATA, RouterMap, RouterUtils } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { AdvancedCourse, HotCourse } from 'course'
import { AppStorageV2, display } from '@kit.ArkUI';


@Builder
export function HomePageBuilder() {
  HomePage()
}

interface SwiperSettingInfo {
  displayCount: number;
  nextMargin: number;
  itemSpace: number;
}

interface SwiperItem {
  img: Resource;  // 图片资源（如 $r('app.media.bg')）
  text: string;   // 文字内容
  url: RouterMap;
  id: string;
}

@ComponentV2
export struct HomePage {
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  scroller: Scroller = new Scroller()
  homeSwiperImageList: SwiperItem[] = [{ img: $r('app.media.swiperImage1'), text: '你真的会跑步吗？关于跑步机的正确使用训练课程', url: RouterMap.COURSE_DETAIL_PAGE, id: '0003' },
    { img: $r('app.media.swiperImage2'), text: '居家健身的优质动作一览', url: RouterMap.COURSE_DETAIL_PAGE, id: '0002' },
    { img: $r('app.media.swiperImage3'), text: '舒缓腰部，促进血液循环', url: RouterMap.COURSE_DETAIL_PAGE, id: '0005' },
    { img: $r('app.media.swiperImage4'), text: '背部舒展，提高内脏健康活力度', url: RouterMap.COURSE_DETAIL_PAGE, id: '0001' },
    { img: $r('app.media.swiperImage5'), text: '暴汗自重力量训练', url: RouterMap.COURSE_DETAIL_PAGE, id: '0004' }];
  knowledgeList: Course[] = KNOWLEDGE_DRAW_DATA;

  @Computed
  get swiperInfo() {
    // 获取当前屏幕旋转角度（0-3 分别对应 0°、90°、180°、270°）
    let rotation: number = display.getDefaultDisplaySync().rotation;
    const swiperInfo: SwiperSettingInfo  = {
      displayCount: 1,
      nextMargin: 16,
      itemSpace: 8,
    }
    if (BreakpointNameEnum.MD === this.breakPointModel.currentBreakpoint) {
      swiperInfo.displayCount = 2
      swiperInfo.nextMargin = 24
      swiperInfo.itemSpace = 12
    }
    if ([BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes((this.breakPointModel.currentBreakpoint))) {
      if (rotation === 1 || rotation === 3) {
        swiperInfo.displayCount = 3
        swiperInfo.nextMargin = 32
        swiperInfo.itemSpace = 16
      }
    }
    return swiperInfo;
  }

  @Computed
  get displayCount() {
    // 获取当前屏幕旋转角度（0-3 分别对应 0°、90°、180°、270°）
    let rotation: number = display.getDefaultDisplaySync().rotation;
    if (BreakpointNameEnum.SM === this.breakPointModel.currentBreakpoint) {
      return 2
    }
    if ([BreakpointNameEnum.MD].includes((this.breakPointModel.currentBreakpoint))) {
      return 4
    }
    if (rotation === 1 || rotation === 3) {
      return 5;
    } else {
      return 2
    }
  }

  @Builder
  homeAdvBuilder() {
    Swiper() {
      ForEach(this.homeSwiperImageList, (item: SwiperItem) => {
        Stack() {
          Image(item.img)
            .width('100%')
            .height('100%')
            .borderRadius(16)
          Column() {
            Text(item.text)  // 主标题
              .fontSize($r('sys.float.Body_L'))
              .width(196)
              .position({ left: 86, top: 101 })
              .fontColor(Color.White)
          }
        }
        .onClick(() => RouterUtils.pushPathByName(item.url, item.id))
      })
    }
    .indicator(new DotIndicator()
      .selectedColor($r('app.color.app_theme')))
    .loop(true)
    .autoPlay(true)
    .height(184)
    .width('100%')
    .displayCount(this.swiperInfo.displayCount)
    .nextMargin(this.swiperInfo.nextMargin)
    .itemSpace(this.swiperInfo.itemSpace)
    .curve(Curve.Smooth)
  }

  @Builder
  commonKnowledgeListBuilder() {
    Column() {
      Row() {
        Text('运动健身常识普及')
          .fontWeight(FontWeight.Medium)
          .fontSize(18)
        Image($r('app.media.ic_right'))
          .width(12)
          .height(24)
          .fillColor($r('sys.color.black'))
          .opacity(0.4)
          .onClick(() => {
            RouterUtils.pushPathByName(RouterMap.COMMON_KNOWLEDGE);
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding({ top: 24, bottom: 8 })
    Swiper() {
      ForEach(this.knowledgeList, (item: Course) => {
        Column() {
          Image(item.cover)
            .width('100%')
            .aspectRatio(1)
            .borderRadius(8)
          Text(item.courseTitle)
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_S'))
            .padding({ top: 8 })
        }
        .width('100%')
        .backgroundColor($r('sys.color.white'))
        .padding({ top: 8, bottom: 8, left: 12, right: 12 })
        .borderRadius(8)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => RouterUtils.pushPathByName(RouterMap.COMMON_KNOWLEDGE_DETAIL, item.id))
      })
    }
    .width('100%')
    .indicator(false)
    .loop(true)
    .displayCount(this.displayCount)
    .nextMargin(this.swiperInfo.nextMargin)
    .itemSpace(this.swiperInfo.itemSpace)
    .curve(Curve.Smooth)
  }

  @Builder
  hotCourseListBuilder() {
    Column() {
      Row() {
        Text('热门课程')
          .fontWeight(FontWeight.Medium)
          .fontSize(18)
        Image($r('app.media.ic_right'))
          .width(12)
          .height(24)
          .onClick(() => {
            RouterUtils.pushPathByName(RouterMap.HOT_COURSE_PAGE);
          })
          .opacity(0.4)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
    }
    .padding({ top: 24, bottom: 8 })
    .width('100%')

    HotCourse({ isShowTop: true })
  }

  @Builder
  advancedCourseListBuilder() {
    Column() {
      Row() {
        Text('进阶课程')
          .fontWeight(FontWeight.Medium)
          .fontSize(18)
        Image($r('app.media.ic_right'))
          .fillColor($r('sys.color.black'))
          .width(12)
          .height(24)
          .onClick(() => {
            RouterUtils.pushPathByName(RouterMap.ADVANCED_COURSE_PAGE);
          })
          .opacity(0.4)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .padding({ top: 24, bottom: 8 })
    .width('100%')

    AdvancedCourse({ isShowTop: true })
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '首页',
          isSubTitle: false,
        })

        Scroll(this.scroller) {
          Column() {
            // 轮播图
            this.homeAdvBuilder()

            // 运动健身常识普及
            this.commonKnowledgeListBuilder()

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
      .backgroundColor($r('app.color.home_background'))
    }
  }
}