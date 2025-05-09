import { router } from '@kit.ArkUI';
import { CommonConstants } from 'commonlib';

@Component
export struct SearchView {
  @Link searchList: string[];
  @Link isSearchState: boolean;
  private scroller: Scroller = new Scroller();

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column() {
        List({
          space: CommonConstants.LIST_ITEM_SPACE,
          initialIndex: CommonConstants.ZERO,
          scroller: this.scroller
        }) {
          ForEach(this.searchList, (index: string) => {
            ListItem() {
              Column() {
                Text(index)
                  .height($r('app.integer.search_list_height'))
                  .fontSize($r('app.integer.text_font_size'))
                  .onClick(() => {
                    AppStorage.setOrCreate('local', index);
                    router.back();
                  })
              }
            }
          }, (item: string) => JSON.stringify(item))
        }
        .layoutWeight(CommonConstants.LAYOUT_WEIGHT)
        .edgeEffect(EdgeEffect.None)
        .divider({
          strokeWidth: $r('app.integer.divider_strokeWidth'),
          color: $r('app.color.divider_color'),
          startMargin: $r('app.integer.divider_start'),
          endMargin: $r('app.integer.divider_end')
        })
        .listDirection(Axis.Vertical)
        .sticky(StickyStyle.Header)
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .layoutWeight(CommonConstants.LAYOUT_WEIGHT)
    .visibility(this.isSearchState ? Visibility.Visible : Visibility.None)
  }
}