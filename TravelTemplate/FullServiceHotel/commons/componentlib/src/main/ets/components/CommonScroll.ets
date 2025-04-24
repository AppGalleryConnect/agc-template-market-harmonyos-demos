import { RouterModule } from 'commonlib';

@ComponentV2
export struct CommonScroll {
  @Param
  private title: string = '';
  @Param
  private topBannerHeight: number = 50;
  @Param
  private color: ResourceColor | undefined = undefined;
  @BuilderParam
  private primaryContentBuilder: () => void;
  @Local
  private localOpacity: number = 0;
  private readonly RATIOS: number[] = Array(1001).fill(0).map((_: number, i: number) => i * 0.001);

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Scroll() {
        Stack({ alignContent: Alignment.TopStart }) {
          this.visibleAreaBuilder();
          this.primaryContentBuilder();
        };
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);

      this.topBannerBuilder();
    }
    .width('100%')
    .backgroundColor(this.color);
  }

  @Builder
  topBannerBuilder() {
    Stack({ alignContent: Alignment.Start }) {
      Column()
        .width(30)
        .height(30)
        .backgroundColor(Color.Black)
        .borderRadius(5)
        .opacity(this.localOpacity >= 0.9 ? 0 : (1 - this.localOpacity) * 0.5)
        .margin({ left: 12 });
      Row() {
        Text(this.title)
          .height(this.topBannerHeight)
          .fontColor('#FF191919')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('app.string.font_size_40'))
          .translate({ y: 0.5 })
          .margin({ left: 48 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }
      .width('100%')
      .backgroundColor('#FFFFFFFF')
      .opacity(this.localOpacity)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);

      Column() {
        Image($r('app.media.ic_back_common'))
          .width('24vp')
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .fillColor(this.localOpacity >= 0.4 ? '#FF191919' : '#FFFFFFFF')
          .margin({ left: 16 });
      }
      .onClick(() => RouterModule.pop());
    };
  }

  @Builder
  visibleAreaBuilder() {
    Column()
      .width('100%')
      .height('18%')
      .onVisibleAreaChange(this.RATIOS, (_: boolean, currentRatio: number) => {
        if (currentRatio < 0.1) {
          this.localOpacity = 1;
        } else if (currentRatio > 0.9) {
          this.localOpacity = 0;
        } else {
          let localOpacityValue: number = 1 - (currentRatio - 0.1) / 0.8;
          this.localOpacity = parseFloat(localOpacityValue.toFixed(2));
        }
      });
  }
}