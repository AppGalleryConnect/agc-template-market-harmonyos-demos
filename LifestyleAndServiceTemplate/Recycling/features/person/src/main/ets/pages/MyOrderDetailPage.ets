import { Constants } from 'common';
import { phoneRouterControl } from 'oh_router';
import { CustomerServiceDialogBuilder } from 'valuation_information';
import { MyOrderDetailPageInfo, MyOrderPageVM, OrderItem } from '../viewmodel/MyOrderPageVM';
import { CancelOrderItemDialog } from '../views/MyOrder/CancelOrderItemDialog';
import { MyOrderProcessOneView } from '../views/MyOrder/MyOrderProcessOneView';
import { promptAction } from '@kit.ArkUI';
import { MyOrderTitleView } from '../views/MyOrder/MyOrderTitleView';
import { MyOrderButtonView } from '../views/MyOrder/MyOrderButtonView';
import { MyOrderProductAndInfoView } from '../views/MyOrder/MyOrderProductAndInfoView';
import { MyOrderProcessThreeView } from '../views/MyOrder/MyOrderProcessThreeView';
import { DeleteOrderItemDialog } from '../views/MyOrder/DeleteOrderItemDialog';
import { ConfirmOrderItemDialog } from '../views/MyOrder/ConfirmOrderItemDialog';

@Builder
export function BuildMyOrderDetailPage(info: Object): void {
  MyOrderDetailPage({ orderInfo: info as MyOrderDetailPageInfo })
}

@ComponentV2
export struct MyOrderDetailPage {
  // 日志打印
  private logTag: string = 'MyOrderDetailPage'
  @Param vm: MyOrderPageVM = MyOrderPageVM.instance
  @Param @Require orderInfo: MyOrderDetailPageInfo;
  // 热线控制变量
  @Local isHotline: boolean = false;

  // 渲染主页
  @Builder
  render() {
    RelativeContainer() {
      Column() {
        // 标题区域
        MyOrderTitleView({
          changeIsHotline: (isHotline: boolean) => {
            this.isHotline = isHotline
          }
        })

        // 内容区域
        Scroll() {
          Column() {
            if (this.orderInfo.orderProcessType === '上门取件') {
              // 第一流程布局
              MyOrderProcessOneView({ order: this.orderInfo.orderInfo }).margin({ bottom: 12 })
            } else {
              // 其他流程图布局
              MyOrderProcessThreeView({ order: this.orderInfo.orderInfo, orderType: this.orderInfo.orderProcessType })
                .margin({ bottom: 12 })
            }

            // 商品信息
            MyOrderProductAndInfoView({ orderInfo: this.orderInfo.orderInfo, isExpand: this.orderInfo.isExpand })
          }.padding({ top: 16, left: 16, right: 16 }).width('100%')
        }
        .width('100%')
        .align(Alignment.Top)
        .layoutWeight(1)
        .backgroundColor('rgba(245, 245, 245, 1)')

        if (this.orderInfo.orderButtonType !== '') {
          MyOrderButtonView({
            clickEvent: () => {
              if (this.orderInfo.orderButtonType === 'cancel' || this.orderInfo.orderButtonType === 'confirm') {
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
              } else if (this.orderInfo.orderButtonType === 'delete') {
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
              }

            }, clickEvent2: () => {
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
            }, type: this.orderInfo.orderButtonType
          })
        }

      }
      .width('100%')
      .height('100%')

    }
    .bindSheet($$this.isHotline, this.dealWithHotlineDialog(),
      {
        showClose: false,
        detents: [170],
        preferType: SheetType.BOTTOM,
      })
    .width('100%')
    .height('100%')

  }

  @Builder
  dealWithHotlineDialog() {
    CustomerServiceDialogBuilder('客服', '000-****-0000', () => {
      this.isHotline = false
    }, $r('app.media.ic_public_close_sheet'), 170)
  }

  // 取消订单
  @Builder
  cancelCustomDialog() {
    CancelOrderItemDialog({
      vm: this.vm,
      orderInfo: this.orderInfo.orderInfo,
      fromPage: 'MyOrderDetailPage'
    })
  }

  // 删除订单
  @Builder
  deleteOrderDialog() {
    DeleteOrderItemDialog({
      orderInfo: this.orderInfo.orderInfo,
      vm: this.vm,
      fromPage: 'MyOrderDetailPage'
    })
  }

  // 确认收款
  @Builder
  confirmOrderDialog() {
    ConfirmOrderItemDialog({
      vm: this.vm,
      orderInfo: this.orderInfo.orderInfo,
      fromPage: 'MyOrderDetailPage'
    })
  }

  build() {
    NavDestination() {
      this.render()
    }
    .title('订单详情')
    .hideTitleBar(true)
    .padding({ top: Constants.PADDING_7XL })
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
  }
}