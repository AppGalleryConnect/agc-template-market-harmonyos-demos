import { BasicDataSource } from '../common/BasicDataSource';
import { Constants } from '../common/Constant';
import { GridRowColSetting } from '../common/GridRowColSetting';
import { SearchWordItem, TextSegment } from '../types/Type';
import { SearchViewModel } from '../viewmodel/SearchViewModel';


@ComponentV2
export struct SearchAutoComplete {
  @Param themeColor: ResourceColor = '#0A59F7';
  @Param breakpoint: string = 'sm';
  @Param matchWords: string[] = []
  @BuilderParam itemBuilderParam: WrappedBuilder<[string, number]>;
  @Event selectSuggestionItem: (listItem: SearchWordItem) => void = () => {
  }
  @Local vm: SearchViewModel = SearchViewModel.getInstance();
  @Local dataSource: BasicDataSource<SearchWordItem> = new BasicDataSource()

  @Monitor('vm.linkChangeStatus')
  onListChange() {
    this.dataSource.setData(this.vm.searchSuggestionList);
  }

  aboutToAppear(): void {
    this.dataSource.setData(this.vm.searchSuggestionList);
  };

  build() {
    Column() {
      List() {
        LazyForEach(this.dataSource, (listItem: SearchWordItem, index: number) => {
          ListItem() {
            if (this.itemBuilderParam !== undefined) {
              this.itemBuilderParam.builder(listItem.content, index)
            } else {
              this.itemBuilder(listItem.content, index)
            }
          }
          .onClick(() => {
            this.selectSuggestionItem(listItem)
          })
        }, (listItem: SearchWordItem) => JSON.stringify(listItem.content + listItem.id))
      }
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .width(Constants.FULL_PERCENT)
    }
    .margin({
      left: GridRowColSetting.getPageMargin(this.breakpoint),
      right: GridRowColSetting.getPageMargin(this.breakpoint),
    })
    .layoutWeight(1)
  }

  @Builder
  itemBuilder(listItem: string, listIndex?: number) {
    Row({ space: Constants.SPACE_XL }) {
      SymbolGlyph($r('sys.symbol.magnifyingglass'))
        .fontSize(Constants.GLASS_SIZE)
        .fontColor([$r('sys.color.icon_primary')])

      Column() {
        Text() {
          ForEach(SearchViewModel.processText(listItem, this.vm.matchWords), (item: TextSegment) => {
            if (item.isHighlight) {
              Span(item.text)
                .fontColor(this.themeColor)
            } else {
              Span(item.text)
            }
          }, (item: TextSegment, index: number) => JSON.stringify(item.text) + index)
        }
        .fontSize($r('sys.float.Body_M'))
        .fontFamily('HarmonyHeiTi')
        .fontColor($r('sys.color.font_primary'))
        .textAlign(TextAlign.Start)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({
          top: Constants.PADDING_L,
          bottom: Constants.PADDING_L
        })

        if (listIndex !== this.dataSource.totalCount() - 1) {
          Divider()
            .strokeWidth('1px')
            .color($r('sys.color.comp_divider'))
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .justifyContent(FlexAlign.Center)
    .height(Constants.LIST_HEIGHT)
    .width(Constants.FULL_PERCENT)
  }
}