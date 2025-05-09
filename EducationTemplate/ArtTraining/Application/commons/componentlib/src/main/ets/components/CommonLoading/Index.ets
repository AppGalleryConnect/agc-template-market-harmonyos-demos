@ComponentV2
export struct CommonLoading {
  @Param loadingSize: Length = $r('app.integer.icon_size_32');

  build() {
    Column() {
      LoadingProgress().width(this.loadingSize).height(this.loadingSize);
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }
}