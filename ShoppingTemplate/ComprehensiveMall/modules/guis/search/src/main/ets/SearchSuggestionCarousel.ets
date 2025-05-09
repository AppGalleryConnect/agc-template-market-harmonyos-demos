import { Style } from '@common/const';

import { SearchSuggestionCarouselLogic, ContentType } from './logic/SearchSuggestionCarouselLogic';

@Builder
export function buildSearchSuggestionCarousel(logic: SearchSuggestionCarouselLogic) {
  Row() {
    Image($r('app.media.ic_search'))
      .width(18)
      .height(18)
      .margin({ left: 10, right: 10 })
      .fillColor($r('sys.color.mask_secondary'))
      .draggable(false)
      .objectFit(ImageFit.Cover)
    Stack({ alignContent: Alignment.Start }) {
      buildContent(logic, ContentType.A)
      buildContent(logic, ContentType.B)
    }
    .layoutWeight(1)
    .height(Style.MENU_BAR_HEIGHT)
    .clip(true)
  }
  .width('100%')
  .height(Style.MENU_BAR_HEIGHT)
  .borderWidth(Style.MENU_BAR_BORDER_WIDTH)
  .borderRadius(Style.MENU_BAR_BORDER_RADIUS)
  .backgroundColor(Color.White)
  .borderColor(Color.Transparent)
  .clip(true)
  .onClick(logic.onClick)
}

@Builder
function buildContent(logic: SearchSuggestionCarouselLogic, type: ContentType) {
  Text(type === ContentType.A ? logic.contentA : logic.contentB)
    .width('100%')
    .maxLines(1)
    .textOverflow({ overflow: TextOverflow.Ellipsis })
    .fontSize(13)
    .fontColor($r('sys.color.mask_secondary'))
    .visibility(
      logic.selectedContentType === type
        ? Visibility.Visible
        : (logic.isPlaying ? Visibility.Visible : Visibility.Hidden)
    )
    .offset({
      y: logic.selectedContentType === type
        ? 0
        : (logic.isPrepareStatus ? Style.MENU_BAR_HEIGHT : -Style.MENU_BAR_HEIGHT)
    })
}
