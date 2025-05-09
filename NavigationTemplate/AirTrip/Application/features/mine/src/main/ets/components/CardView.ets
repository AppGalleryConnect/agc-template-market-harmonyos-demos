
@Builder
function customContentBuilder() {
};

@ComponentV2
export struct CardView {
  @BuilderParam customContent: () => void = customContentBuilder;
  @Param title: string = ''

  build() {
    Column({space: 12}) {
      Text(this.title).fontSize(18).fontWeight(FontWeight.Medium)
      this.customContent()
    }
    .alignItems(HorizontalAlign.Start)
  }
}