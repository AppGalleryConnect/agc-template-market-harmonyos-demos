@ComponentV2
export struct CommonButton {
  @Param
  bgColor: ResourceColor = '#007dff';
  @Param
  title: string = '';
  @Param
  subTitle: string = '';
  @Param
  fullWidth: boolean = true;
  @Event
  handleClick?: () => void = () => {
  };

  build() {
    Row() {
      Button(this.title) {
        Column() {
          Text(this.title)
            .fontSize(32)
            .fontWeight(500);
          if (this.subTitle) {
            Text(this.subTitle)
              .fontSize(20)
              .fontColor('#99ffffff');
          }
        };
      }
      .width(this.fullWidth ? '100%' : 'auto')
      .padding({
        left: 16,
        right: 16,
      })
      .height('88lpx')
      .backgroundColor(this.bgColor)
      .fontColor('#ffffff')
      .onClick(() => {
        this.handleClick?.();
      });
    }
    .padding({
      left: 8,
      right: 8,
    });
  }
}