import { LengthMetrics } from '@kit.ArkUI'
import {NewsDetailSegmentInterface} from '../model/Interface'
import {newsDetailPiece} from '../mock/MockData'
@Builder
export function NewsDetailBuilder() {
  NewsDetail()
}

@Component
export struct NewsDetail {
  params:NewsDetailSegmentInterface[]=newsDetailPiece
  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            Text(this.params[0].title)
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.black'))
              // .margin({ top: 12 })
            Text(this.params[0].time)
              .fontSize(12)
              .fontColor($r('sys.color.black'))
              .margin({ top: 11 })
            Divider()
              .margin({ top: 16, bottom:12 })
              .strokeWidth('1px').color($r('sys.color.ohos_id_color_list_separator'))
            Image(this.params[0].image)
              .width(326)
              .height(180)
              .borderRadius($r('sys.float.corner_radius_level4'))
            Text(this.params[0].subtitle)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .margin({ top: 23, bottom: 18 })
              .fontColor($r('sys.color.black'))
            Text(this.params[0].content)
              .fontSize(12)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.mask_secondary'))
              .lineSpacing(LengthMetrics.percent(1))
          }
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .height('100%')
        }
        .scrollBar(BarState.Off)
      }
      .margin({ top: 20 })
      .padding(12)
      // .backgroundColor($r('app.color.background_color_white'))
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }
}