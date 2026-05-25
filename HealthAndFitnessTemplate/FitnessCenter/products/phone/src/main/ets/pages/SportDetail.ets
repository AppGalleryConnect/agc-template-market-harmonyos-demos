import {
  BreakpointModel,
  BreakpointNameEnum, CardInfo, CourseDetailModel,
  GridSettingInfo,
  MockService, SportType } from 'external_interactions';
import { JSON } from '@kit.ArkTS';
import { CardGrid } from 'card';
import { CourseGrid } from 'course'
import { TitleBar } from 'module_recharge/src/main/ets/components/TitleBar';
import { ScreenPropStorage , AccountUpdate} from 'external_interactions'
import { AppStorageV2, display } from '@kit.ArkUI';

interface SwiperSettingInfo {
  displayCount: number;
  nextMargin: number;
  itemSpace: number;
  gridShowNum: number;
}

@ComponentV2
export struct SportDetail {
  @Local screenPropStorage : ScreenPropStorage = AppStorageV2.connect(ScreenPropStorage, 'ScreenPropStorage', () =>new ScreenPropStorage())!
  @Local topRectHeight: number = this.screenPropStorage.topRectHeight;
  @Local bottomRectHeight: number = this.screenPropStorage.bottomRectHeight;
  @Param @Once pathStack: NavPathStack = new NavPathStack();
  @Param @Once sportType: SportType =  {} as SportType
  courseList: CourseDetailModel[] = []
  cardList: CardInfo[] = []
  @Local currentIndex: number = 0
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  @Computed
  get swiperInfo() {
    // 获取当前屏幕旋转角度（0-3 分别对应 0°、90°、180°、270°）
    let rotation: number = display.getDefaultDisplaySync().rotation;
    const swiperInfo: SwiperSettingInfo  = {
      displayCount: 1,
      nextMargin: 16,
      itemSpace: 8,
      gridShowNum: 4
    }
    if (BreakpointNameEnum.MD === this.breakPointModel.currentBreakpoint) {
      swiperInfo.displayCount = 2
      swiperInfo.nextMargin = 24
      swiperInfo.itemSpace = 12
      swiperInfo.gridShowNum = 8
    }
    if ([BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes((this.breakPointModel.currentBreakpoint))) {
      if (rotation === 1 || rotation === 3) {
        swiperInfo.displayCount = 3
        swiperInfo.nextMargin = 32
        swiperInfo.itemSpace = 16
        swiperInfo.gridShowNum = 12
      }
    }
    return swiperInfo;
  }

  @Computed
  get gridSetting() {
    // 获取当前屏幕旋转角度（0-3 分别对应 0°、90°、180°、270°）
    let rotation: number = display.getDefaultDisplaySync().rotation;
    const gridSettingInfo: GridSettingInfo  = {
      template: '1fr 1fr',
      colGap: 8,
      rowGap: 8,
    }
    if (BreakpointNameEnum.MD === this.breakPointModel.currentBreakpoint) {
      gridSettingInfo.template = '1fr 1fr 1fr 1fr'
      gridSettingInfo.colGap = 12
    }
    if ([BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes((this.breakPointModel.currentBreakpoint))) {
      if (rotation === 1 || rotation === 3) {
        gridSettingInfo.template = '1fr 1fr 1fr 1fr 1fr 1fr'
        gridSettingInfo.colGap = 16
        gridSettingInfo.rowGap = 16
      }
    }
    return gridSettingInfo
  }

  @Builder
  sportsAdvBuilder() {
    // 主轮播内容
    Swiper() {
      ForEach(this.sportType.advImage, (item: string) => {
        Image($r(item))
          .width('100%')
          .height('100%')
          .borderRadius(16)
      }, (item: string) => item)
    }
    .loop(true)
    .autoPlay(true)
    .height(148)
    .width('100%')
    .borderRadius(16)
    .curve(Curve.Smooth)
    .indicator(false) // 关闭默认指示器
    .displayCount(this.swiperInfo.displayCount)
    .nextMargin(this.swiperInfo.nextMargin)
    .itemSpace(this.swiperInfo.itemSpace)
    .onChange((index) => {
      this.currentIndex = index // 同步当前索引
    })

    // 自定义指示器
    Row({ space: 6 }) {
      ForEach(this.sportType.advImage, (item: string, index) => {
        // 动态改变选中项样式
        Column()
          .width(this.currentIndex === index ? 12 : 6)
          .height(6)
          .borderRadius(3)
          .backgroundColor(this.currentIndex === index ? '#0A59F7' : 'rgba(0, 0, 0, 0.1)')
          .animation({ duration: 200, curve: Curve.EaseOut }) // 平滑过渡动画
      }, (item: string) => item)
    }
    .margin({ top: 12, bottom: 12 }) // 底部间距
  }

  @Builder
  cardListBuilder() {
    Column() {
      Row() {
        Text('本店卡项')
          .fontWeight(FontWeight.Bold)
          .fontSize(18)

        Row() {
          Text('更多')
            .fontSize(14)
            .margin({ right: 3 })
            .fontColor($r('sys.color.black'))

          Image($r('app.media.chevron_right'))
            .width(8)
            .height(8)
            .fillColor($r('sys.color.black'))
        }
        .opacity(0.4)
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          this.pathStack.pushPath({ name: 'card/showAllCards', param: this.cardList })
        })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ top: 10, bottom: 15 })
      .width('100%')

      Grid() {
        ForEach(this.cardList.slice(0, this.swiperInfo.gridShowNum), (item: CardInfo) => {
          GridItem() {
            CardGrid({cardInfo: item, onBackClick:()=>{
              this.pathStack.pushPath({name: 'card/cardDetail', param: item})
            }})
          }
        }, (item: string) => JSON.stringify(item))
      }
      .width('100%')
      .columnsTemplate(this.gridSetting.template)
      .columnsGap(this.gridSetting.colGap)
      .rowsGap(this.gridSetting.rowGap)
    }
    .width('100%')
    .margin({ bottom: 15 })
  }

  @Builder
  courseListBuilder() {
    Column() {
      Row() {
        Text('课程列表')
          .fontWeight(FontWeight.Bold)
          .fontSize(18)

        Row() {
          Text('更多')
            .fontSize(14)
            .margin({ right: 3 })
          Image($r('app.media.chevron_right'))
            .width(8)
            .height(8)
        }
        .opacity(0.4)
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          this.pathStack.pushPath({ name: 'course/ShowAllCourse', param: this.courseList })
        })
      }
      .padding({ top: 10, bottom: 15 })
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Grid() {
        ForEach(this.courseList.slice(0, this.swiperInfo.gridShowNum), (item: CourseDetailModel) => {
          GridItem() {
            CourseGrid({courseDetail: item, onBackClick:()=>{
              this.pathStack.pushPath({ name: 'course/CourseDetail', param: item })
            }})
          }
        }, (item: CourseDetailModel) => JSON.stringify(item))
      }
      .width('100%')
      .columnsTemplate(this.gridSetting.template)
      .columnsGap(this.gridSetting.colGap)
      .rowsGap(this.gridSetting.rowGap)
    }
    .width('100%')
    .margin({ bottom: 15 })
    .padding({ bottom: 10 })
  }

  build() {
    NavDestination() {
      TitleBar({ title: this.sportType.name,  onBackClick:()=>{this.pathStack.pop()} })
        .margin({ left: 16, right: 16 })
      Stack() {
        Scroll() {
          Column() {
            this.sportsAdvBuilder()
            this.cardListBuilder()
            this.courseListBuilder()
          }
        }
        .scrollBar(BarState.Off)
        .margin({ left: 16, right: 16 })
        .edgeEffect(EdgeEffect.Spring)
      }
      .layoutWeight(1)
      .alignContent(Alignment.Top)
    }
    .hideTitleBar(true)
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx?.pathStack
      this.sportType = ctx?.pathInfo?.param as SportType;
      this.courseList = MockService.getCourseListBySportType(this.sportType.typeEnum)
      this.cardList = MockService.getCardListBySportType(this.sportType.typeEnum)
    })
    .backgroundColor($r('app.color.main_background_color'))
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight),
      bottom: this.getUIContext().px2vp(this.bottomRectHeight) })
  }
}