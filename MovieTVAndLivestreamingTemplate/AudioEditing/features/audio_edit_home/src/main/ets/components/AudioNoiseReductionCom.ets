import { CalculateUtil } from 'audio_common';


@ComponentV2
export struct AudioNoiseReductionCom {
  @Local speed: string = '1';
  @Event getSpeedValue: (speed: string) => void = () => {
  }
  @Local step: string = '1'
  @Local min: number = 1
  @Local max: number = 97
  @Local calculateUtil: CalculateUtil = new CalculateUtil()
  @Local typeList: Array<string> = ['无', '一般', '录音中', '演讲', '语音']
  @Local selectedIndex: number = 0

  aboutToAppear(): void {

  }

  typeClick(index: number) {
    this.selectedIndex = index
    switch (this.selectedIndex) {
      case 0:
        this.speed = '1'
        break;
      case 1:
        this.speed = '20'
        break;
      case 2:
        this.speed = '45'
        break;
      case 3:
        this.speed = '65'
        break
      case 4:
        this.speed = '80'
        break;
      default:
    }
    this.getSpeedValue(this.speed)
  }

  build() {

    Column() {
      Column() {
        Text('自动降噪：' + this.speed + 'DB（DB)')
          .fontSize(14)
          .fontColor($r('sys.color.font_on_primary'))
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({
        bottom: 13
      })

      Row() {
        Text('(Db)')
          .fontSize(12)
          .fontColor($r('sys.color.font_on_primary'))

        Row() {


          Slider({
            value: Number(this.speed),
            min: this.min,
            max: this.max,
            style: SliderStyle.OutSet,
            step: Number(this.step),
          })
            .blockColor('#01FCEA')
            .trackColor($r('sys.color.comp_background_secondary'))
            .selectedColor($r('sys.color.comp_background_emphasize'))
            .showTips(false)
            .onChange((value: number, mode: SliderChangeMode) => {
              this.speed = value.toFixed(0);
              this.selectedIndex = -1
              this.getSpeedValue(this.speed.toString())
            })
        }
        .layoutWeight(1)
        .padding({
          left: 16,
          right: 16
        })

      }
      .width('100%')

      Row() {
        Text('模型：')
          .fontSize(12)
          .fontColor($r('sys.color.font_on_primary'))

        Row() {
          ForEach(this.typeList, (item: string, index: number) => {
            Text(item)
              .fontSize(12)
              .textAlign(TextAlign.Center)
              .fontColor(this.selectedIndex === index ? '#000000' : '#FFFFFF')
              .backgroundColor(this.selectedIndex === index ? '#01FCEA' : '')
              .borderRadius(4)
              .padding({
                top: 8,
                bottom: 5
              })
              .width(50)
              .onClick(() => {
                this.typeClick(index)
              })
          }, (item: string) => JSON.stringify(item))

        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .margin({
        top: 23
      })
    }

  }
}
