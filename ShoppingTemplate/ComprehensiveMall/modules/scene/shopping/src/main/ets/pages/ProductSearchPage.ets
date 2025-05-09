import { TitleBar } from '@components/titlebar';
import { Style } from '@common/const';

import { ProductSearchPageLogic } from '../logic/ProductSearchPageLogic';

@ComponentV2
struct ProductSearchPage {

  private logic: ProductSearchPageLogic = new ProductSearchPageLogic();

  build() {
    NavDestination() {
      Column() {
        TitleBar({ barPadding: { right: Style.MENU_BAR_MARGIN_RIGHT } }) {
          buildSearch(this.logic)
        }
        Scroll() {
          Column() {
            if (this.logic.isShowCandidate) {
              ForEach(this.logic.candidateWords, (word: string) => {
                Column() {
                  Text(word) {
                    ImageSpan($r('app.media.ic_search'))
                      .verticalAlign(ImageSpanAlignment.CENTER)
                      .height(15)
                      .objectFit(ImageFit.Contain)
                    ImageSpan('')
                      .width(8)
                    Span(this.logic.keyWord)
                      .fontColor('#FFE64566')
                    Span(word)
                      .fontColor('#E6000000')
                  }
                  .fontSize(12)
                  .lineHeight(42)
                  .halfLeading(true)
                  .maxLines(1)
                  .margin({ left: 8 })
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Divider()
                    .height(Style.DIVIDER_HEIGHT)
                }
                .alignItems(HorizontalAlign.Start)
                .width('100%')
                .padding({ left: 8 })
                .onClick(() => this.logic.onSubmit(this.logic.keyWord + word))
              })
            }
          }
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              this.logic.controller.stopEditing()
            }
          })
          .constraintSize({ minHeight: '100%' })
          .width('100%')
          .justifyContent(FlexAlign.Start)
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
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
export function buildProductSearchPage() {
  ProductSearchPage()
}

@Builder
function buildSearch(logic: ProductSearchPageLogic) {
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
    .onChange(logic.onChange)
    .onSubmit(logic.onSubmit)
}
