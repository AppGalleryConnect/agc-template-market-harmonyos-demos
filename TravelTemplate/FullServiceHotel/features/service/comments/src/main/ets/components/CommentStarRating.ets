import { Constants, RatingLayoutType } from '../constants';
import { CommentStar } from './CommentStar';

@ComponentV2
export struct CommentStarRating {
  @Param rating: number = 1;
  @Param starSize: number = 30;
  @Param layoutType: RatingLayoutType = RatingLayoutType.HORIZONTAL;
  @Param label: string = '';
  @Event $rating: (value: number) => void = (value: number) => {
  };
  @Local starList: boolean[] = [false, false, false, false, false];

  aboutToAppear(): void {

  }

  @Computed
  get desc() {
    return Constants.RATING_LABEL[this.rating - 1] ?? '';
  }

  handleStarClick(value: number) {
    this.$rating(value + 1);
  }

  build() {
    Column() {
      if (this.layoutType === RatingLayoutType.VERTICAL) {
        Column() {
          CommentStar({
            starNum: this.rating,
            starSize: this.starSize,
            isUncheckedShow: true,
            handleStarClick: (value) => {
              this.handleStarClick(value);
            },
          });
          Text(this.desc + ' ').fontSize($r('app.string.font_size_28')).fontColor($r('app.color.font_color_level1')).margin({ top: $r('app.string.margin_s') });
        };
      } else {
        Flex({
          alignItems: ItemAlign.Center,
        }) {
          if (this.label) {
            Text(this.label).fontColor($r('app.color.font_color_level1')).margin({ right: $r('app.string.margin_m') }).fontSize($r('app.string.font_size_28'));
          }
          CommentStar({
            starNum: this.rating,
            starSize: this.starSize,
            isUncheckedShow: true,
            handleStarClick: (value) => {
              this.handleStarClick(value);
            },
          });
          Blank();
          Text(this.desc).fontSize($r('app.string.font_size_28')).fontColor($r('app.color.font_color_level2'));
        }
        .width('100%')
        .margin({
          bottom: $r('app.string.margin_s'),
        });
      }
    }
    .width('100%');
  }
}
