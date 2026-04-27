import { ColorPanPicker } from '../components/ColorPanPicker';
import { CanvasPen, canvasPenList, CommonConstants } from '../constants/CommonConstants';
import { DrawBoardVM } from '../viewmodel/DrawVM';
import { ToolsNav } from './ToolsNav';

@ComponentV2
export struct PaintContent {
  @Local drawBoardVM: DrawBoardVM = DrawBoardVM.instance

  setCanvasPen(id: ResourceStr, index: number) {
    switch (id) {
      case 'ballpoint':
        this.drawBoardVM.drawWithBallpointPen(index)
        break
      case 'marker':
        this.drawBoardVM.drawWithMarkerPen(index)
        break
      case 'pencil':
        this.drawBoardVM.drawWithPencilPen(index)
        break
      case 'fountain':
        this.drawBoardVM.drawWithFountainPen(index)
        break
      case 'laser':
        this.drawBoardVM.drawWithSprayPen(index)
        break
      default:
        this.drawBoardVM.drawWithBallpointPen(index)
    }
  }

  aboutToAppear(): void {
    this.setCanvasPen(canvasPenList[this.drawBoardVM.penSelectIndex].id, this.drawBoardVM.penSelectIndex)
  }

  build() {
    Column() {
      Column() {
        ToolsNav({title: $r('app.string.brash')})

        Row() {
          ForEach(canvasPenList, (item: CanvasPen, index: number) => {
            Column() {
              Stack() {
                Image(this.drawBoardVM.penSelectIndex === index ? item.select : item.unSelect)
                  .width(13)
                  .height(21)
                Button({ type: ButtonType.Normal })
                  .width($r('app.float.back_width'))
                  .height($r('app.float.back_width'))
                  .borderRadius($r('sys.float.corner_radius_level7'))
                  .backgroundColor(Color.Transparent)
                  .onClick(() => {
                    this.setCanvasPen(item.id, index)
                  })
              }
              .width($r('app.float.image_width'))
              .height($r('app.float.image_width'))
              .borderRadius('50%')
              .backgroundColor(this.drawBoardVM.penSelectIndex === index ? $r('app.color.theme_color') :
              $r('sys.color.background_secondary'))

              Text(item.name)
                .fontSize($r('app.float.font_size'))
                .fontColor(this.drawBoardVM.penSelectIndex === index ? $r('app.color.theme_color') :
                $r('sys.color.mask_secondary'))
                .margin({ top: $r('app.float.margin_top') })
            }
          },(item: CanvasPen, index: number) => index + JSON.stringify(item))
        }
        .width(CommonConstants.ONE_HUNDRED_PERCENT)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .alignItems(HorizontalAlign.Start)
      .width(CommonConstants.ONE_HUNDRED_PERCENT)
      .margin({ bottom: $r('app.float.title_bottom') })

      Divider()
      ColorPanPicker({
        selectColor: this.drawBoardVM.color,
        alpha: this.drawBoardVM.alpha,
        isMark: this.drawBoardVM.penSelectIndex === 1,
        isShowAlpha: this.drawBoardVM.penSelectIndex === 1,
        percent: this.drawBoardVM.percent,
        onSelectChange: (color: string) => {
          this.drawBoardVM.color = color;
          this.drawBoardVM.ToggleThicknessColor();
        },
        onAlphaChange: (value: number) => {
          if (this.drawBoardVM.penSelectIndex === 1) {
            this.drawBoardVM.alpha = value / 100;
            this.drawBoardVM.percent = value.toFixed(0);
            this.drawBoardVM.ToggleThicknessColor();
          }
        },
      })

      Column() {
        Text($r('app.string.thicknesses'))
          .textAlign(TextAlign.Start)
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: $r('app.float.margin_bottom') })
        Column() {
          Slider({
            value: this.drawBoardVM.strokeWidth,
            min: CommonConstants.ONE,
            max: CommonConstants.TWENTY_ONE,
            style: SliderStyle.InSet,
          })
            .width('100%')
            .minResponsiveDistance(CommonConstants.ONE)
            .onChange((value: number, _mode: SliderChangeMode) => {
              this.drawBoardVM.strokeWidth = value;
              this.drawBoardVM.ToggleThicknessColor();
            })
          Row() {
            Text('细')
              .fontSize(14)
              .fontColor($r('sys.color.font_secondary'))
            Text('粗')
              .fontSize(14)
              .fontColor($r('sys.color.font_secondary'))
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width(CommonConstants.ONE_HUNDRED_PERCENT)
      }
      .alignItems(HorizontalAlign.Start)
      .width(CommonConstants.ONE_HUNDRED_PERCENT)
    }
    .width(CommonConstants.ONE_HUNDRED_PERCENT)
    .padding({
      bottom: 36,
      left: 16,
      right: 16,
      top: 16,
    })
  }
}