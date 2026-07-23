import { Constants } from 'constant';

@Preview
@ComponentV2
export struct CommonHeader {
  @Param title: string = '';
  @Param icon: ResourceStr = '';
  @Param showBackButton: boolean = false;
  @Event backButtonClick: () => void = () => {};
  @Event iconClick: () => void = () => {};


  build() {
    Row() {
      if (this.showBackButton) {
        Row() {
          Image($r('app.media.ic_arrow_left'))
            .fillColor($r('sys.color.icon_primary'))
            .height(20)
        }
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .borderRadius('99vp')
        .height(40)
        .width(40)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          this.backButtonClick();
        });
      }
      Text(this.title)
        .fontSize(this.showBackButton ? '20vp' : '30vp')
        .fontColor($r('sys.color.font_primary'))
        .margin({ left: '12vp' })
        .fontWeight(FontWeight.Bold);
      Blank()
        .layoutWeight(1)
      Image(this.icon)
        .height(40)
        .margin({ right: '12vp' })
        .onClick(this.iconClick)
    }
    .width(Constants.FULL_SCREEN)
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .height(56)
    .padding({ left: '8vp' })
    .margin({ top: '36vp' })
  }
}