import { Constants, TValueType } from 'common'
import { OHPage, phoneRouterControl } from 'oh_router'
import { CommonConstants } from '../constants/Constant'
import { ImageRouterParams } from '../types/StyleType'
import { DrawingBoardVM } from '../viewmodel/DrawingBoardVM'
import { ImageCropVM } from '../viewmodel/ImageCropVM'

@Builder
export function ImageCropPageBuilder(params: TValueType) {
  ImageCropPage({ pageParams: params })
}

@ComponentV2
struct ImageCropPage {
  @Local drawingBoardVM: DrawingBoardVM = DrawingBoardVM.instance
  @Param pageParams: TValueType = null
  @Local imageCropVM: ImageCropVM = new ImageCropVM()

  aboutToAppear(): void {
    const param = this.pageParams as ImageRouterParams
    this.imageCropVM.init(
      param.uri,
      this.drawingBoardVM.context.width,
      this.drawingBoardVM.context.height
    )
  }

  @Builder
  Placeholder() {
    Column()
      .height(Constants.FULL_SIZE)
      .layoutWeight(1)
      .backgroundColor('#4D000000')
      .hitTestBehavior(HitTestMode.Transparent)
  }

  @Builder
  ColumnPlaceholder() {
    Column()
      .width(Constants.FULL_SIZE)
      .layoutWeight(1)
      .backgroundColor('#4D000000')
      .hitTestBehavior(HitTestMode.Transparent)
  }

  @Builder
  render() {
    Column() {
      Row() {
        Image($r('app.media.ic_image_cancel'))
          .width(40)
          .height(40)
          .onClick(() => {
            phoneRouterControl.popPage()
          })

        Text($r('app.string.image_crop'))
          .fontSize(20)
          .layoutWeight(1)
          .fontColor(Color.White)
          .textAlign(TextAlign.Start)
          .margin({ left: 8 })

        Image($r('app.media.ic_image_apply'))
          .width(40)
          .height(40)
          .onClick(async () => {
            await this.imageCropVM.getTargetImage()
            this.drawingBoardVM.canvasBackgroundImage = this.imageCropVM.targetImage
            this.drawingBoardVM.setBackgroundType('Album')
            phoneRouterControl.popPage()
          })
      }
      .padding({
        left: 16,
        right: 16,
        top: 8,
        bottom: 8
      })
      .backgroundColor(Color.Black)
      .alignItems(VerticalAlign.Center)
      .height(56)
      .zIndex(10)

      Stack() {
        Image(this.imageCropVM.imageUri)
          .width(Constants.FULL_SIZE)
          .height(Constants.FULL_SIZE)
          .objectFit(ImageFit.Contain)
          .scale({
            x: this.imageCropVM.scaleValue,
            y: this.imageCropVM.scaleValue,
            z: this.imageCropVM.scaleZ
          })
          .translate({
            x: this.imageCropVM.offsetX,
            y: this.imageCropVM.offsetY,
          })
          .gesture(
            GestureGroup(GestureMode.Exclusive,
              PanGesture()
                .onActionUpdate((event: GestureEvent) => {
                  this.imageCropVM.handleMove(event)
                })
                .onActionEnd(() => {
                  this.imageCropVM.handleEnd()
                }),
              PinchGesture({ fingers: 2 })
                .onActionStart(() => {
                  this.imageCropVM.handlePinchStart()
                })
                .onActionUpdate((event: GestureEvent) => {
                  this.imageCropVM.handlePinchUpdate(event.scale)
                })
                .onActionEnd(() => {
                  this.imageCropVM.handlePinchEnd()
                })
            )
          )
        Column() {
          this.ColumnPlaceholder()
          Row() {
            this.Placeholder()
            Column()
              .width(this.imageCropVM.cropBoxWidth)
              .height(this.imageCropVM.cropBoxHeight)
              .border({
                width: 2,
                color: Color.White,
                style: BorderStyle.Solid
              })
              .backgroundColor(Color.Transparent)
              .onAreaChange((oldArea, newArea) => {
                this.imageCropVM.cropBoxPositionX = Number(newArea.position.x)
              })
            this.Placeholder()
          }
          .height(this.imageCropVM.cropBoxHeight)
          .justifyContent(FlexAlign.Center)
          .hitTestBehavior(HitTestMode.Transparent)
          .onAreaChange((oldArea, newArea) => {
            this.imageCropVM.cropBoxPositionY = Number(newArea.position.y)
          })

          this.ColumnPlaceholder()
        }
        .hitTestBehavior(HitTestMode.Transparent)
        .width(Constants.FULL_SIZE)
        .height(Constants.FULL_SIZE)

      }
      .hitTestBehavior(HitTestMode.Transparent)
      .width(Constants.FULL_SIZE)
      .id(CommonConstants.CROP_AREA)
      .backgroundColor('#4D000000')
      .layoutWeight(1)
    }
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
    .backgroundColor(Color.Black)
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render()
      },
      useSafePadding: false
    })
  }
}