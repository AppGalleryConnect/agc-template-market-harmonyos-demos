@Builder
export function SectorDetailPageBuilder() {
  SectorDetailPage();
}

@ComponentV2
struct SectorDetailPage {
  @Local data: string[][] = [];

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          List({ space: 12 }) {
            ForEach(this.data, (item: string[], index: number) => {
              ListItem() {
                Column() {
                  Text('扇区:' + index).margin({ bottom: 10 });
                  if (item && item.length > 0) {
                    ForEach(item, (str: string, i: number) => {
                      if (i === 3) {
                        Row() {
                          Text() {
                            Span(str.substring(0, 12).toUpperCase())
                              .fontSize(15)
                              .fontColor('#a3ff88')
                              .letterSpacing(0.02);
                            Span(str.substring(12, 18).toUpperCase())
                              .fontSize(15)
                              .fontColor('#ffaf37')
                              .letterSpacing(0.02);
                            Span(str.substring(18, 20).toUpperCase())
                              .fontSize(15)
                              .fontColor('#333333')
                              .letterSpacing(0.02);
                            Span(str.substring(20).toUpperCase())
                              .fontSize(15)
                              .fontColor('#a3ff88')
                              .letterSpacing(0.02);
                          };
                        };
                      } else {
                        Text(str.toUpperCase())
                          .fontSize(15)
                          .fontColor(i === 0 ? '#f707ff' : i === 3 ? '#a3ff88' : '#333333')
                          .letterSpacing(0.02);
                      }
                    }, (str: string, i: number) => str);
                  } else {
                    Text('未发现密钥（或死扇区）');
                  }
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
                .backgroundColor($r('sys.color.background_secondary'))
                .borderRadius(8).padding(12);
              }.width('100%');
            }, (item: string[], index: number) => JSON.stringify(item));
          }
          .width('100%');
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .align(Alignment.Top);
      }
      .width('100%')
      .height('100%')
      .padding(16);
    }.title('扇区详情').onReady((ctx) => {
      this.data = ctx.pathInfo.param as string[][];
    });
  }
}