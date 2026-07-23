import { GridRowColSetting } from 'module_weather_core';
import { CommonHeader } from '../components/CommonHeader';
import { CommonUtil } from '../utils/Utils';
import { SearchVM } from '../viewmodels/SearchVM';
import { City } from '../types/Types';
import { CityPage } from '../constants/Constants';

@ComponentV2
export struct SearchCityPage {
  @Local stack: NavPathStack | undefined;
  vm: SearchVM = SearchVM.instance;

  aboutToAppear(): void {
    this.vm.resetSearchParams();
  }

  build() {
    NavDestination() {
      CommonHeader({ stack: this.stack }) {
        Search()
          .layoutWeight(1)
          .onChange(CommonUtil.debounce((res: string) => {
            this.vm.text = res.trim();
            if (this.vm.text.length) {
              this.vm.query(this.vm.text);
            } else {
              this.vm.searchListSpilt = [];
            }
          }, 200))
      }

      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({
          span: this.vm.text ? this.vm.searchResultColSpan : this.vm.defaultCenterColSpan,
          offset: this.vm.text ? this.vm.searchResultColOffset : this.vm.defaultCenterColOffset,
        }) {
          Scroll() {
            Column() {
              if (this.vm.text) {
                this.searchResListBuilder()
              } else {
                this.popularFlexBuilder()
              }

              Blank().layoutWeight(1)
            }
            .width('100%')
            .constraintSize({ minHeight: '100%' })
            .justifyContent(FlexAlign.Start)
            .onSizeChange((_, n) => {
              this.vm.updateItemWidth(Number(n.width));
            })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .layoutWeight(1)
      .padding({ left: this.vm.pagePadding, right: this.vm.pagePadding, bottom: 24 })
      .margin({ top: 16 })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_primary'))
    .onReady(res => {
      this.stack = res.pathStack;
      this.vm.curPostion = this.stack.getParamByName(CityPage.SEARCH).pop() as City;
    })
  }

  @Builder
  popularFlexBuilder() {
    Column({ space: 24 }) {
      Column({ space: 12 }) {
        Text('定位')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_L'))

        Text() {
          ImageSpan($r('app.media.local_fill')).width(12).height(15).margin({ right: 4 })
          Span(this.vm.curPostion.name)
        }
        .itemStyle()
        .width('calc(25% - 6vp)')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .onClick(() => {
          if (!this.vm.curPostion.code) {
            this.stack?.pop(this.vm.curPostion);
          }
        })
        .bindPopup(this.vm.show, {
          message: this.vm.curPostion.name,
          messageOptions: {
            textColor: $r('sys.color.font_primary'),
            font: {
              size: $r('sys.float.Body_S'),
              weight: FontWeight.Regular,
            },
          },
          placement: Placement.BottomLeft,
          enableArrow: true,
          onStateChange: (e) => {
            if (!e.isVisible) {
              this.vm.show = false;
            }
          },
        })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      Column({ space: 12 }) {
        Text('热门城市')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_L'))
        Grid() {
          ForEach(SearchVM.popularCityList, (city: City) => {
            GridItem() {
              Text(city.name).itemStyle().width('100%')
            }.onClick(() => {
              this.stack?.pop(city);
            })
          }, (city: City) => city.code)
        }
        .height(28 * 5 + 4 * 8)
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .rowsTemplate('1fr 1fr 1fr 1fr 1fr')
        .rowsGap(8)
        .columnsGap(8)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  searchResListBuilder() {
    List() {
      ForEach(this.vm.searchListSpilt, (item: string[], index1) => {
        ListItem() {
          Text() {
            ForEach(item, (s: string, index2) => {
              Span(s).fontColor($r('sys.color.font_secondary'))
              if (index2 !== item.length - 1) {
                Span(this.vm.text).fontColor($r('sys.color.font_primary'))
              }
            }, (s: string, index2) => s + '_' + index2)
          }
          .fontSize($r('sys.float.Subtitle_M'))
          .fontWeight(FontWeight.Medium)
          .height(48)
          .onClick(() => {
            this.stack?.pop(this.vm.getPostionFromSearchInfo(index1));
          })
        }
      }, (item: string[], index1) => JSON.stringify(item) + '_' + index1)
    }
    .divider({ strokeWidth: 1, color: $r('sys.color.comp_divider') })
    .scrollBar(BarState.Off)
  }

  @Builder
  menuBuilder() {
    Text(this.vm.curPostion.name)
      .fontColor($r('sys.color.font_primary'))
      .fontSize($r('sys.float.Body_S'))
      .padding({
        left: 12,
        right: 12,
        top: 14,
        bottom: 14,
      })
  }
}


@Builder
export function searchCityPageBuilder() {
  SearchCityPage()
}

@Extend(Text)
function itemStyle() {
  .height(28)
  .textAlign(TextAlign.Center)
  .backgroundColor($r('sys.color.comp_background_tertiary'))
  .borderRadius(16)
  .fontColor($r('sys.color.font_primary'))
  .fontSize(12)
}
