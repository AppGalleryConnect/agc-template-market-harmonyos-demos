@ComponentV2
export struct TitleBar {
  @Param @Require isShowBack: boolean;
  @Param @Require title: string;
  @Param @Require clickEvent: () => void;
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;

  build() {
    Stack({ alignContent: Alignment.Start }) {
      Text(this.title).fontSize(18).fontWeight(500).width('100%').textAlign(TextAlign.Center);

      if (this.isShowBack) {
        Image($r('app.media.left_arrow'))
          .size({ height: 24, width: 24 })
          .onClick(this.clickEvent);
      }
    }
    .margin({ top: this.windowTopHeight })
    .width('100%')
    .padding({
      left: 12,
      top: 16,
      right: 12,
      bottom: 12,
    });
  }
}