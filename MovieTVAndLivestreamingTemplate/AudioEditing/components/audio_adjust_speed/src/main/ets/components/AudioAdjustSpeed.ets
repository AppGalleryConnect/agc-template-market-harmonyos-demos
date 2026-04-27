import { CalculateUtil } from 'audio_common';


@ComponentV2
export struct AudioAdjustSpeedComponent {
  @Local speed: string = '1.0';
  @Event getSpeedValue: (value: string) => void = () => {
  }
  @Local calculateUtil:CalculateUtil=new CalculateUtil()

  build() {

      Column() {
        Column() {
          Text('音速：' )
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_on_primary'))
          Text( '+' + this.speed.toString())
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_on_primary'))
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({
          bottom: 0
        })
        .offset({
          top:10
        })

        Row() {
          Image($r('app.media.remove'))
            .width(16)
            .height(16)
            .objectFit(ImageFit.Cover)
            .onClick(() => {
              if (this.speed === '0.5') {
                return
              }
              this.speed = this.calculateUtil.calResult(this.speed.toString(), '0.1', '-').toFixed(1)
              this.getSpeedValue(this.speed)
            })
          Row() {


            Slider({
              value: Number(this.speed),
              min: 0.5,
              max: 2,
              style: SliderStyle.OutSet,
              step: 0.1,
            })
              .blockColor('#01FCEA')
              .trackColor('rgba(255,255,255,0.1)')
              .selectedColor($r('sys.color.comp_background_emphasize'))
              .showTips(false)
              .onChange((value: number, mode: SliderChangeMode) => {
                this.speed = value.toFixed(1);
                this.getSpeedValue(this.speed)
              })
          }
          .layoutWeight(1)
          .padding({
            left: 16,
            right: 16
          })


          Image($r('app.media.add'))
            .width(16)
            .height(16)
            .objectFit(ImageFit.Cover)
            .onClick(() => {
              if (this.speed === '2.0') {
                return
              }
              this.speed = this.calculateUtil.calResult(this.speed.toString(), '0.1', '+').toFixed(1)
              this.getSpeedValue(this.speed)
            })
        }
        .width('100%')

      }

  }
}
