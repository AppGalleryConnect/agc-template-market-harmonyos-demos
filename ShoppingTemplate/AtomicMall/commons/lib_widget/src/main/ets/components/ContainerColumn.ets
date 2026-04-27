@ComponentV2
export struct ContainerColumn {
  @Param title: string = '';
  @Param subTitle: string = '';
  @Param bottomGap: boolean = true
  @BuilderParam customBuilderParam: () => void = this.buildEmpty;

  build() {
    Column() {
      if (this.title) {
        Row() {
          Text(this.title).titleStyle();
          Text(this.subTitle).subTitleStyle();
        }
        .justifyContent(FlexAlign.Start)
        .width($r('app.string.size_percent_full'));

        Divider()
          .margin({ top: $r('app.float.space_m'), bottom: $r('app.float.space_m') })
          .color($r('sys.color.comp_divider'))
      }

      this.customBuilderParam();
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .margin({ bottom: this.bottomGap ? $r('app.float.space_m') : 0 })
    .backgroundColor($r('app.color.background_color_primary'))
    .borderRadius($r('app.float.border_radius_l'))
    .width($r('app.string.size_percent_full'))
    .padding($r('app.float.space_m'))
    .height('auto')
  }

  @Builder
  buildEmpty() {
  }
}

@Extend(Text)
function titleStyle() {
  .fontSize($r('app.float.font_size_16'))
  .fontWeight(FontWeight.Medium)
  .layoutWeight(1)
  .fontColor($r('app.color.font_color_level1'));
}

@Extend(Text)
function subTitleStyle() {
  .fontSize($r('app.float.font_size_12'))
  .fontColor($r('app.color.font_color_level2'));
}