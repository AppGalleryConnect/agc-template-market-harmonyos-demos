import { Constants } from '../constants';
import { MyOrderPageVM } from '../viewModels/MyOrderPageVM';
import { TabItem } from '../types';
import { CommonHeader } from 'componentlib';
import { GetOrderDetailRequest, OrderItem } from 'network';
import { RouterMap, RouterModule } from 'commonlib';


@Builder
export function myOrdersPageBuilder() {
  MyOrdersPage()
}

@ComponentV2
export struct MyOrdersPage {
  vm: MyOrderPageVM = MyOrderPageVM.instance;
  private controller: TabsController = new TabsController();

  aboutToAppear(): void {
    this.vm.initData();
  }

  @Builder
  tabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontColor(this.vm.currentIndex === index ? $r('app.color.system_color_focus') :
        $r('app.color.font_color_level1'))
        .fontSize($r('app.string.font_size_28'))
        .fontWeight(this.vm.currentIndex === index ? 500 : 400)
        .lineHeight(22)
        .margin({ top: $r('app.string.margin_s'), bottom: $r('app.string.margin_s') })
      Divider()
        .strokeWidth(2)
        .color('#007DFF')
        .opacity(this.vm.currentIndex === index ? 1 : 0)
    }
    .padding({
      left: $r('app.string.padding_xs'),
      right: $r('app.string.padding_xs'),
    })
    .width('20%')
  }

  build() {
    NavDestination() {
      CommonHeader({
        title: '我的订单',
      })
      Tabs({ barPosition: BarPosition.Start, index: this.vm.currentIndex, controller: this.controller }) {
        ForEach(this.vm.tabList, (item: TabItem, index: number) => {
          TabContent() {
            Column() {
              if (this.vm.isLoading) {
                LoadingProgress()
                  .width(40)
              } else {
                if (this.vm.orderList.length) {
                  List() {
                    ForEach(this.vm.orderList, (item: OrderItem) => {
                      ListItem() {
                        this.orderItemBuilder(item);
                      }
                      .padding({
                        left: $r('app.string.padding_s'),
                        right: $r('app.string.padding_s'),
                        top: $r('app.string.padding_s'),
                      })
                    }, (item: OrderItem) => JSON.stringify(item))
                  }
                  .padding({ bottom: 50 })
                } else {
                  Text('暂无数据')
                    .fontSize($r('app.string.font_size_28'))
                }
              }
            }
            .visibility(this.vm.currentIndex === index ? Visibility.Visible : Visibility.Hidden)
            .justifyContent(FlexAlign.Start)
            .height('100%')
          }.tabBar(this.tabBuilder(index, item.label))
        }, (item: TabItem) => JSON.stringify(item))
      }
      .vertical(false)
      .barMode(BarMode.Scrollable)
      .onChange((index: number) => {
        this.vm.currentIndex = index;
        this.vm.getOrderList();
      })
      .backgroundColor($r('app.color.system_color_background_auxiliary'))
    }
    .height('100%')
    .width('100%')
    .hideTitleBar(true)
  }

  @Builder
  orderItemBuilder(item: OrderItem) {
    RelativeContainer() {
      Row() {
        Image(item.shopLogo).width('32lpx').margin({ right: $r('app.string.margin_xs') })
        Text(item.shopName)
          .fontSize($r('app.string.font_size_28'))
        Blank()
        Text(Constants.ORDER_STATUS_LABEL.get(item.orderStatus))
          .fontSize($r('app.string.font_size_24'))
          .fontColor($r('app.color.font_color_link'))
      }
      .width('100%')
      .padding({ bottom: $r('app.string.padding_m') })
      .alignRules({
        left: { anchor: Constants.RELATIVE_CONTAINER_ID, align: HorizontalAlign.Start },
        top: { anchor: Constants.RELATIVE_CONTAINER_ID, align: VerticalAlign.Top },
      })
      .id('header')

      Image(item.displayImg ?? '')
        .width(80)
        .aspectRatio(4 / 3)
        .objectFit(ImageFit.Cover)
        .borderRadius($r('app.string.border_radius_8'))
        .padding({
          right: $r('app.string.padding_s'),
        })
        .alignRules({
          left: { anchor: Constants.RELATIVE_CONTAINER_ID, align: HorizontalAlign.Start },
          top: { anchor: 'header', align: VerticalAlign.Bottom },
        })
        .id('img')
      Text(item.goodsName)
        .id('title')
        .fontSize($r('app.string.font_size_28'))
        .fontWeight(500)
        .padding({
          bottom: $r('app.string.padding_s'),
        })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .alignRules({
          left: { anchor: 'img', align: HorizontalAlign.End },
          top: { anchor: 'header', align: VerticalAlign.Bottom },
          right: { anchor: 'price', align: HorizontalAlign.Start },
        })
      Text(`下单时间：${item.createTime}`)
        .id('time')
        .alignRules({
          left: { anchor: 'img', align: HorizontalAlign.End },
          top: { anchor: 'title', align: VerticalAlign.Bottom },
        })
        .fontSize($r('app.string.font_size_20'))
        .fontColor($r('app.color.font_color_level2'))
        .width('70%')
      Text('×' + item.goodsQty)
        .id('count')
        .alignRules({
          left: { anchor: 'img', align: HorizontalAlign.End },
          bottom: { anchor: 'img', align: VerticalAlign.Bottom },
        })
        .fontSize($r('app.string.font_size_20'))
        .fontColor($r('app.color.font_color_level2'))

      Text('¥' + item.actualPaidPrice)
        .id('price')
        .alignRules({
          right: { anchor: Constants.RELATIVE_CONTAINER_ID, align: HorizontalAlign.End },
          bottom: { anchor: 'img', align: VerticalAlign.Bottom },
        })
        .fontColor($r('app.color.font_color_level1'))
        .fontSize($r('app.string.font_size_28'))
    }
    .width('100%')
    .height(120)
    .backgroundColor(Color.White)
    .padding($r('app.string.padding_m'))
    .borderRadius($r('app.string.border_radius_8'))
    .onClick(() => {
      RouterModule.push({
        url: RouterMap.ORDER_DETAIL,
        param: {
          userId: this.vm.userId,
          orderNo: item.orderNo,
          orderType: Number(item.orderType),
        } as GetOrderDetailRequest,
      });
    })
  }
}