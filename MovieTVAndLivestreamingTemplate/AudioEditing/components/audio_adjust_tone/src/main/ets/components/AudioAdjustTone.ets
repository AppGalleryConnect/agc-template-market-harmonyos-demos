import { CalculateUtil } from 'audio_common';


@ComponentV2
export struct AudioAdjustToneComponent {
  @Local speed: string = '0';
  @Event getSpeedValue: (value: string) => void = () => {
  }
  @Local step: string = '50'
  @Local currentValue: number = 0
  @Require @Param min: number
  @Require @Param max: number
  @Require @Param currentSpeed: number
  @Local calculateUtil: CalculateUtil = new CalculateUtil()

  aboutToAppear(): void {
    this.speed = this.currentSpeed.toString()
  }

  build() {

    Column() {
      Column() {
        Text('音调：' + (this.currentValue < 0 ? '' : '+') + this.currentValue + '赫兹（Hz)')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_on_primary'))
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({
        bottom: 13
      })

      Row() {
        Image($r('app.media.remove'))
          .width(16)
          .height(16)
          .objectFit(ImageFit.Cover)
          .onClick(() => {
            if (this.speed === this.min.toString()) {
              return
            }
            this.speed = this.calculateUtil.calResult(this.speed.toString(), this.step, '-').toFixed(0)
            this.currentValue = Number(this.speed) - this.currentSpeed
            this.getSpeedValue(this.speed)
          })
        Row() {


          Slider({
            value: Number(this.speed),
            min: this.min,
            max: this.max,
            style: SliderStyle.OutSet,
            step: Number(this.step),
          })
            .blockColor('#01FCEA')
            .trackColor('rgba(255,255,255,0.1)')
            .selectedColor($r('sys.color.comp_background_emphasize'))
            .showTips(false)
            .onChange((value: number, mode: SliderChangeMode) => {
              this.speed = value.toFixed(0);
              this.currentValue = Number(this.speed) - this.currentSpeed
              this.getSpeedValue(this.currentValue.toString())
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
            if (this.speed === this.max.toString()) {
              return
            }
            this.speed = this.calculateUtil.calResult(this.speed.toString(), this.step, '+').toFixed(0)
            this.currentValue = Number(this.speed) - this.currentSpeed
            this.getSpeedValue(this.currentValue.toString())
          })
      }
      .width('100%')

    }

  }
}
