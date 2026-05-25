import { MockService,
  VIDEO_URL,
  BreakpointNameEnum,
  BreakpointModel,
  GridSettingInfo,
  ScreenPropStorage,
  AccountUpdate,
  Logger} from 'external_interactions';
import { window } from '@kit.ArkUI';
import { TitleBar } from 'module_recharge/src/main/ets/components/TitleBar';
import { AppStorageV2, display } from '@kit.ArkUI';

const TAG = '[ClubEnvironmentDetail]';

@ComponentV2
export struct ClubEnvironmentDetail {
  @Local screenPropStorage: ScreenPropStorage =
    AppStorageV2.connect(ScreenPropStorage, 'ScreenPropStorage', () => new ScreenPropStorage())!
  @Local topRectHeight: number = this.screenPropStorage.topRectHeight;
  @Local bottomRectHeight: number = this.screenPropStorage.bottomRectHeight;
  @Param @Once pathStack: NavPathStack = new NavPathStack();
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  controller: VideoController = new VideoController()
  @Consumer() isVideoFullscreen: boolean = false;

  @Computed
  get gridSetting() {
    // 获取当前屏幕旋转角度（0-3 分别对应 0°、90°、180°、270°）
    let rotation: number = display.getDefaultDisplaySync().rotation;
    const gridSettingInfo: GridSettingInfo  = {
      template: '1fr',
      colGap: 8,
      rowGap: 8,
    }
    if (BreakpointNameEnum.MD === this.breakPointModel.currentBreakpoint) {
      gridSettingInfo.template = '1fr 1fr'
      gridSettingInfo.colGap = 12
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

  @Builder
  videoBuilder() {
    Column() {
      Video({
        src: VIDEO_URL,
        previewUri: $r('app.media.material9'),
        controller: this.controller,
        currentProgressRate: PlaybackSpeed.Speed_Forward_1_00_X
      })
        .width('100%')
        .height(148)
        .borderRadius({ topLeft: 16, topRight: 16 })
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
      Text('力健健身房配备齐全的器械设备，其中包括力量训练器械、有氧运动器械、功能性训练器械以及高科技健身设备等，满足不同健身需求。')
        .width('100%')
        .fontSize(12)
        .borderRadius({ bottomLeft: 16, bottomRight: 16 })
        .backgroundColor(Color.White)
        .padding({
          top: 8,
          right: 12,
          bottom: 16,
          left: 12
        })
    }
    .width('100%')
    .margin({ bottom: 12 })
  }

  @Builder
  imageBuilder(imageStr: string, text: string) {
    Column() {
      Image($r(imageStr))
        .width('100%')
        .height(148)
        .borderRadius({ topLeft: 16, topRight: 16 })
      Text(text)
        .width('100%')
        .fontSize(12)
        .borderRadius({ bottomLeft: 16, bottomRight: 16 })
        .backgroundColor(Color.White)
        .padding({
          top: 8,
          right: 12,
          bottom: 16,
          left: 12
        })
    }
    .width('100%')
    .margin({ bottom: 12 })
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          title: '俱乐部环境', onBackClick: () => {
            this.pathStack.pop()
          }
        })
          .margin({ left: 16, right: 16 })
        Scroll() {
          Grid() {
            GridItem() {
              this.videoBuilder()
            }
            GridItem() {
              this.imageBuilder('app.media.material5',
                '有氧训练；专业的有氧训练器材，宽敞的有氧训练场地，可以让你安全放松的完成一场有益身心的有氧训练。')
            }
            GridItem() {
              this.imageBuilder('app.media.material11',
                '力量训练；适当的力量训练，可以增强身体肌肉含量，保证身体足够蛋白质，提高免疫力，我们的力量区有优秀的教练，专业的器材。')
            }
            GridItem() {
              this.imageBuilder('app.media.material8',
                '力量训练；适当的力量训练，可以增强身体肌肉含量，保证身体足够蛋白质，提高免疫力，我们的力量区有优秀的教练，专业的器材。')
            }
          }
          .width('100%')
          .columnsTemplate(this.gridSetting.template)
          .columnsGap(this.gridSetting.colGap)
          .rowsGap(this.gridSetting.rowGap)
        }
        .margin({ left: 16, right: 16 })
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
        .layoutWeight(1)
      }.height('100%')
    }
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx?.pathStack
    })
    .hideTitleBar(true)
    .backgroundColor($r('app.color.main_background_color'))
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight),
      bottom: this.getUIContext().px2vp(this.bottomRectHeight) })
  }
}

@ComponentV2
export struct ImageBuilder {
  @Param imageStr: string = ''
  @Param text: string = ''

  build() {
    Column() {
      Image($r(this.imageStr))
        .width('100%')
        .height(148)
        .borderRadius({ topLeft: 16, topRight: 16 })
      Text(this.text)
        .width('100%')
        .fontSize(12)
        .borderRadius({ bottomLeft: 16, bottomRight: 16 })
        .backgroundColor(Color.White)
        .padding({
          top: 8,
          right: 12,
          bottom: 16,
          left: 12
        })
    }
    .width('100%')
    .margin({ bottom: 12 })
  }
}