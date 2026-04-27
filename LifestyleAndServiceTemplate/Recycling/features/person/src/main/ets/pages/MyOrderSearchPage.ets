import { LengthMetrics, promptAction } from '@kit.ArkUI';
import { phoneRouterControl } from 'oh_router';
import { MyOrderPageVM, OrderItem } from '../viewmodel/MyOrderPageVM';
import { MyOrderSearchPageVM, OrderInfoManager } from '../viewmodel/MyOrderSearchPageVM';
import { DeleteHistoryListDialog } from '../views/MyOrder/DeleteHistoryListDialog';
import { MyOrderItemView } from '../views/MyOrder/MyOrderItemView';
import { SearchMyOrderComponent } from '../views/MyOrder/SearchMyOrderComponent';

@Builder
export function MyOrderSearchPageBuilder() {
  MyOrderSearchPage()
}

@Entry
@ComponentV2
struct MyOrderSearchPage {
  @Provider('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  private searchController: MyOrderSearchPageVM = MyOrderSearchPageVM.instance;
  private vm: MyOrderPageVM = MyOrderPageVM.instance;
  @Local searchKey: string = '';
  @Local textWidth: number = 0;

  build() {
    NavDestination() {
      Column() {
        SearchMyOrderComponent({
          appPathStack: this.appPathStack,
          historySearchBuilder: this.historySearch.bind(this),
          searchResultBuilder: this.searchResult.bind(this),
          backFunc: () => {
            phoneRouterControl.popPage()
          },
          getSearchResult: this.getSearchResult.bind(this)
        });
      }
      .height('100%')
      .width('100%')
      .margin({ top: 20 })
    }
    .hideToolBar(true)
    .hideTitleBar(true)
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true;
    })
  }

  @Builder
  historySearch() {
    Column() {
      Row() {
        Text('历史搜索')
          .fontColor('rgba(0,0,0,0.90)')
          .fontSize(14)

        Blank();

        Row() {
          Image($r('app.media.ic_trash_btn'))
            .height(24)
            .width(24)

          Text('清空')
            .fontSize(14)
            .lineHeight(15)
            .margin({ left: 4 })
            .fontColor('rgba(0, 0, 0, 0.6)')
        }
        .margin({ right: 16 })
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          promptAction.openCustomDialog({
            builder: () => {
              this.deleteDialog()
            },
            alignment: DialogAlignment.Center,
            width: '90%'
          }).then((id) => {
            this.searchController.deleteDialogId = id
          })
        });

      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%');

      if (this.searchController.historySearch.length > 0) {
        // 搜索结果
        Text('搜索结果')
          .fontSize(14)
          .fontColor('rgba(0, 0, 0, 0.9)')
          .margin({ left: 16, top: 16, bottom: 12 })

        Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
          ForEach(this.searchController.historySearch, (item: string, index: number) => {
            Row() {
              Text(item)
                .fontSize(12)
                .fontColor('rgba(25, 25, 25, 1)')
                .height(15)

              Image($r('app.media.ic_close_btn'))
                .height(16)
                .margin({ left: 8 })
                .width(16)
                .onClick(() => {
                  this.searchController.historySearch.splice(index, 1);
                });
            }
            .alignItems(VerticalAlign.Center)
            .padding({
              top: 6,
              bottom: 6,
              left: 12,
              right: 8,
            })
            .backgroundColor('rgba(0, 0, 0, 0.05)')
            .borderRadius(14)
            .focusable(true)
            .focusOnTouch(true)
            .onClick(() => {
              this.searchController.searchCondition = item;
              this.searchController.isShowResult = true;
              this.searchController.updateHistorySearch(item);
              this.getSearchResult();
            });

          }, (item: string, index) => item + index.toString());
        }.margin({ top: 10 })
      } else {
        Row() {
          Text('暂无历史搜索').fontSize(14).fontColor('rgba(102, 102, 102, 1)')
            .margin({ top: 14 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }

    }
    .padding({
      bottom: px2vp(AppStorage.get('bottomRectHeight')),
    });
  }

  @Builder
  deleteDialog() {
    DeleteHistoryListDialog({
      onDeleted: () => {
        this.searchController.historySearch = [];
        promptAction.closeCustomDialog(this.searchController.deleteDialogId)
      },
      onCanceled: () => {
        promptAction.closeCustomDialog(this.searchController.deleteDialogId)
      }
    })
  }

  @Builder
  searchResult() {
    Column() {
      if (this.searchController.searchResult.list.length === 0) {
        Image($r('app.media.ic_no_search_result_found'))
          .width(120)
          .height(120)
          .margin({
            top: 120
          })

        Text('暂时没有搜索到您要找的内容呢')
          .fontSize(14)
          .fontColor('rgba(0,0,0,0.40)')
      } else {
        Scroll() {
          Column() {

            // 搜索结果布局
            this.buildProductInfoList()
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: 16, right: 16 })
          .backgroundColor('rgba(245, 245, 245, 1)')
          .alignItems(HorizontalAlign.Start);
        }
        .scrollBar(BarState.Off);
      }

    }
    .layoutWeight(1);
  }

  // 返回订单列表
  getOrderList(status: string): OrderItem[] {
    if (status === '全部') {
      return this.vm.orderList;
    }
    return this.vm.orderList.filter((item: OrderItem) => {
      return item.status === status;
    });
  }

  // 商品列表
  @Builder
  buildProductInfoList() {
    List() {
      ForEach(this.searchController.searchResult.list, (item: OrderItem, index: number) => {
        ListItem() {
          MyOrderItemView({
            vm: this.vm,
            item: item,
            reloadList: () => {
              this.getSearchResult()
            }
          })
        }.margin({ top: 12 })
      }, (item: OrderItem, index: number) => JSON.stringify(item) + index)
    }.width('100%').height('100%').scrollBar(BarState.Off).alignListItem(ListItemAlign.Start)
  }

  getSearchResult() {
    this.searchController.searchResult = new OrderInfoManager('搜索结果', this.vm.orderList.filter(item => {
      return item.name.toLowerCase().includes(this.searchController.searchCondition)
    }))
  }
}
