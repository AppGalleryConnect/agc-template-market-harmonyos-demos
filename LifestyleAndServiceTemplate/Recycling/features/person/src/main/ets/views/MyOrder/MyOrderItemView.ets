import { RouterMap } from 'common'
import { phoneRouterControl } from 'oh_router'
import { MyOrderDetailPageInfo, MyOrderPageVM, OrderItem } from '../../viewmodel/MyOrderPageVM'
import { promptAction } from '@kit.ArkUI'
import { CancelOrderItemDialog } from './CancelOrderItemDialog'
import { DeleteOrderItemDialog } from './DeleteOrderItemDialog'
import { CustomerServiceDialogBuilder } from 'valuation_information'
import { ConfirmOrderItemDialog } from './ConfirmOrderItemDialog'
import { BuildMyOrderDetailPage } from '../../pages/MyOrderDetailPage'

interface JumpType {
  name: string
  pageName: string
  builder: WrappedBuilder<[Object]>
  orderProcessType: string
  orderButtonType: string
  isExpand: boolean
}

const jumpType: JumpType[] = [
  {
    name: '待发货',
    pageName: RouterMap.MY_ORDER_DETAIL_PAGE,
    builder: wrapBuilder(BuildMyOrderDetailPage),
    orderProcessType: '上门取件',
    orderButtonType: 'cancel',
    isExpand: false
  },
  {
    name: '已取消-待发货',
    pageName: RouterMap.MY_ORDER_DETAIL_PAGE,
    builder: wrapBuilder(BuildMyOrderDetailPage),
    orderProcessType: '取消订单',
    orderButtonType: 'delete',
    isExpand: true
  },
  {
    name: '待处理',
    pageName: RouterMap.MY_ORDER_DETAIL_PAGE,
    builder: wrapBuilder(BuildMyOrderDetailPage),
    orderProcessType: '派件中',
    orderButtonType: 'cancel',
    isExpand: false
  },
  {
    name: '待处理-已质检',
    pageName: RouterMap.MY_ORDER_DETAIL_PAGE,
    builder: wrapBuilder(BuildMyOrderDetailPage),
    orderProcessType: '已送达',
    orderButtonType: 'cancel',
    isExpand: false
  },
  {
    name: '待处理-已质检-确认收款',
    pageName: RouterMap.MY_ORDER_DETAIL_PAGE,
    builder: wrapBuilder(BuildMyOrderDetailPage),
    orderProcessType: '确认收款',
    orderButtonType: 'confirm',
    isExpand: false
  },
  {
    name: '待处理-取消订单',
    pageName: RouterMap.MY_ORDER_DETAIL_PAGE,
    builder: wrapBuilder(BuildMyOrderDetailPage),
    orderProcessType: '邮件寄出',
    orderButtonType: '',
    isExpand: true
  },
  {
    name: '待处理-已质检-取消订单',
    pageName: RouterMap.MY_ORDER_DETAIL_PAGE,
    builder: wrapBuilder(BuildMyOrderDetailPage),
    orderProcessType: '平台质检-取消订单-确认收货',
    orderButtonType: '',
    isExpand: true
  },
  {
    name: '待处理-已质检-确认收款-取消订单',
    pageName: RouterMap.MY_ORDER_DETAIL_PAGE,
    builder: wrapBuilder(BuildMyOrderDetailPage),
    orderProcessType: '待处理-已质检-取消订单',
    orderButtonType: '',
    isExpand: true
  },
  {
    name: '已完成',
    pageName: RouterMap.MY_ORDER_DETAIL_PAGE,
    builder: wrapBuilder(BuildMyOrderDetailPage),
    orderProcessType: '已完成',
    orderButtonType: 'delete',
    isExpand: false
  },
  {
    name: '已取消',
    pageName: RouterMap.MY_ORDER_DETAIL_PAGE,
    builder: wrapBuilder(BuildMyOrderDetailPage),
    orderProcessType: '邮件寄出',
    orderButtonType: '',
    isExpand: true
  },
  {
    name: '已取消-已质检',
    pageName: RouterMap.MY_ORDER_DETAIL_PAGE,
    builder: wrapBuilder(BuildMyOrderDetailPage),
    orderProcessType: '平台质检-取消订单-确认收货2',
    orderButtonType: '',
    isExpand: true
  },
]

@ComponentV2
export struct MyOrderItemView {
  @Param @Require vm: MyOrderPageVM
  @Param @Require item: OrderItem
  // 重新获取搜索列表
  @Param reloadList: () => void = () => {
  }
  // 客服热线控制变量
  @Local serviceHotline: boolean = false

  @Builder
  orderDetail() {

    Column() {
      // 订单商品图片
      Row() {
        Row() {
          Image(this.item.image).width(51).height(57)
        }
        .width(70)
        .height(70)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .border({
          width: 1,
          radius: 8,
          color: 'rgba(0, 0, 0, 0.1)'
        })
        .margin({ left: 12 })

        Column() {
          // 订单商品名称
          Text(this.item.name)
            .width('100%')
            .padding({ right: 12 })
            .fontSize(14)
            .fontColor('rgba(0, 0, 0, 0.9)')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .ellipsisMode(EllipsisMode.END)

          // 订单商品数量 和 是否质检
          Row() {
            Text(`x${this.item.count}`).fontSize(10).fontColor('rgba(0, 0, 0, 0.4)')

            if (this.item.isQuality || this.item.remark === '已取消2') {
              Image($r('app.media.ic_is_quality')).width(36).height(16).margin({ left: 6 })
            }

          }.margin({ top: 2 })

          Blank().height(19)

          // 订单商品价格
          Row() {
            // 商品预估价
            Text('商品预估价').fontSize(12).fontColor('rgba(0, 0, 0, 0.9)').margin({ right: 6 })

            // 价格拼接
            Text('¥').fontSize(12).fontColor('rgba(255, 75, 75, 1)').margin({ top: 3 })

            Text(this.item.price.toFixed(2)).fontSize(16).fontColor('rgba(255, 75, 75, 1)')
          }.height(21).alignItems(VerticalAlign.Center)

        }.layoutWeight(1).padding({ left: 12 }).alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.Start)

      }.width('100%').margin({ top: 8 }).alignItems(VerticalAlign.Top).justifyContent(FlexAlign.Start)

      // 操作栏
      Row() {
        if (this.item.status === '待发货') {
          // 状态： 待发货
          Text('取消订单')
            .width(80)
            .height(28)
            .borderRadius(14)
            .borderWidth(1)
            .borderColor('rgba(0, 0, 0, 0.2)')
            .fontSize(14)
            .fontColor('rgba(0, 0, 0, 0.6)')
            .backgroundColor('rgba(255, 255, 255, 1)')
            .textAlign(TextAlign.Center)
            .onClick(() => {
              promptAction.openCustomDialog({
                builder: () => {
                  this.cancelCustomDialog()
                },
                alignment: DialogAlignment.Center,
                width: '90%'
              })
                .then((id) => {
                  this.vm.cancelDialogId = id
                })

            })

        } else if (this.item.status === '待处理-已质检-确认收款') {
          Row() {
            Text('取消订单')
              .width(80)
              .height(28)
              .borderRadius(14)
              .borderWidth(1)
              .borderColor('rgba(0, 0, 0, 0.2)')
              .fontSize(14)
              .fontColor('rgba(0, 0, 0, 0.6)')
              .backgroundColor('rgba(255, 255, 255, 1)')
              .textAlign(TextAlign.Center)
              .margin({ right: 8 })
              .onClick(() => {
                promptAction.openCustomDialog({
                  builder: () => {
                    this.cancelCustomDialog()
                  },
                  alignment: DialogAlignment.Center,
                  width: '90%'
                })
                  .then((id) => {
                    this.vm.cancelDialogId = id
                  })

              })

            Text('联系客服')
              .width(80)
              .height(28)
              .borderRadius(14)
              .borderWidth(1)
              .borderColor('rgba(0, 0, 0, 0.2)')
              .fontSize(14)
              .fontColor('rgba(0, 0, 0, 0.6)')
              .backgroundColor('rgba(255, 255, 255, 1)')
              .textAlign(TextAlign.Center)
              .margin({ right: 8 })
              .onClick(() => {
                this.serviceHotline = true
              })

            Text('确认收款')
              .width(80)
              .height(28)
              .borderRadius(14)
              .fontSize(14)
              .fontColor('rgba(255, 255, 255, 1)')
              .backgroundColor('rgba(255, 75, 75, 1)')
              .textAlign(TextAlign.Center)
              .onClick(() => {
                promptAction.openCustomDialog({
                  builder: () => {
                    this.confirmOrderDialog()
                  },
                  alignment: DialogAlignment.Center,
                  width: '90%'
                })
                  .then((id) => {
                    this.vm.confirmDialogId = id
                  })
              })
          }.height(28)

        } else if (this.item.status === '待处理-已质检-确认收款-取消订单' ||
          this.item.status === '待处理-已质检-取消订单' || this.item.status === '待处理-取消订单') {
          Text('联系客服')
            .width(80)
            .height(28)
            .borderRadius(14)
            .borderWidth(1)
            .borderColor('rgba(0, 0, 0, 0.2)')
            .fontSize(14)
            .fontColor('rgba(0, 0, 0, 0.6)')
            .backgroundColor('rgba(255, 255, 255, 1)')
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.serviceHotline = true
            })
        } else if (this.item.status === '待处理-已质检' || this.item.status === '待处理') {
          Row() {
            Text('取消订单')
              .width(80)
              .height(28)
              .borderRadius(14)
              .borderWidth(1)
              .borderColor('rgba(0, 0, 0, 0.2)')
              .fontSize(14)
              .fontColor('rgba(0, 0, 0, 0.6)')
              .backgroundColor('rgba(255, 255, 255, 1)')
              .textAlign(TextAlign.Center)
              .margin({ right: 8 })
              .onClick(() => {
                promptAction.openCustomDialog({
                  builder: () => {
                    this.cancelCustomDialog()
                  },
                  alignment: DialogAlignment.Center,
                  width: '90%'
                })
                  .then((id) => {
                    this.vm.cancelDialogId = id
                  })
              })

            Text('联系客服')
              .width(80)
              .height(28)
              .borderRadius(14)
              .borderWidth(1)
              .borderColor('rgba(0, 0, 0, 0.2)')
              .fontSize(14)
              .fontColor('rgba(0, 0, 0, 0.6)')
              .backgroundColor('rgba(255, 255, 255, 1)')
              .textAlign(TextAlign.Center)
              .onClick(() => {
                this.serviceHotline = true
              })
          }.height(28)

        } else if (this.item.status === '已完成') {
          Row() {
            Text('删除订单')
              .width(80)
              .height(28)
              .borderRadius(14)
              .borderWidth(1)
              .borderColor('rgba(0, 0, 0, 0.2)')
              .fontSize(14)
              .fontColor('rgba(0, 0, 0, 0.6)')
              .backgroundColor('rgba(255, 255, 255, 1)')
              .textAlign(TextAlign.Center)
              .onClick(() => {
                promptAction.openCustomDialog({
                  builder: () => {
                    this.deleteOrderDialog()
                  },
                  alignment: DialogAlignment.Center,
                  width: '90%'
                })
                  .then((id) => {
                    this.vm.deleteDialogId = id
                  })

              })
          }.height(28)
        } else if (this.item.status === '已取消-待发货' || this.item.status === '已取消' ||
          this.item.status === '已取消-已质检') {
          Text('删除订单')
            .width(80)
            .height(28)
            .borderRadius(14)
            .borderWidth(1)
            .borderColor('rgba(0, 0, 0, 0.2)')
            .fontSize(14)
            .fontColor('rgba(0, 0, 0, 0.6)')
            .backgroundColor('rgba(255, 255, 255, 1)')
            .textAlign(TextAlign.Center)
            .onClick(() => {
              promptAction.openCustomDialog({
                builder: () => {
                  this.deleteOrderDialog()
                },
                alignment: DialogAlignment.Center,
                width: '90%'
              })
                .then((id) => {
                  this.vm.deleteDialogId = id
                })

            })
        }
      }.width('100%').justifyContent(FlexAlign.End).padding({ right: 12 }).margin({ top: 16, bottom: 16 })
    }
  }

  jump() {
    jumpType.forEach((item: JumpType) => {
      if (item.name === this.item.status) {
        phoneRouterControl.jumpPage({
          pageName: item.pageName,
          builder: item.builder,
          param: this.buildMyOrderDetailParam(item)
        })
      }
    })
  }

  /**
   * 组装订单详情参数
   */
  private buildMyOrderDetailParam(item: JumpType) {
    // 封装跳转页面的参数对象
    const paramInfo: MyOrderDetailPageInfo = new MyOrderDetailPageInfo()
    paramInfo.orderInfo = this.item
    paramInfo.orderProcessType = item.orderProcessType
    paramInfo.orderButtonType = item.orderButtonType
    paramInfo.isExpand = item.isExpand
    return paramInfo
  }

  build() {
    Column() {
      Row() {
        // 订单商店名称
        Text('回收服务').fontSize(16).fontColor('rgba(0, 0, 0, 0.6)').margin({ left: 15, top: 13, bottom: 13 })

        Blank().layoutWeight(1)

        // 订单状态
        Text(this.item.status.split('-')[0])
          .fontSize(14)
          .fontColor(this.item.status.split('-')[0] === '待发货' || this.item.status.split('-')[0] === '待处理' ?
            'rgba(255, 75, 75, 1)' :
            'rgba(0, 0, 0, 0.4)')
          .margin({ top: 13, bottom: 12, right: 12 })
      }
      .width('100%')
      .height(44)
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)

      // 订单详情
      this.orderDetail()
    }
    .width('100%')
    .borderRadius(16)
    .backgroundColor('rgba(255, 255, 255, 1)')
    .onClick(() => {
      this.jump()
    })
    .bindSheet($$this.serviceHotline, this.dealWithHotlineDialog(),
      {
        showClose: false,
        detents: [170],
        preferType: SheetType.BOTTOM,
      })
  }

  // 取消订单
  @Builder
  cancelCustomDialog() {
    CancelOrderItemDialog({
      vm: this.vm,
      orderInfo: this.item
    })
  }

  // 删除订单
  @Builder
  deleteOrderDialog() {
    DeleteOrderItemDialog({
      vm: this.vm,
      orderInfo: this.item
    })
  }

  // 确认收款
  @Builder
  confirmOrderDialog() {
    ConfirmOrderItemDialog({
      vm: this.vm,
      orderInfo: this.item
    })
  }

  @Builder
  dealWithHotlineDialog() {
    CustomerServiceDialogBuilder('客服', '000-****-0000', () => {
      this.serviceHotline = false
    }, $r('app.media.ic_public_close_sheet'), 170)
  }
}