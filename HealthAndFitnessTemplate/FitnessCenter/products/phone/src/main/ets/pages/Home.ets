import { CardInfo, CourseDetailModel, MockService, SportType, VIDEO_URL,
  BreakpointNameEnum, BreakpointModel, GridSettingInfo, Logger } from 'external_interactions';
import { window } from '@kit.ArkUI';
import { CardContent } from 'card'
import { CourseContent } from 'course'
import { ScreenPropStorage, AccountUpdate } from 'external_interactions'
import { AppStorageV2, display } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import  EventData  from '@ohos.events.emitter';

const TAG = '[Home]'

interface SwiperSettingInfo {
  displayCount: number;
  nextMargin: number;
  itemSpace: number;
  gridShowNum: number;
  sportTypeShowNum: number;
  environmentImageShowNum: number;
}

@ComponentV2
export struct Home {
  @Local screenPropStorage: ScreenPropStorage =
    AppStorageV2.connect(ScreenPropStorage, 'ScreenPropStorage', () => new ScreenPropStorage())!
  @Local topRectHeight: number = this.screenPropStorage.topRectHeight;
  scroller: Scroller = new Scroller()
  controller: VideoController = new VideoController()
  @Param @Once pathStack: NavPathStack = new NavPathStack()
  courseList: CourseDetailModel[] = MockService.courseList
  cardList: CardInfo[] = MockService.cardList
  private swiperController: SwiperController = new SwiperController()
  cardIdMap: Map<string, CardInfo> = MockService.cardIdMap
  courseIdMap: Map<string, CourseDetailModel> = MockService.courseIdMap
  @Local currentIndex: number = 0
  @Local currentCity: string = '北京'
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Consumer() isVideoFullscreen: boolean = false;
  @Local environmentImages: string[] = ['app.media.material5', 'app.media.material11'];

  @Computed
  get swiperInfo() {
    // 获取当前屏幕旋转角度（0-3 分别对应 0°、90°、180°、270°）
    let rotation: number = display.getDefaultDisplaySync().rotation;
    const swiperInfo: SwiperSettingInfo  = {
      displayCount: 1,
      nextMargin: 16,
      itemSpace: 8,
      gridShowNum: 4,
      sportTypeShowNum: 4,
      environmentImageShowNum: 0
    }
    if (BreakpointNameEnum.MD === this.breakPointModel.currentBreakpoint) {
      swiperInfo.displayCount = 2
      swiperInfo.nextMargin = 24
      swiperInfo.itemSpace = 12
      swiperInfo.gridShowNum = 8
      swiperInfo.environmentImageShowNum = 1
    }
    if ([BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes(this.breakPointModel.currentBreakpoint)) {
      if (rotation === 1 || rotation === 3) {
        swiperInfo.displayCount = 3
        swiperInfo.nextMargin = 32
        swiperInfo.itemSpace = 16
        swiperInfo.gridShowNum = 12
        swiperInfo.sportTypeShowNum = 8
        swiperInfo.environmentImageShowNum = 2
      }
    }
    return swiperInfo;
  }

  @Computed
  get gridSetting() {
    let rotation: number = display.getDefaultDisplaySync().rotation;
    const gridSettingInfo: GridSettingInfo  = {
      template: '1fr',
      colGap: 8,
      rowGap: 8,
    }
    if (BreakpointNameEnum.MD === this.breakPointModel.currentBreakpoint) {
      gridSettingInfo.template = '1fr 1fr'
      gridSettingInfo.colGap = 12
      gridSettingInfo.rowGap = 12
    }
    if ([BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes((this.breakPointModel.currentBreakpoint))) {
      if (rotation === 1 || rotation === 3) {
        gridSettingInfo.template = '1fr 1fr 1fr'
        gridSettingInfo.colGap = 16
        gridSettingInfo.rowGap = 16
      }
    }
    return gridSettingInfo
  }

  aboutToAppear(): void {
    try {
      emitter.on('currentCity', (data: EventData.EventData) => {
        if(data.data){
          let currentCity: string = data.data.currentCity
          this.currentCity = currentCity
        }
      })
    } catch (e) {
      Logger.error(TAG, `emitter on failed. error: ${JSON.stringify(e)}`)
    }
  }

  aboutToDisappear(): void {
    try {
      emitter.off('currentCity')
    } catch (e) {
      Logger.error(TAG, `emitter off failed. error: ${JSON.stringify(e)}`)
    }
  }

  @Builder
  homeAdvBuilder() {
    Swiper() {
      ForEach(MockService.homeSwiperImageList, (item: string) => {
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
      ForEach(MockService.homeSwiperImageList, (item: string, index) => {
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
  sportTypesBuilder() {
    Row() {
      Image($r('app.media.back'))
        .width(13)
        .height(13)
        .onClick(() => {
          this.swiperController.showPrevious()
        })
      Swiper(this.swiperController) {
        ForEach(MockService.sportTypeList, (item: SportType) => {
          ListItem() {
            Column() {
              Image($r(item.icon))
                .width(24)
                .height(24)
                .margin({ bottom: 4 })
              Text(item.name)
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
            }
            .onClick(() => {
              this.pathStack.pushPath({ name: 'sportDetail', param: item })
            })
          }.width('25%')
        }, (item: SportType) => JSON.stringify(item))
      }
      .width('80%')
      .autoPlay(false)
      .loop(false)
      .itemSpace(0)
      .displayCount(this.swiperInfo.sportTypeShowNum)
      .effectMode(EdgeEffect.Spring)
      .indicator(false)
      .duration(200)
      .onChange((index: number) => {
        this.swiperController.changeIndex(index)
      })
      .curve(Curve.Smooth)

      Image($r('app.media.chevron_right'))
        .width(13)
        .height(13)
        .onClick(() => {
          this.swiperController.showNext()
        })
    }
    .width('100%')
    .height(72)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .margin({ top: 15, bottom: 15 })
    .borderRadius(16)
    .justifyContent(FlexAlign.SpaceAround)
    .alignItems(VerticalAlign.Center)
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
          this.pathStack.pushPath({ name: 'card/showAllCards' })
        })
      }
      .padding({ top: 10, bottom: 10 })
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      CardContent({
        cardList: this.cardList.slice(0, this.swiperInfo.gridShowNum),
        onChildClick: (id: string) => {
          this.pathStack.pushPath({ name: 'card/cardDetail', param: this.cardIdMap.get(id) })
        }
      })
    }
    .width('100%')
    .margin({ bottom: 12 })
    .padding({ bottom: 10 })
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
          this.pathStack.pushPath({ name: 'course/ShowAllCourse' })
        })
      }
      .padding({ top: 10, bottom: 10 })
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      CourseContent({
        courseList: this.courseList.slice(0, this.swiperInfo.gridShowNum),
        onBackClick:(msg: string) => {
          this.pathStack.pushPath(
            {
              name: 'course/CourseDetail',
              param: this.courseIdMap.get(msg)
            }
          )
        }
      })

    }
    .width('100%')
    .margin({ bottom: 12 })
    .padding({ bottom: 10 })
  }

  @Builder
  clubEnvironmentVideo() {
    Column() {
      Video({
        src: VIDEO_URL,
        previewUri: $r('app.media.material9'),
        controller: this.controller,
        currentProgressRate: PlaybackSpeed.Speed_Forward_1_00_X
      })
        .width('100%')
        .height(BreakpointNameEnum.MD === this.breakPointModel.currentBreakpoint ? 192 : '25%')
        .borderRadius(this.swiperInfo.itemSpace)
        .onFullscreenChange(async (event) => {
          // 改变设备横竖屏状态
          try {
            let lastWindow = await window.getLastWindow(this.getUIContext().getHostContext()!)
            lastWindow.setPreferredOrientation(event.fullscreen ? window.Orientation.LANDSCAPE :
              window.Orientation.UNSPECIFIED)
          } catch (e) {
            Logger.error(TAG, `Failed to get last window. error: ${JSON.stringify(e)}`)
          }
          this.isVideoFullscreen = event.fullscreen;
        })
      Text('了解俱乐部的详情')
        .width('100%')
        .padding({ top: 10, bottom: 10 })
        .fontSize(12)
    }
  }

  @Builder
  clubEnvironmentBuilder() {
    Column() {
      Row() {
        Text('俱乐部环境')
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
          this.pathStack.pushPath({ name: 'clubEnvironmentDetail' })
        })
      }
      .padding({ top: 10, bottom: 10 })
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Grid() {
        GridItem() {
          this.clubEnvironmentVideo()
        }
        ForEach(this.environmentImages.slice(0, this.swiperInfo.environmentImageShowNum), (item: string) => {
          GridItem() {
            Image($r(item))
              .width('100%')
              .height(BreakpointNameEnum.MD === this.breakPointModel.currentBreakpoint ? 192 : '25%')
              .borderRadius(this.gridSetting.colGap)
          }
        }, (item: string) => JSON.stringify(item))
      }
      .columnsTemplate(this.gridSetting.template)
      .columnsGap(this.gridSetting.colGap)
      .rowsGap(this.gridSetting.rowGap)
    }
    .width('100%')
    .margin({ bottom: 15 })
  }

  build() {
    Column() {
      Column() {
        Row() {
          Text(this.currentCity)
            .fontSize(16)
            .width(16 * this.currentCity.length)
            .fontWeight(FontWeight.Medium)
            .margin({ right: 2 })

          Image($r('app.media.Arrow_bottom_filled'))
            .width(24)
        }
        .margin({ left: 16, right: 16 })
        .borderRadius(20)
        .backgroundColor($r('sys.color.background_tertiary'))
        .padding({
          top: 8,
          bottom: 8,
          left: 16,
          right: 8
        })
        .onClick(() => {
          this.pathStack.pushPath({ name: 'CitySelect' })
        })
      }
      .margin({
        top: 8,
        bottom: 8
      })
      .height(40)
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Scroll(this.scroller) {
        Column() {
          // 轮播图
          this.homeAdvBuilder()

          // 运动类别
          this.sportTypesBuilder()

          // 卡项
          this.cardListBuilder()

          // 课程
          this.courseListBuilder()

          // 健身房环境
          this.clubEnvironmentBuilder()
        }
        .margin({ left: 16, right: 16 })
      }
      .padding({ bottom: 56 })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.main_background_color'))
  }
}