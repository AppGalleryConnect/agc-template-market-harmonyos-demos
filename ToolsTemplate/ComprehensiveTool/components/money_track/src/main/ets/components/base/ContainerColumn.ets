@ComponentV2
export struct ContainerColumn {
  @Param
  title: string = '';
  @Param
  alignStyle: HorizontalAlign = HorizontalAlign.Start;
  @BuilderParam customBuilderParam: () => void;

  build() {
    Column() {
      if (this.title) {
        Row() {
          Text(this.title).titleStyle();
        }
        .width($r('app.string.width_percent_full'));
      }

      this.customBuilderParam();
    }
    .alignItems(this.alignStyle)
    .margin({bottom:$r('app.string.space_l')})
    .backgroundColor($r('app.color.system_color_background_white'))
    .borderRadius(16)
    .width($r('app.string.width_percent_full'))
    .padding($r('app.string.space_m'))
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
