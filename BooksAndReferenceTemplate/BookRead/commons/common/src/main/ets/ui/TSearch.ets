import { TCRouter } from '../comp/TCRouter'
import { Constants } from '../constant/Constants'

@ComponentV2
export struct TSearch {
  build() {
    Row() {
      Image($r('app.media.ic_search'))
        .width(18)
        .height(18)
        .margin({ left: 10, right: 10 })
        .fillColor($r('sys.color.mask_secondary'))
        .draggable(false)
        .objectFit(ImageFit.Cover)
      Text($r('app.string.search_placeholder'))
        .lineHeight(36)
        .layoutWeight(1)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontSize(13)
        .fontColor($r('sys.color.mask_secondary'))
        .halfLeading(true)
    }
    .width('95%')
    .height(40)
    .margin({ top: 15, bottom: 15 })
    .borderWidth($r('sys.float.border_small'))
    .borderRadius(18)
    .backgroundColor('#0D000000')
    .borderColor(Color.Transparent)
    .onClick(() => {
      TCRouter.push(Constants.SEARCH_ROUTE);
    })
    .clip(true)
  }
}