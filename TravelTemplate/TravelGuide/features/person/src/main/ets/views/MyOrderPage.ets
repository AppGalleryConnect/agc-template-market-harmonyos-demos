/**
 * @usage: 订单管理页面，展示用户的全部订单、待付款订单、未出行订单，支持订单状态分类查看和订单删除功能
 * @layout: 页面整体采用垂直布局（Column），顶部是通用头部组件和tab切换栏，下方是可滚动的订单卡片列表
 * @constraints: currentIndexTab控制当前显示的订单类型（全部、待付款、未出行）；orderList数据来源于本地存储
 * @isGen: true
 * @fileType: page
 * @zhName: 订单管理
 * @domain: 旅游
 * @image: screenshots/person/MyOrder.jpg
 * @component: CommonHeader,CommonEmpty,OrderCard
 */
import { common } from '@kit.AbilityKit';
import {
  BarVM, CommonEmpty, CommonHeader, Constants, GlobalContext, TValueType,
} from 'common';
import { OrderInfo } from 'common_travel_guide';
import { OHPage, phoneRouterControl } from 'oh_router'
import { OrderCard } from '../comp/OrderCard';
import { OrderPageVM } from '../viewmodel/OrderPageVM';

@Builder
export function MyOrderPageBuilder(params: TValueType) {
  MyOrderPage({
    pageParam: params
  });
}

@ComponentV2
export struct MyOrderPage {
  @Param pageParam?: TValueType = null
  vm: OrderPageVM = new OrderPageVM();
  context: common.UIAbilityContext = GlobalContext.getUIAbilityContext()

  aboutToAppear() {
    this.vm.currentIndexTab = this.pageParam as number ?? Constants.TAB_INDEX_ZERO
    this.vm.getLocalList()
    this.context.eventHub.on('orderStatusChange', () => {
      this.vm.getLocalList()
    })
  }

  @Builder
  tabBuilder(title: string, index: number) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(14)
        .fontColor(this.vm.currentIndexTab === index ? '#000' : 'rgba(0, 0, 0, 0.50)')
      if (this.vm.currentIndexTab === index) {
        Row().width(12).height(3).borderRadius(2).backgroundColor('#333')
      }
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 10, bottom: 4 })
    .height(37)
    .onClick(() => {
      this.vm.currentIndexTab = index;
    })
  }

  @Builder
  tabContentBuilder(index: number, list: OrderInfo[]) {
    if (list.length) {
      Scroll() {
        this.contentListBuilder(index)
      }
      .layoutWeight(1)
      .padding({ bottom: BarVM.instance.aiBarH })
      .width('100%')
      .align(Alignment.TopStart)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .zIndex(index === this.vm.currentIndexTab ? 999 : 0)
      .visibility(index === this.vm.currentIndexTab ? Visibility.Visible : Visibility.Hidden)
    } else {
      CommonEmpty()
        .height('100%')
        .zIndex(index === this.vm.currentIndexTab ? 999 : 0)
        .visibility(index === this.vm.currentIndexTab ? Visibility.Visible : Visibility.Hidden)
    }
  }

  @Builder
  contentListBuilder(index: number) {
    Column({ space: 10 }) {
      ForEach(this.vm.getListByIndex(index), (item: OrderInfo) => {
        OrderCard({
          data: item,
          deleteItem: (id: string) => {
            this.vm.deleteItem(id)
          }
        })
      },(item: OrderInfo) => JSON.stringify(item))
    }
    .width('100%')
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      Column() {
        CommonHeader({
          title: '订单管理',
          backgroundColorParam: '#fff',
          onReturnClick: () => {
            phoneRouterControl.popPage();
          },
        })
          .padding({ left: 16, right: 16 })

        Row({ space: 24 }) {
          this.tabBuilder('全部', Constants.TAB_INDEX_ZERO)
          this.tabBuilder('待付款', Constants.TAB_INDEX_ONE)
          this.tabBuilder('未出行', Constants.TAB_INDEX_TWO)
        }
        .padding({ left: 16, right: 16 })
        .height(37)
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }
      .backgroundColor('#fff')
      .padding({ top: BarVM.instance.staBarH })

      Stack() {
        this.tabContentBuilder(Constants.TAB_INDEX_ZERO, this.vm.orderList.list)
        this.tabContentBuilder(Constants.TAB_INDEX_ONE, this.vm.pendingOrderList)
        this.tabContentBuilder(Constants.TAB_INDEX_TWO, this.vm.untraveledOrderList)
      }
      .padding({ left: 16, right: 16, top: 12 })
      .layoutWeight(1)
      .width('100%')
      .backgroundColor('#F1F3F5')
      .align(Alignment.TopStart)
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
    .padding({ bottom: BarVM.instance.aiBarH })
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      }
    })
  }
}

