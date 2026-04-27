import { HSBColorPicker, HSBColorPickerLayout, rgb2hex } from '@keke/color-picker';
import { image } from '@kit.ImageKit';
import { ColorGlobalContext } from '../util/ColorGlobalContext';

@ComponentV2
export struct ColorSelector {
  //颜色
  @Once
  @Param color: string = '#ffffff';
  @Param drawingId: string = '';
  @Param touchX: number = 0
  @Param touchY: number = 0
  @Param RGB: number[] = []
  @Event RGBChange: (RGB: number[]) => void = () => {
  }
  @Event selectColorChange: (color: string) => void = () => {
  }
  @Event colorChange: (color: string) => void = (color: string) => {
  }
  @Event colorSampling: () => void = () => {
  }
  @Local pixelMap: image.PixelMap | undefined = undefined

  @Monitor('touchX','touchY')
  async colorSamplingChange() {
    const positionX = this.getUIContext().vp2px(this.touchX)
    const positionY = this.getUIContext().vp2px(this.touchY)
    const area: image.PositionArea = {
      pixels: new ArrayBuffer(4),
      offset: 0,
      stride: 4,
      region: { size: { height: 1, width: 1 }, x: positionX, y: positionY }
    };
    try {
      if (this.pixelMap !== undefined) {
        this.pixelMap.readPixelsSync(area)
        let bgraData = new Uint8Array(area.pixels);
        // 提取 RGBA 四个通道的值
        const b = bgraData[0];
        const g = bgraData[1];
        const r = bgraData[2];
        const alpha = bgraData[3];
        this.RGBChange([r, g, b])
        const hex = rgb2hex(r, g, b)
        const pureHex = hex.replace('#', '').slice(0, 6);
        const alphaHex = Math.max(0, Math.min(255, alpha)).toString(16).padStart(2, '0');
        this.color = `#${alphaHex}${pureHex}`
        this.selectColorChange(`#${pureHex}`)
      } else {
        this.color = '#ffffff'
      }
    } catch (err) {
    }
  }

  build() {
    Column() {
      HSBColorPicker({
        layout: HSBColorPickerLayout.COLUMN,
        color: this.color,
        gutter: 16,
        radius: 12,
        showAlpha: true,
        onChange: (value: string) => {
          this.color = value
        }
      })
        .height(292)
        .width('100%')
      Divider()
        .strokeWidth('2vp')
        .width('100%')
        .margin({ top: 12, bottom: 13 })


      Row() {
        Row() {
          Circle()
            .width(36)
            .height(36)
            .fill(this.color)
          if (this.drawingId) {
            Row() {
              Image($r('app.media.ColorSucker'))
                .width(18)
                .height(18)
                .objectFit(ImageFit.Cover)
                .onClick(async () => {
                  this.pixelMap = await ColorGlobalContext.getUIContext().getComponentSnapshot()
                    .get(this.drawingId, { scale: 1, waitUntilRenderFinished: true })
                  this.colorSampling()
                })
            }
            .padding(3)
            .height(36)
            .alignItems(VerticalAlign.Center)
            .margin({ left: 16 })
          }
        }

        Row() {
          Text('Hex: #')
            .fontSize(14)
            .lineHeight(17)
            .fontColor(Color.Black)
            .opacity(0.6)
            .textAlign(TextAlign.Start)
          Row() {
            Text(this.color.replace(/#/g, ''))
              .fontSize(12)
              .lineHeight(15)
              .fontColor(Color.Black)
              .opacity(0.9)
              .textAlign(TextAlign.Start)
          }
          .margin({ left: 4 })
          .padding({
            top: 3,
            bottom: 5,
            right: 10,
            left: 10
          })

          .height(24)
          .borderRadius($r('sys.float.corner_radius_level4'))
          .backgroundColor('#0D000000')

        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .height(36)

      Button('确定')
        .fontSize($r('sys.float.Body_S'))
        .borderRadius($r('sys.float.corner_radius_level10'))
        .backgroundColor('#FFED6F21')
        .width('100%')
        .height(40)
        .margin({ top: 31 })
        .onClick(() => {
          this.colorChange(this.color)
        })
    }
    .padding({ left: 24, right: 24 })
    .width('100%')
  }
}
