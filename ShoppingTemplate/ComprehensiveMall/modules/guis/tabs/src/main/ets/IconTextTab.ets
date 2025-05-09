import { IconTextTabLogic } from './logic/IconTextTabLogic';

@ComponentV2
export struct IconTextTab {

  @Param
  public logic: IconTextTabLogic = new IconTextTabLogic();

  build() {
    Column() {
      Image(this.logic.icon)
        .width($r('app.float.width_sm'))
        .height($r('app.float.height_sm'))
        .objectFit(ImageFit.Cover)
        .fillColor(this.logic.iconColor)
        .margin({ bottom: $r('app.float.space_xs') })
      Text(this.logic.label)
        .fontSize($r('app.float.font_size_small'))
        .fontWeight(FontWeight.Medium)
        .fontColor(this.logic.textColor)
    }
    .width('20%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }

}

@Builder
export function buildIconTextTab(logic: IconTextTabLogic) {
  Column() {
    Image(logic.icon)
      .width($r('app.float.width_sm'))
      .height($r('app.float.height_sm'))
      .objectFit(ImageFit.Cover)
      .fillColor(logic.iconColor)
      .margin({ bottom: $r('app.float.space_xs') })
    Text(logic.label)
      .fontSize($r('app.float.font_size_small'))
      .fontWeight(FontWeight.Medium)
      .fontColor(logic.textColor)
  }
  .width('20%')
  .alignItems(HorizontalAlign.Center)
  .justifyContent(FlexAlign.Start)
}
