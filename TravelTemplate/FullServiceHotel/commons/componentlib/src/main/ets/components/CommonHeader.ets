import { RouterModule } from 'commonlib';


export enum BackButtonType {
  COMMON,
  INVERT,
}

@ComponentV2
export struct CommonHeader {
  @Param
  backButtonType: BackButtonType = BackButtonType.COMMON;
  @Param
  title: string = '';
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
          .margin({
            right: $r('app.string.margin_xs'),
          })
          .onClick(() => {
            RouterModule.pop();
          });
      }
      Text(this.title)
        .fontSize($r('app.string.font_size_36'))
        .fontColor($r('app.color.font_color_level1'));
    }
    .width('100%')
    .padding({
      left: $r('app.string.padding_s'),
    })
    .backgroundColor($r('app.color.system_color_background_white'))
    .justifyContent(FlexAlign.Start)
    .height(this.topBannerHeight);
  }
}