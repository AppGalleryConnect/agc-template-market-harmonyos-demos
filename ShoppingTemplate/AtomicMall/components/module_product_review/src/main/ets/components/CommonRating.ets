import { MyRatingStyle } from 'module_ui_base';
import { Constants } from '../commons/Constants';

@ComponentV2
export struct CommonRating {
  @Param
  isIndicator: boolean = false
  @Param
  rating: number = 0
  @Param
  starSize: number = 20
  @Param
  label: string = '';
  @Event
  handleChange: (rating: number) => void

  @Computed
  get desc() {
    return Constants.RATING_LABEL[this.rating - 1] ?? '';
  }

  build() {
    Row() {
      if (this.label) {
        Text(this.label)
          .fontColor($r('app.color.font_color_level1'))
          .margin({ right: $r('app.float.space_l') })
          .fontSize($r('app.float.font_size_14'));
      }
      this.buildRating()
      Blank();
      Text(this.desc).fontSize($r('app.float.font_size_14')).fontColor($r('app.color.font_color_level2'));
    }
    .width('100%')
    .margin({
      bottom: $r('app.float.space_s'),
    });
  }

  @Builder
  buildRating() {
    Row() {
      Rating({ rating: this.rating, indicator: this.isIndicator })
        .contentModifier(new MyRatingStyle(this.starSize))
        .onChange((value) => {
          this.handleChange?.(value)
        })
    }.layoutWeight(1).height(this.starSize)
  }
}
