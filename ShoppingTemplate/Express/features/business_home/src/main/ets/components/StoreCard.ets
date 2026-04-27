import { IServicePoint } from 'lib_foundation'

@ComponentV2
export struct StoreCard {
  @Param servicePoint: IServicePoint | undefined = undefined
  @Param isSelected: boolean = false

  build() {
    Row({space: 8}) {
      Image($r('app.media.store'))
        .width(54)
        .height(60)
      Column({ space: 8 }) {
        Row() {
          Text(this.servicePoint?.name)
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_primary'))
            .lineHeight(19)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ right: 4 })
            .layoutWeight(1)

          if (this.servicePoint?.title) {
            Row() {
              Text(this.servicePoint?.title)
                .fontSize(8)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_secondary'))
            }
            .padding({left: 8, right: 8, top: 4, bottom: 4})
            .justifyContent(FlexAlign.Center)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .borderRadius(8)
          }
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)

        Row() {
          ForEach(this.servicePoint?.tips, (item: string) => {
            this.tipBuilder(item)
          }, (item: string[]) => JSON.stringify(item))
        }
        .width('100%')
        .margin({ bottom: 4 })

        Row() {
          Text() {
            Span(this.servicePoint?.distance)
            Span(' ｜ ')
            Span(this.servicePoint?.positionName)
          }
          .fontSize(12)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_tertiary'))
        }
        .width('100%')
      }
      .layoutWeight(1)
    }
    .padding(12)
    .backgroundColor(Color.White)
    .borderWidth(1)
    .borderColor(this.isSelected ? $r('sys.color.background_emphasize') : Color.White)
    .borderRadius(16)
    .width('100%')
  }

  @Builder
  tipBuilder(text: string) {
    Row() {
      Text(text)
        .fontSize(10)
        .fontWeight(FontWeight.Regular)
        .fontColor('#0A59F7')
    }
    .padding({
      top: 4,
      bottom: 4,
      left: 8,
      right: 8
    })
    .margin({ right: 8 })
    .backgroundColor('#BFD5FF')
    .borderRadius(8)
  }
}