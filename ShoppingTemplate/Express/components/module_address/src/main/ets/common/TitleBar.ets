import { IStyle, IColor } from './CommonConst';

@ComponentV2
export struct TitleBar {

  @Param
  public hideBackButton: boolean = false;

  @Param
  public barColor: ResourceColor = Color.Transparent;

  @Param
  public barExpandSafeArea: boolean = true;

  @Param
  public barPadding: Padding = {};

  @Event
  public onBackButtonClick: () => void = () => {};

  @BuilderParam
  private titleContentBuilder: () => void = buildEmptyComponent;

  build() {
    Row() {
      Row() {
        if (!this.hideBackButton) {
          Column() {
            Image($r('app.media.ic_left_arrow'))
              .height(IStyle.TITLE_BAR_BACK_ICON_HEIGHT)
              .objectFit(ImageFit.Contain)
              .fillColor(IColor.BLACK_TRANSPARENT_60)
          }
          .width(IStyle.TITLE_BAR_BACK_BTN_WIDTH)
          .height(IStyle.TITLE_BAR_HEIGHT)
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .onClick(this.onBackButtonClick)
        }
        Column() {
          this.titleContentBuilder();
        }
        .layoutWeight(1)
        .height(IStyle.TITLE_BAR_HEIGHT)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)
        .padding(this.barPadding)
      }
      .width('100%')
      .height('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)
      .backgroundColor(this.barColor)
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], this.barExpandSafeArea ? [SafeAreaEdge.TOP] : [])
      .padding({ right: IStyle.MENU_BAR_WIDTH + IStyle.MENU_BAR_MARGIN_RIGHT })
    }
    .width('100%')
    .height(IStyle.TITLE_BAR_HEIGHT)
  }
}

@Builder
function buildEmptyComponent() {
  // No need to do anything
}
