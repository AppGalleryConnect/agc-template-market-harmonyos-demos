import { Constants } from 'common'
import { phoneRouterControl } from 'oh_router'
import { MyOrderPageVM, OrderItem } from '../viewmodel/MyOrderPageVM';
import { MyOrderItemView } from '../views/MyOrder/MyOrderItemView';

/**
 * @usage: 我的订单页面，展示用户的订单列表，支持按订单状态筛选（全部、待发货、待处理、已完成、已取消）。每个订单项显示订单信息，点击可查看订单详情
 * 。支持从提交订单页面跳转过来时返回到首页。
 * @layout: 页面采用垂直布局（Column），顶部为标题栏（返回按钮 + 标题），下方为 Tabs 组件实现的订单状态切换，每个 Tab 内容区为订单列表（List）
 * @constraints: orderStatusList 数组定义订单状态标签（全部、待发货、待处理、已完成、已取消），不建议修改。from 参数用于判断来源页面，如果来
 * 自"提交订单"页面，返回时会清空整个页面栈。orderList 数据来自 MyOrderPageVM。
 * @isGen: true
 * @fileType: page
 * @zhName: 我的订单页面
 * @subPage: MyOrderDetailPage
 * @component: MyOrderItemView
 * @image: screenshots/person/myOrder.png
 */

@Builder
export function BuildMyOrderPage(param: Object): void {
  MyOrderPage({ from: param as string })
}

@ComponentV2
export struct MyOrderPage {
  private logTag: string = 'MyOrderPage'
  controller: TabsController = new TabsController();
  // 模型绑定对象
  private vm: MyOrderPageVM = MyOrderPageVM.instance
  // 来自哪里跳转过来的
  @Param from: string = ''

  // 标题区域
  @Builder
  buildTitleLayout() {
    Row() {
      Image($r('app.media.back')).width(40).height(40).margin({ left: 17 })
        .onClick(() => {
          if (this.from === '提交订单') {
            phoneRouterControl.popMulPage(phoneRouterControl.getNavPageInfoList().length)
          } else {
            phoneRouterControl.popPage()
          }
        })

      Text('我的订单').fontSize(20).fontColor('rgba(0, 0, 0, 1)').margin({ left: 5 })

      Blank().layoutWeight(1)

    }
    .width('100%')
    .height(56)
    .alignItems(VerticalAlign.Center)
  }

  // 构建tab标签
  @Builder
  buildTabLayout(item: string, index: number) {
    Text(item)
      .height(36)
      .width(66)
      .fontSize(14)
      .fontColor(this.vm.selectedTabIndex === index ? 'rgba(255, 255, 255, 1)' : 'rgba(0, 0, 0, 1)')
      .borderRadius(18)
      .backgroundColor(this.vm.selectedTabIndex === index ? 'rgba(255, 75, 75, 1)' : 'rgba(255, 255, 255, 1)')
      .textAlign(TextAlign.Center)
  }

  // 返回订单列表
  getOrderList(status: string): OrderItem[] {
    if (status === '全部') {
      return this.vm.orderList;
    }
    return this.vm.orderList.filter((item: OrderItem) => {
      if (status === '待发货' && item.status === '待发货') {
        return true
      } else if (status === '待处理' &&
        (item.status === '待处理' || item.status === '待处理-已质检' || item.status === '待处理-已质检-确认收款' ||
          item.status === '待处理-取消订单' || item.status === '待处理-已质检-取消订单' ||
          item.status === '待处理-已质检-确认收款-取消订单')) {
        return true
      } else if (status === '已完成' && item.status === '已完成') {
        return true
      } else if (status === '已取消' &&
        (item.status === '已取消-已质检' || item.status === '已取消' || item.status === '已取消-待发货')) {
        return true
      } else {
        return false
      }
    });
  }

  // 构造订单列表项
  @Builder
  buildOrderItemLayout(status: string) {
    Column() {
      List() {
        ForEach(this.getOrderList(status), (item: OrderItem, index: number) => {
          ListItem() {
            MyOrderItemView({
              vm: this.vm,
              item: item
            })
          }.margin({ top: 12 })
        }, (item: OrderItem, index: number) => JSON.stringify(item) + index)
      }
      .width('100%')
      .height('100%')
      .alignListItem(ListItemAlign.Start)

    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16 })
    .backgroundColor('rgba(245, 245, 245, 1)')
  }

  // 订单状态栏
  @Builder
  buildOrderStatusLayout() {
    Column() {
      Tabs({ barPosition: BarPosition.Start, controller: this.controller, index: this.vm.selectedTabIndex }) {
        ForEach(this.vm.orderStatusList, (item: string, index: number) => {
          TabContent() {
            // 构造订单列表项
            this.buildOrderItemLayout(item)
          }.tabBar(this.buildTabLayout(item, index))
        }, (item: string) => item)
      }
      .width('100%')
      .layoutWeight(1)
      .barHeight(56)
      .barWidth('90%')
      .barBackgroundColor('rgba(255, 255, 255, 1)')
      .onChange((index: number) => {
        this.vm.selectedTabIndex = index
      })
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('rgba(255, 255, 255, 1)')
  }

  build() {
    NavDestination() {
      // 标题区域
      this.buildTitleLayout()

      // 订单状态栏
      this.buildOrderStatusLayout()
    }
    .hideTitleBar(true)
    .padding({ top: Constants.PADDING_7XL })
    .onBackPressed(() => {
      if (this.from === '提交订单') {
        phoneRouterControl.popMulPage(phoneRouterControl.getNavPageInfoList().length)
      } else {
        phoneRouterControl.popPage()
      }
      return true
    })
  }
}