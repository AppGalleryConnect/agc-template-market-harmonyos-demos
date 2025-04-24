@ComponentV2
export struct DeviceBaseInfoView {
  @Require @Param image: ResourceStr;
  @Require @Param name: string;

  build() {
    Column() {
      Column() {
        Image(this.image)
          .objectFit(ImageFit.Contain)
          .size({ width: 100 });
      }
      .justifyContent(FlexAlign.Center)
      .height(100)
      .width(100);

      Text(this.name)
    };
  }
}
