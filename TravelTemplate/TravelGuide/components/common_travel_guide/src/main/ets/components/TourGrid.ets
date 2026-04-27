import { BarVM } from 'common'
import { TourModel } from '../model/TourModel'

@ComponentV2
export struct TourGrid {
  @Param tourList: TourModel[] = []
  @Event jumpTourDetailPage: (listItem: TourModel) => void = () => {
  }

  // 旅游列表item
  @Builder
  private tourItem(item: TourModel) {
    Row() {
      Image($r(item.image))
        .width(90)
        .height(128)
        .borderRadius(10)
        .objectFit(ImageFit.Contain)

      Column() {
        Column() {
          Text(item.title)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .width('100%')

          Text(item.subTitle)
            .fontSize(10)
            .fontColor('#717376')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 8 })
            .width('100%')
        }
        .width('100%')

        Row() {
          Text() {
            Span('¥')
            Span(item.originalPrice.toString())
          }
          .fontSize(10)
          .fontColor('#717376')
          .decoration({
            type: TextDecorationType.LineThrough,
            color: Color.Gray,
            style: TextDecorationStyle.SOLID
          })
          .margin({ right: 6 })

          Text() {
            Span('¥')
            Span(item.priceFrom.toString()).fontSize(18)
            Span('起')
          }
          .fontSize(10)
          .fontColor('#FF4A26')
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
        .alignItems(VerticalAlign.Bottom)
      }
      .layoutWeight(1)
      .height('100%')
      .padding({ left: 10, top: 6, bottom: 6 })
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height(128)
    .backgroundColor('#FFFFFF')
    .borderRadius(10)
    .padding(6)
    .onClick(() => {
      // 跳转到旅游详情页
      this.jumpTourDetailPage(item);
    })
  }

  build() {
    Column() {
      // 列表
      List({ space: 12 }) {
        ForEach(this.tourList, (item: TourModel, index: number) => {
          ListItem() {
            this.tourItem(item)
          }.margin({ bottom: index === this.tourList.length - 1 ? BarVM.instance.aiBarH + 12 : 0 })
        }, (item: TourModel) => item.id.toString())
      }
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .scrollBar(BarState.Off)
      .padding({ top: 12 })
    }
    .width('100%')
    .layoutWeight(1)
  }
}