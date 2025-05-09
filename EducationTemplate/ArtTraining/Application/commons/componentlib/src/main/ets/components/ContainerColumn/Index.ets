/* eslint-disable */
import { CommonDivider } from '../CommonDivider/Index';

@ComponentV2
export struct ContainerColumn {
  @Param title: string = '';
  @Param subTitle: string = '';
  @BuilderParam customBuilderParam: () => void;

  build() {
    Column() {
      if (this.title) {
        Row() {
          Text(this.title).titleStyle();
          Text(this.subTitle).subTitleStyle();
        }
        .width($r('app.string.width_percent_full'));

        CommonDivider();
      }

      this.customBuilderParam();
    }
    .alignItems(HorizontalAlign.Start)
    .margin({bottom:$r('app.string.margin_l')})
    .backgroundColor($r('app.color.system_color_background_white'))
    .borderRadius($r('app.string.border_radius_16'))
    .width($r('app.string.width_percent_full'))
    .padding($r('app.string.padding_m'))
    .height('auto')

  }
}

@Extend(Text)
function titleStyle() {
  .fontSize($r('app.string.font_size_16'))
  .fontWeight(FontWeight.Medium)
  .layoutWeight(1)
  .fontColor($r('app.color.font_color_level1'));
}

@Extend(Text)
function subTitleStyle() {
  .fontSize($r('app.string.font_size_12'))
  .fontColor($r('app.color.font_color_level2'));
}