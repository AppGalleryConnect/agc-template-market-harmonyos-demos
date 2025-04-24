@ComponentV2
export struct TitleBar {
  @Param leftImgResID: string = 'app.media.ic_close';
  @Event hide: () => void = () => {
  };
  @Param titleResID: string = '';
  @Param rightImgResID: string = 'app.media.ic_check_mask';
  @Event callback: () => void = () => {
  };
  @Param bgColor: string | Color = '';

  build() {
    List() {
      ListItem() {
        Row() {
          Column() {
            Image($r(this.leftImgResID)).height(18)
              .width(18)
          }
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#EEEEEE')
          .height(40)
          .width(40)
          .borderRadius(20)
          .visibility(this.leftImgResID === '' ? Visibility.None : Visibility.Visible)

          Blank().width('2%')

          Text(this.titleResID === '' ? '' : $r(this.titleResID))
            .fontSize(20).fontWeight(FontWeight.Bold)
        }
      }.align(Alignment.Start).onClick(() => {
        this.hide();
      }).height(40).width('70%')

      ListItem() {
        Column() {
          Column() {
            Image($r(this.rightImgResID)).height(18)
              .width(18)
          }
          .backgroundColor('#EEEEEE')
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .height(40)
          .width(40)
          .borderRadius(20)
          .onClick(() => {
            this.callback();
          })
        }.alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .visibility(this.rightImgResID === '' ? Visibility.None : Visibility.Visible)
      }.align(Alignment.End).height(40).width('30%')
    }
    .scrollBar(BarState.Off)
    .backgroundColor(this.bgColor === '' ? '' : this.bgColor)
    .listDirection(Axis.Horizontal)
    .padding({top: 10})
    .height(56)
    .width('100%')
  }
}