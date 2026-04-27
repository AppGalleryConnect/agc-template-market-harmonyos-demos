import { PlayerSliderModel, SliderType } from '../models/PlayerSliderModel';

@ComponentV2
export struct PlayerSlider {
  @Param type: SliderType = SliderType.VOLUME
  @Consumer() playerSliderModel: PlayerSliderModel = new PlayerSliderModel();

  @Monitor('playerSliderModel')
  onSliderModelChange() {
    this.getIcon()
  }
  
  getIcon(): ResourceStr {
    if (this.type === SliderType.VOLUME) {
      if (this.playerSliderModel.volume === 0) {
        return $r('app.media.ic_mute')
      } else {
        return $r('app.media.ic_volume')
      }
    } else if (this.type === SliderType.BRIGHT) {
      return $r('app.media.ic_bright')
    }
    return ''
  }

  build() {
    Row() {
      Stack() {
        Row()
          .width('100%')
          .height('100%')
          .backgroundColor(Color.Black)
          .opacity($r('sys.float.ohos_id_alpha_content_secondary'))
          .borderRadius('50%')

        Row({space: 10}) {
          Image(this.getIcon())
            .width(16)
            .height(16)
            .fillColor(Color.White)

          Slider({
            value: this.type === SliderType.VOLUME ? this.playerSliderModel.volume : this.playerSliderModel.bright,
            step: 0.01,
            min: 0,
            max: 1,
            style: SliderStyle.NONE
          })
            .layoutWeight(1)
            .trackColor('#94fffefe')
            .trackThickness(2)
            .selectedColor('#beffffff')
            .selectedBorderRadius(2)
            .enabled(false)
        }
        .width('100%')
        .height('100%')
        .borderRadius('50%')
        .clip(true)
        .padding({ left: 16, right: 16 })
      }
      .width('100%')
      .height('100%')
    }
    .width(220)
    .height(30)
  }
}