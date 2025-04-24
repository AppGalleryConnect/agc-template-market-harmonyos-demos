import { ComponentConst } from '../constant/ComponentConst';

@ComponentV2
export struct CardWrapper {
  @Param bgColor: ResourceColor = ComponentConst.CARD_BG_COLOR;
  @Param horizonPadding: Length = ComponentConst.CARD_PADDING_HORIZON;
  @Param verticalPadding: Length = ComponentConst.CARD_PADDING_VERTICAL;
  @Param cardRadius: Length | BorderRadiuses | LocalizedBorderRadiuses = ComponentConst.CARD_RADIUS_MIDDLE;
  @BuilderParam contentBuilder: () => void;

  build() {
    Column() {
      this.contentBuilder();
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .padding({
      left: this.horizonPadding,
      right: this.horizonPadding,
      top: this.verticalPadding,
      bottom: this.verticalPadding,
    })
    .borderRadius(this.cardRadius)
    .backgroundColor(this.bgColor)
  }
}