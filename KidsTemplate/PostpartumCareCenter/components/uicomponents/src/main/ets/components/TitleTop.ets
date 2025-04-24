@Preview
@ComponentV2
export struct TitleTop {
  @Param @Require title: ResourceStr;

  build() {
    Row() {
      Text(this.title)
        .fontSize($r('app.string.font_size_24'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Bold)
        .fontColor('rgba(0,0,0,0.90)');
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Start)
    .padding({ left: $r('app.string.padding_16') });
  }
}