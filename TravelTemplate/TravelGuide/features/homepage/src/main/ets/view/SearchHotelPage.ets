import { BarVM, RouterMap, TValueType } from 'common'
import { phoneRouterControl } from 'oh_router'
import { SearchComponent, SearchController } from 'search'
import { SearchHotelPageVM } from '../viewmodel/SearchHotelPageVM'
import { LengthMetrics } from '@kit.ArkUI'
import { HotelModel } from 'common_travel_guide'
import { HotelDetailsPageBuilder } from './HotelDetailsPage'
import { HotelDetailsParam } from './HotelListPage'
import { HotelPageVM } from '../viewmodel/HotelPageVM'
import { HotelListPageVM } from '../viewmodel/HotelListPageVM'

@Builder
export function SearchHotelPageBuilder(params: TValueType) {
  SearchHotelPage({
    pageParam: params as HotelPageVM
  })
}

@ComponentV2
export struct SearchHotelPage {
  vm: SearchHotelPageVM = new SearchHotelPageVM()
  @Param pageParam: TValueType = null
  private searchController: SearchController = SearchController.instance;

  build() {
    NavDestination() {
      this.render()
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      phoneRouterControl.popPage({
        popData: this.searchController.searchCondition
      })
      return true
    })

  }

  getSearchResult() {
    this.vm.searchHotelList =
      this.vm.hotelList.filter(item => item.name.includes(this.searchController.searchCondition))
  }

  aboutToAppear(): void {
    this.searchController.searchCondition = (this.pageParam as HotelPageVM)?.searchContent
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      SearchComponent({
        historySearchBuilder: this.historySearch.bind(this),
        searchResultBuilder: this.searchResult.bind(this),
        getSearchResult: this.getSearchResult.bind(this),
        placeholderText: '位置/品牌/酒店',
        popPage: () => {
          phoneRouterControl.popPage({
            popData: this.searchController.searchCondition
          })
        },
      })
        .padding({
          left: 16,
          right: 16,
        });
    }
    .padding({
      top: BarVM.instance.staBarH,
      bottom: BarVM.instance.aiBarH
    })
    .width('100%')
    .backgroundColor($r('sys.color.background_primary'))
  }

  @Builder
  historySearch() {
    Column() {
      Row() {
        Text('搜索历史').fontColor('rgba(0,0,0,0.90)').fontSize(16)
        Blank()
        if (this.vm.isDelete) {
          Row() {
            Text('全部删除').fontColor('rgba(0, 0, 0, 0.50)').fontSize(14)
              .onClick(() => {
                this.searchController.historySearch = [];
              });
            Column().backgroundColor('rgba(0, 0, 0, 0.10)').margin({ left: 12, right: 12 }).width(1).height(10)
            Text('完成').fontColor('rgba(0, 0, 0, 0.50)').fontSize(14)
              .onClick(() => {
                this.vm.isDelete = false;
              });
          }
        } else {
          Text('删除').fontColor('rgba(0, 0, 0, 0.50)').fontSize(14)
            .onClick(() => {
              this.vm.isDelete = true;
            });
        }
      }.justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 12 }).width('100%');

      Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
        ForEach(this.searchController.historySearch, (item: string, index: number) => {
          if (this.vm.isDelete) {
            Row() {
              Text(item).fontSize(14).fontColor('rgba(0,0,0,0.60)')
              Image($r('app.media.ic_search_delete')).width(14).height(14).margin({ left: 2 })
            }
            .padding({ top: 6, bottom: 6, left: 12, right: 12, })
            .borderRadius(15)
            .backgroundColor('#F8F8F8')
            .onClick(() => {
              this.searchController.historySearch.splice(index, 1);
            })

          } else {
            Text(item)
              .labelBaseStyle()
              .onClick(() => {
                this.searchController.searchCondition = item;
                this.searchController.updateHistorySearch(item);
                this.searchController.isShowResult = true;
                this.getSearchResult();
              });
          }
        }, (item: string, index) => item + index.toString());
      };
    }
    .padding({
      bottom: px2vp(AppStorage.get('bottomRectHeight')),
    });
  }

  @Builder
  searchResult() {
    Column() {
      ForEach(this.vm.searchHotelList, (item: HotelModel) => {
        Row() {
          Column({ space: 6 }) {
            Text() {
              Span(this.searchController.searchCondition) .fontColor('#3F7FFF')
              Span(item.name.replaceAll(this.searchController.searchCondition, '')).fontColor('#333333')
            }
            .fontSize(14)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

            Text(`距离${this.searchController.searchCondition}直线${item.distance}公里`)
              .fontSize(12)
              .maxLines(1)
              .fontColor('rgba(0, 0, 0, 0.50)')
              .textOverflow({ overflow: TextOverflow.Ellipsis })

          }.height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Start)

          Text() {
            Span(`¥${item.price}`)
              .fontColor('#FF890B')
            Span('起')
              .fontColor('rgba(0, 0, 0, 0.50)')
          }.fontSize(14)
        }
        .height(68)
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(() => {
          const param: HotelDetailsParam = {
            hotelModel: item,
            hotelDate: (this.pageParam as HotelPageVM)?.hotelDateModel ||
              (this.pageParam as HotelListPageVM)?.hotelDate,
            hotelPageVM: this.pageParam as HotelPageVM
          }
          phoneRouterControl.jumpPage({
            pageName: RouterMap.HOTEL_DETAILS_PAGE,
            builder: wrapBuilder(HotelDetailsPageBuilder),
            param: param
          })
        });
      }, (item: HotelModel) => item.toString());
    }.margin({ top: 8 })
  }
}

@Extend(Text)
function labelBaseStyle() {
  .padding({
    top: 6,
    bottom: 6,
    left: 12,
    right: 12,
  })
  .fontSize(14)
  .borderRadius(15)
  .fontColor('rgba(0,0,0,0.60)')
  .backgroundColor('#F8F8F8')
  .focusable(true)
  .focusOnTouch(true);
}