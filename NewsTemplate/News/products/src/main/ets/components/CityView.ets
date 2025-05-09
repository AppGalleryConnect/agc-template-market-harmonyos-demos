import { router } from '@kit.ArkUI';
import { CommonConstants } from 'commonlib';
import { CityType, CITY_DATA, HOT_CITY, TAB_VALUE } from '../viewmodels/CityDetailData';

@Component
export struct CityView {
  @State stabIndex: number = CommonConstants.ZERO;
  @State location: boolean = true;
  @Link isSearchState: boolean;
  @StorageProp('currentLocal') currentLocal: string = '';
  private scroller: Scroller = new Scroller();
  curCity: string = '';
  controller: SearchController = new SearchController();

  build() {
    Column() {
      Stack({ alignContent: Alignment.End }) {
        Column() {
          Text($r('app.string.location'))
            .fontSize($r('app.integer.text_font'))
            .fontColor($r('app.color.text_font_color'))
            .opacity(CommonConstants.TEXT_OPACITY[2])
            .margin({ left: $r('app.integer.txt_margin_left'), bottom: $r('app.integer.row_margin_bottom') })

          Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center, wrap: FlexWrap.Wrap }) {
            Text(this.currentLocal)
              .margin({ bottom: $r('app.integer.text_margin_bottom'), left: $r('app.integer.text_margin_left2') })
              .width($r('app.string.city_text_width'))
              .height($r('app.integer.text_height'))
              .textAlign(TextAlign.Center)
              .fontSize($r('app.integer.text_font'))
              .maxLines(CommonConstants.MAX_LINES)
              .fontColor($r('app.color.text_font_color2'))
              .backgroundColor($r('app.color.text_bgc'))
              .borderRadius($r('app.integer.text_border_radius'))
              .onClick(() => {
                AppStorage.setOrCreate('local', this.currentLocal);
                router.back();
              })
          }
          .width(CommonConstants.FULL_PERCENT)

          Text($r('app.string.hotCity'))
            .fontSize($r('app.integer.text_font'))
            .fontColor($r('app.color.text_font_color'))
            .opacity(CommonConstants.TEXT_OPACITY[2])
            .margin({ left: $r('app.integer.txt_margin_left'), bottom: $r('app.integer.row_margin_bottom') })

          Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center, wrap: FlexWrap.Wrap }) {
            ForEach(HOT_CITY, (item: string) => {
              Text(`${item}`)
                .margin({ bottom: $r('app.integer.text_margin_bottom'), left: $r('app.integer.text_margin_left2') })
                .width($r('app.string.city_text_width'))
                .height($r('app.integer.text_height'))
                .textAlign(TextAlign.Center)
                .fontSize($r('app.integer.text_font'))
                .maxLines(CommonConstants.MAX_LINES)
                .fontColor($r('app.color.text_font_color2'))
                .backgroundColor($r('app.color.text_bgc'))
                .borderRadius($r('app.integer.text_border_radius'))
                .onClick(() => {
                  AppStorage.setOrCreate('local', item);
                  router.back();
                })
            }, (item: string) => JSON.stringify(item))
          }
          .width(CommonConstants.FULL_PERCENT)
          .padding({ right: $r('app.string.city_padding_right') })

          List({
            space: CommonConstants.LIST_ITEM_SPACE,
            initialIndex: CommonConstants.ZERO,
            scroller: this.scroller
          }) {
            ForEach(CITY_DATA, (index: CityType) => {
              ListItem() {
                Column() {
                  Text(`${index.name}`)
                    .height($r('app.integer.list_item_height'))
                    .fontSize($r('app.integer.font_size'))
                    .fontColor($r('app.color.text_font_color'))
                    .width(CommonConstants.FULL_PERCENT)
                  ForEach(index.city, (item: string) => {
                    Text(item)
                      .height($r('app.integer.list_item_height'))
                      .fontSize($r('app.integer.text_font'))
                      .width(CommonConstants.FULL_PERCENT)
                      .onClick(() => {
                        AppStorage.setOrCreate('local', item);
                        router.back();
                      })
                  }, (item: string) => JSON.stringify(item))
                }
              }
            },  (item: CityType) => JSON.stringify(item))
          }
          .width(CommonConstants.FULL_PERCENT)
          .margin({ left: $r('app.integer.txt_margin_left'), bottom: $r('app.integer.txt_margin_bottom') })
          .layoutWeight(CommonConstants.LAYOUT_WEIGHT)
          .edgeEffect(EdgeEffect.None)
          .divider({
            strokeWidth: $r('app.integer.divider_strokeWidth'),
            color: $r('app.color.divider_color'),
            startMargin: $r('app.integer.divider_start'),
            endMargin: $r('app.integer.divider_end')
          })
          .listDirection(Axis.Vertical)
          .scrollBar(BarState.Off)
          .onScrollIndex((firstIndex: number, lastIndex: number) => {
            this.stabIndex = firstIndex;
          })
        }
        .alignItems(HorizontalAlign.Start)

        AlphabetIndexer({arrayValue: TAB_VALUE, selected: this.stabIndex })
          .height(CommonConstants.FULL_PERCENT)
          .selectedColor($r('sys.color.font_emphasize'))
          .popupColor($r('sys.color.font_emphasize'))
          .selectedBackgroundColor($r('sys.color.comp_emphasize_tertiary'))
          .popupBackground($r('app.color.alphabet_pop_bgc'))
          .popupPosition({ x: $r('app.integer.pop_position_x'), y: $r('app.integer.pop_position_y') })
          .usingPopup(true)
          .selectedFont({size: $r('sys.float.Caption_M'), weight: FontWeight.Bolder })
          .popupFont({ size: $r('sys.float.Title_M'), weight: FontWeight.Bolder })
          .alignStyle(IndexerAlign.Right)
          // .itemSize(CommonConstants.ITEM_SIZE)
          .onSelect((tabIndex: number) => {
            this.scroller.scrollToIndex(tabIndex);
          })
      }
      .margin({ top: $r('app.integer.margin_top') })
    }
    .flexShrink(CommonConstants.LAYOUT_WEIGHT)
    .flexGrow(CommonConstants.LAYOUT_WEIGHT)
    .alignItems(HorizontalAlign.Start)
    .padding({ bottom: $r('app.integer.padding_bottom') })
    .visibility(this.isSearchState ? Visibility.None : Visibility.Visible)
  }
}