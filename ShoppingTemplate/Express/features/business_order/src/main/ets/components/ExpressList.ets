import { QueryPageVM } from '../viewModels/QueryPageVM'
import { CustomContentDialog, TipsDialog } from '@kit.ArkUI'
import { ExpressStatus, IOrder, OrderStatus, PaymentMethod, RouterModule } from 'lib_foundation'
import { CommonUtil, RouterMap, CommonDivider, OrderType } from 'module_base'

@ComponentV2
export struct ExpressList {
  vm: QueryPageVM = QueryPageVM.instance
  dialogControllerDelete: CustomDialogController = new CustomDialogController({
    builder: TipsDialog({
      content: '是否删除当前订单?',
      primaryButton: {
        value: '取消',
        action: () => {
          console.info('Callback when the first button is clicked')
        },
      },
      secondaryButton: {
        value: '删除',
        role: ButtonRole.ERROR,
        action: () => {
          this.vm.deleteOrder(this.vm.deleteExpressId)
        },
      },
    }),
  })
  editDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.buildContent();
      },
      contentAreaPadding: {
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
      },
    }),
  })
  payDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.payBuildContent();
      },
      contentAreaPadding: {
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
      },
    }),
  })

  build() {
    if (this.vm.orderList.length <= 0) {
      Column() {
        Image($r('app.media.ic_send_null'))
          .width(120)
          .height(120)
          .margin({ top: 24, bottom: 24 })
        Text('点击“寄快递”，开启寄件吧')
          .fontSize(14)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_tertiary'))
          .onClick(() => {
            if (!this.vm.userInfoModel.isLogin) {
              RouterModule.push({ url: RouterMap.QUICK_LOGIN_PAGE })
              return
            }
            RouterModule.push({ url: RouterMap.EXPRESS_PAGE })
          })
      }
      .width('100%')
      .height(232)
      .backgroundColor(Color.White)
      .borderRadius(16)
    } else {
      List() {
        ForEach(this.vm.orderList, (order: IOrder) => {
          ListItem() {
            Column() {
              Column() {
                Row() {
                  Text() {
                    Span(order.companyName)
                    Span('：')
                    Span(order.orderNo)
                  }
                  .fontSize(10)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_tertiary'))
                  .margin({ right: 4 })

                  Image($r('app.media.ic_duplicating'))
                    .width(14)
                    .height(14)
                    .onClick(() => {
                      CommonUtil.copyText(order.orderNo)
                    })
                }
                .width('100%')
                .margin({ bottom: 12 })

                Flex() {
                  Column() {
                    Text(order.sendAddress.city)
                      .fontSize(18)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                      .margin({ bottom: 4 })
                    Text(order.sendAddress.name)
                      .fontSize(14)
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_secondary'))
                  }
                  .width('100%')
                  .flexGrow(1)

                  Column() {
                    Image($r('app.media.send'))
                      .width(18)
                      .height(18)
                      .margin({ bottom: 9 })
                    Text(order.expressStatus)
                      .fontSize(10)
                      .fontWeight(FontWeight.Regular)
                      .fontColor('#0A59F7')
                  }
                  .flexShrink(0)

                  Column() {
                    Text(order.getAddress.city)
                      .fontSize(18)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.font_primary'))
                      .margin({ bottom: 4 })
                    Text(order.getAddress.name)
                      .fontSize(14)
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_secondary'))
                  }
                  .width('100%')
                  .flexGrow(1)
                }
                .margin({ bottom: 16 })
                .onClick(() => {
                  if (order.paymentMethod === PaymentMethod.PAY_NOW && order.status === OrderStatus.DO_ING) {
                    return
                  }
                  if (this.vm.type === OrderType.RECEIVE) {
                    RouterModule.push({ url: RouterMap.ORDER_INFO_PAGE, param: order.id })
                    return
                  }
                  if (order.paymentMethod === PaymentMethod.PAY_ON_DELIVERY &&
                    order.expressStatus === ExpressStatus.PICKUP_PENDING) {
                    RouterModule.push({ url: RouterMap.EDIT_ORDER_PAGE, param: order.id })
                    return
                  }
                  if (order.expressStatus === ExpressStatus.CANCEL) {
                    return
                  } else if (order.expressStatus === ExpressStatus.PICKUP_PENDING) {
                    RouterModule.push({ url: RouterMap.EDIT_ORDER_PAGE, param: order.id })
                  } else {
                    RouterModule.push({ url: RouterMap.ORDER_INFO_PAGE, param: order.id })
                  }
                })

                Row() {
                  Text() {
                    Span('预计送达时间：')
                      .fontColor($r('sys.color.font_tertiary'))
                    Span(order.deliveryTime)
                      .fontColor($r('sys.color.font_secondary'))
                  }
                  .fontSize(10)
                  .fontWeight(FontWeight.Regular)
                }
                .width('100%')
                .margin({ bottom: 12 })

                if (order.remark) {
                  Row() {
                    Text(`备注：${order.remark}`)
                      .fontSize(10)
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_tertiary'))
                  }
                  .width('100%')
                  .padding({
                    top: 7,
                    bottom: 7,
                    left: 8,
                    right: 8,
                  })
                  .borderRadius(8)
                  .backgroundColor('rgba(0,0,0,0.05)')
                  .margin({ bottom: 12 })
                }

                if (order.price) {
                  Row() {
                    Text(`￥${order.price}`)
                      .fontSize(18)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#0A59F7')
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.End)
                  .margin({ bottom: 12 })
                }
              }

              CommonDivider()
                .margin({ bottom: 12 })

              Row() {
                if (order.expressStatus === ExpressStatus.CANCEL) {
                  Button('删除', { controlSize: ControlSize.SMALL })
                    .width(72)
                    .backgroundColor(Color.White)
                    .borderWidth(1)
                    .borderStyle(BorderStyle.Solid)
                    .borderColor('rgba(0,0,0,0.10)')
                    .fontColor($r('sys.color.font_tertiary'))
                    .borderRadius(20)
                    .margin({ right: 8 })
                    .onClick(() => {
                      this.vm.deleteExpressId = order.id
                      this.dialogControllerDelete.open()
                    })
                }
                Button('添加备注', { controlSize: ControlSize.SMALL })
                  .width(72)
                  .backgroundColor(Color.White)
                  .borderWidth(1)
                  .borderStyle(BorderStyle.Solid)
                  .borderColor('rgba(0,0,0,0.10)')
                  .fontColor($r('sys.color.font_tertiary'))
                  .borderRadius(20)
                  .onClick(() => {
                    this.vm.selectedOrder = order
                    this.editDialogController.open()
                  })
                if (order.status === OrderStatus.DO_ING) {
                  Button('立即支付', { controlSize: ControlSize.SMALL })
                    .width(72)
                    .backgroundColor(Color.White)
                    .borderWidth(1)
                    .borderStyle(BorderStyle.Solid)
                    .borderColor('rgba(0,0,0,0.10)')
                    .backgroundColor('#0A59F7')
                    .fontColor($r('sys.color.font_on_primary'))
                    .borderRadius(20)
                    .margin({ left: 8 })
                    .onClick(() => {
                      this.vm.selectedOrder = order
                      this.payDialogController.open()
                    })
                }
              }
              .width('100%')
              .justifyContent(FlexAlign.End)
            }
            .padding(12)
          }
          .borderRadius(16)
          .backgroundColor(Color.White)
          .margin({ bottom: 12 })
        }, (item: IOrder[]) => JSON.stringify(item))
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
  }

  // 自定义弹出框的内容区
  @Builder
  buildContent(): void {
    Column() {
      Scroll() {
        Column() {
          Row() {
            Text('修改备注')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .margin({ bottom: 12 })

          Row() {
            TextInput({ text: $$this.vm.remake, placeholder: '请输入备注' })
              .placeholderColor($r('sys.color.font_secondary'))
              .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
              .height(40)
              .fontSize(14)
              .backgroundColor(Color.Transparent)
          }
          .width('100%')
          .height(40)
          .padding({ left: 12, right: 12 })
          .margin({ bottom: 18 })
          .backgroundColor('rgba(0,0,0,0.05)')
          .borderRadius(8)

          Row() {
            this.cancelButton(() => {
              this.vm.remake = ''
              this.editDialogController.close()
            })
            this.saveButton(
              () => {
                if (this.vm.selectedOrder && this.vm.remake) {
                  this.vm.addRemakeToOrder(this.vm.selectedOrder.id, this.vm.remake)
                }
                this.editDialogController.close()
              },
            )
          }
          .margin({ top: 28 })
        }
        .width('100%')
        .padding({
          top: 24,
          bottom: 16,
          left: 24,
          right: 24,
        })
        .backgroundColor('rgba(255,255,255,0.80)')
      }
      .scrollBar(BarState.Off)
    }
  }

  // 自定义弹出框的内容区
  @Builder
  payBuildContent(): void {
    Column() {
      Scroll() {
        Column() {
          Row() {
            Text('支付金额')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .margin({ bottom: 12 })

          Row() {
            Text(this.vm.selectedOrder?.price.toString() ?? '100')
              .fontSize(24)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FE543A')
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .margin({ bottom: 12 })

          Row() {
            this.cancelButton(() => {
              this.payDialogController.close()
            })
            this.saveButton(() => {
              this.vm.prepay()
              this.payDialogController.close()
            })
          }
          .margin({ top: 28 })
        }
        .width('100%')
        .padding({
          top: 24,
          bottom: 16,
          left: 24,
          right: 24,
        })
        .backgroundColor('rgba(255,255,255,0.80)')
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }
  }

  @Builder
  cancelButton(func: Function) {
    Row() {
      Text('取消')
    }
    .width('50%')
    .height(40)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      func()
    })
  }

  @Builder
  saveButton(func: Function) {
    Row() {
      Button('确认')
        .width('100%')
        .height(40)
        .backgroundColor('#0A59F7')
    }
    .width('50%')
    .height(40)
    .onClick(() => {
      func()
    })
  }
}