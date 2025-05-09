import { RouterModule } from 'commonlib'


export enum BackButtonType {
  COMMON,
  INVERT,
}

@ComponentV2
export struct CommonHeader {
  @Param backButtonType: BackButtonType = BackButtonType.COMMON;
  @Param title: string = '';
  @Param transparent: boolean = false;
  private topBannerHeight: number = 56;

  @Computed
  get showBackButton() {
    return Boolean(RouterModule.size() > 0);
  }

  build() {
    Row() {
      if (this.showBackButton) {
        Image(this.backButtonType === BackButtonType.COMMON ? $r('app.media.ic_back_common') :
        $r('app.media.ic_back_invert'))
          .width('24vp')
          .margin({ right: $r('app.string.margin_4') })
          .onClick(() => {
            RouterModule.pop();
          })
      }
      Text(this.title)
        .fontSize($r('app.string.font_size_24'))
        .fontColor('rgba(0, 0, 0, 0.9)')
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .padding({ left: $r('app.string.padding_8') })
    .backgroundColor(this.transparent ? Color.Transparent : Color.White)
    .justifyContent(FlexAlign.Start)
    .height(this.topBannerHeight)
  }
}