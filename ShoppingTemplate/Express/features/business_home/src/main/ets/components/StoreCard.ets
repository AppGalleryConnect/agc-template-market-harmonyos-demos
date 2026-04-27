import { IServicePoint } from 'lib_foundation'

@ComponentV2
export struct StoreCard {
  @Param servicePoint: IServicePoint | undefined = undefined
  @Param isSelected: boolean = false

  build() {
    Column() {
      Flex() {
        Image($r('app.media.store'))
          .width(50)
          .height(60)
          .margin({ right: 12 })
        Column() {
          Flex() {
            Text(this.servicePoint?.name)
              .fontSize(14)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_secondary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ right: 4 })
              .flexGrow(1)
            if (this.servicePoint?.title) {
              Row() {
                Text(this.servicePoint?.title)
                  .fontSize(10)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_secondary'))
              }
              .width(72)
              .height(20)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('rgba(0,0,0,0.05)')
              .borderRadius(8)
            }
          }
          .margin({ bottom: 4 })

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
        .flexGrow(1)
      }
      .padding({
        top: 12,
        bottom: 12,
        left: 12,
        right: 20
      })

      if (this.isSelected) {
        Image($r('app.media.ic_selected'))
          .width(20)
          .height(20)
          .position({ right: 0, bottom: 0 })
      }
    }
    .backgroundColor(Color.White)
    .margin({ bottom: 12 })
    .borderWidth(this.isSelected ? 1 : 0)
    .borderColor(this.isSelected ? '#0A59F7' : '')
    .borderRadius(8)
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
      top: 3,
      bottom: 3,
      left: 8,
      right: 8
    })
    .margin({ right: 8 })
    .backgroundColor('#BFD5FF')
    .borderRadius(8)
  }
}