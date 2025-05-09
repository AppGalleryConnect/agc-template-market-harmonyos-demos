import { TitleBar } from '@components/titlebar';
import { Style } from '@common/const';

import { OrderSearchPageLogic } from '../logic/OrderSearchPageLogic';

@ComponentV2
struct OrderSearchPage {

  private logic: OrderSearchPageLogic = new OrderSearchPageLogic();

  build() {
    NavDestination() {
      Column() {
        TitleBar({ barPadding: { right: Style.MENU_BAR_MARGIN_RIGHT } }) {
          buildSearch(this.logic)
        }
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
    }
    .hideTitleBar(true)
    .backgroundColor('#FFF1F3F5')
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
    .onShown(() => this.logic.onShown(this.getUIContext()))
  }
}

@Builder
export function buildOrderSearchPage() {
  OrderSearchPage()
}

@Builder
function buildSearch(logic: OrderSearchPageLogic) {
  Search({
    value: logic.submit,
    controller: logic.controller,
    placeholder: logic.placeholder
  })
    .id(logic.SEARCH_ID)
    .width('100%')
    .height(Style.MENU_BAR_HEIGHT)
    .borderWidth(Style.MENU_BAR_BORDER_WIDTH)
    .borderRadius(Style.MENU_BAR_BORDER_RADIUS)
    .backgroundColor(Color.White)
    .borderColor($r('sys.color.font_fourth'))
    .searchButton('搜索', {
      fontSize: 13,
      fontColor: '#FFE64566'
    })
    .defaultFocus(true)
    .searchIcon({ size: 0 })
    .textFont({
      size: 13
    })
    .placeholderFont({
      size: 13
    })
    .placeholderColor($r('sys.color.mask_secondary'))
    .caretStyle({ color: '#FFE64566' })
    .onSubmit(logic.onSubmit)
}
