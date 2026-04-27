import { Constants, RouterMap, WindowParam, WindowPopManager } from 'common'
import { CommonConstants } from '../constants/Constant'
import { backgroundGroupList } from '../constants/StyleConstants'
import { GroupTab } from './GroupTab'
import { SheetTitle } from './SheetTitle'
import { PhotoUtils } from '../utils/PhotoUtils';
import { DrawingBoardVM } from '../viewmodel/DrawingBoardVM'
import { ColorGrid } from './ColorGrid'
import { phoneRouterControl } from 'oh_router'
import { ImageCropPageBuilder } from '../views/ImageCropPage'
import { ImageRouterParams } from '../types/StyleType'
import { WindowBuilder } from './WindowBuilder'

@Builder
export function BackgroundMenuContentBuilder(param: WindowParam) {
  BackgroundMenuContent({ param: param })
}

@ComponentV2
export struct BackgroundMenuContent {
  @Local drawingBoardVM: DrawingBoardVM = DrawingBoardVM.instance
  @Param @Require param: WindowParam
  @Local backgroundSelectType: string = 'SolidColor'

  aboutToAppear(): void {
    this.backgroundSelectType = this.drawingBoardVM.backgroundSelectType
  }

  @Builder
  AlbumBuilder() {
    Column() {
      Image(this.drawingBoardVM.canvasBackgroundImage || $r('app.media.background_album_example'))
        .width(150)
        .height(150)
        .objectFit(ImageFit.Cover)
        .margin({ top: 32, bottom: 24 })
      Button($r('app.string.button_select_from_album'))
        .fontSize($r('sys.float.Body_S'))
        .borderRadius($r('sys.float.corner_radius_level10'))
        .backgroundColor('#FFED6F21')
        .width('100%')
        .height(40)
        .onClick(async () => {
          const uris = await PhotoUtils.selectPhoto()
          WindowPopManager.destroyWindow(CommonConstants.WINDOW_NAME)
          phoneRouterControl.jumpPage({
            pageName: RouterMap.IMAGE_CROP,
            param: {
              uri: uris[0]
            } as ImageRouterParams,
            builder: wrapBuilder(ImageCropPageBuilder),
          })
        })
        .margin({ bottom: 49 })
    }
    .padding({ left: 16, right: 16 })
    .width(Constants.FULL_SIZE)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  SolidColorBuilder() {
    ColorGrid({
      colorList: CommonConstants.COLOR_ARR,
      selectColor: this.drawingBoardVM.canvasColor,
      gridHeight: 295,
      colorChange: (color: string) => {
        this.drawingBoardVM.canvasColor = color
        this.drawingBoardVM.setBackgroundType('SolidColor')
        WindowPopManager.destroyWindow(CommonConstants.WINDOW_NAME)
      }
    })
  }

  @Builder
  GradientBuilder() {
    Column() {
      Grid() {
        ForEach(CommonConstants.LINEAR_GRADIENT_ARR, (gradient: Array<[ResourceColor, number]>) => {
          GridItem() {
            Column() {
              Column()
                .width(70)
                .height(70)
                .borderRadius($r('sys.float.corner_radius_level8'))
                .linearGradient({
                  direction: GradientDirection.Bottom,
                  colors: gradient
                })
            }
            .width(76)
            .height(76)
            .padding(3)
            .border({
              width: this.drawingBoardVM.gradientColor[0] === gradient[0] ? 1 : 0,
              radius: $r('sys.float.corner_radius_level9'),
              color: $r('app.color.theme_color')
            })
            .onClick(() => {
              this.drawingBoardVM.gradientColor = gradient
              this.drawingBoardVM.setBackgroundType('Gradient')
              WindowPopManager.destroyWindow(CommonConstants.WINDOW_NAME)
            })
          }
        }, (gradient: Array<[ResourceColor, number]>,index:number) => index.toString())
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr 1fr')
      .columnsGap(6)
      .rowsGap(8)
    }
    .width(Constants.FULL_SIZE)
    .height(295)
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  render() {
    Column() {
      SheetTitle({ title: '背景' })
      GroupTab({
        groupList: backgroundGroupList,
        showGroup: this.backgroundSelectType,
        changeGroup: (group) => {
          this.backgroundSelectType = group
        }
      })
        .margin({bottom:8})

      Column() {
        if (this.backgroundSelectType === 'Album') {
          this.AlbumBuilder()
        } else if (this.backgroundSelectType === 'SolidColor') {
          this.SolidColorBuilder()
        } else if (this.backgroundSelectType === 'Gradient') {
          this.GradientBuilder()
        }
      }
      .backgroundColor(Color.White)
      .width(Constants.FULL_SIZE)
      .padding({ left: 16, right: 16 })
    }
    .backgroundColor(Color.White)
    .width(Constants.FULL_SIZE)
    .borderRadius({ topLeft: $r('sys.float.corner_radius_level16'), topRight: $r('sys.float.corner_radius_level16') })
  }

  build() {
    WindowBuilder({
      sheetBuilder: () => {
        this.render()
      }
    })
  }
}
