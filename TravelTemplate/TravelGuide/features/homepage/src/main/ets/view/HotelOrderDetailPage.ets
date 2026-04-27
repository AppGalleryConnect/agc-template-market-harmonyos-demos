import { BarVM, GlobalContext, RouterMap, TValueType } from 'common'
import {
  HotelDateModel,
  HotelModel,
  MyOrderList,
  OrderInfo,
  OrderStatus,
  PassengerInfo,
  TourOrderRouterParam,
  TravelAggregatedPaymentKey
} from 'common_travel_guide'
import { phoneRouterControl } from 'oh_router'
import { HotelOrderDetailPageVM } from '../viewmodel/HotelOrderDetailPageVM'
import { ReimbursementVoucherPageBuilder } from './ReimbursementVoucherPage'
import { aggregatedPaymentService, CashierPicker, PaymentType } from 'aggregated_payment'
import { AppStorageV2, promptAction } from '@kit.ArkUI'
import { common, Want } from '@kit.AbilityKit'
import deviceInfo from '@ohos.deviceInfo'
import { ChooseStatus } from '../viewmodel/HotelPageVM'

@Builder
export function HotelOrderDetailPageBuilder(params: TValueType) {
  HotelOrderDetailPage({
    pageParams: params as TourOrderRouterParam
  })
}

phoneRouterControl.registerPageBuilder('HotelOrderDetailPage', wrapBuilder(HotelOrderDetailPageBuilder))

@ComponentV2
export struct HotelOrderDetailPage {
  vm: HotelOrderDetailPageVM = new HotelOrderDetailPageVM()
  @Param @Require pageParams: TourOrderRouterParam
  @Local info: string = 'orderInfo'
  @Local hotelModel: HotelModel = Object()
  @Local hotelDate: HotelDateModel = Object()
  @Local totalPrice: number = 0
  @Local roomType: string = ''
  @Local orderId: string = ''
  @Local phoneNum: string = ''
  @Local startTime: string = ''
  @Local endTime: string = ''
  @Local roomDesc: string = ''
  @Local orderInfo: OrderInfo = Object()
  @Local createTime?: string = '' //订单创建时间
  @Local createDate?: string = '' //订单创建日期
  @Local laterPayTime: Date = new Date()
  @Local countDownTime: string = ''
  @Local scenicPayType: string = ''
  @Local totalDays: number = 0
  @Local chooseStatus: ChooseStatus = ChooseStatus.Domestic
  @Local passengerInfo: PassengerInfo[] = []
  @Local isPulUpPay: boolean = false
  @Local orderList: MyOrderList = AppStorageV2.connect(MyOrderList, () => new MyOrderList())!
  @Local travelPaymentKey: TravelAggregatedPaymentKey =
    AppStorageV2.connect(TravelAggregatedPaymentKey, 'travelAggregatedPaymentKey',
      () => new TravelAggregatedPaymentKey())!;
  private uiContext: UIContext = this.getUIContext();
  private navPathStack: NavPathStack = new NavPathStack();
  private cashierPicker: CashierPicker = new CashierPicker(this.uiContext)
    .onRealPayment(async (type: PaymentType) => {
      // todo: 根据支付类型向服务器请求支付所需参数
      if (type === PaymentType.ALIPAY) {
        /**
         * 请求拉起支付宝
         *
         * 临时测试时，orderInfo 不推荐传入空字符串，这会导致跳转至支付宝行为仅仅是跳转，不会有支付相关的交互
         * 未安装支付宝且参数真实时，SDK 会尝试使用 this.navPathStack 跳转至 H5 页面继续支付，该参数可不传
         */
        aggregatedPaymentService.requestPaymentByAliPay({ orderInfo: this.info }, this.navPathStack);

      } else if (type === PaymentType.HUAWEI) {
        /**
         * 请求拉起华为支付
         */
        if (deviceInfo.marketName === 'emulator') {
          this.showToast('华为支付在模拟器场景下无任何响应');
          return;
        }
        aggregatedPaymentService.requestPaymentByHuawei(this.uiContext, { orderStr: '' });
      } else if (type === PaymentType.WECHAT) {
        /**
         * 请求拉起微信支付
         *
         * 微信支持获取拉起结果，如果拉起成功，则可以进一步尝试等待支付回调。如果拉起失败，则不会有支付回调。
         */
        const isWeChatOpenSuccess: boolean =
          await aggregatedPaymentService.requestPaymentByWeChat(this.uiContext, {
            partnerId: '',
            prepayId: '',
            nonceStr: '',
            timeStamp: '',
            sign: ''
          });
        if (!isWeChatOpenSuccess) {
          this.showToast('微信拉起失败');
        }
      }
    })
    .onWillDismiss((reason: DismissReason) => {
      if (reason === DismissReason.TOUCH_OUTSIDE) {
        this.showToast('已拦截点击其它区域进行关闭的交互方式');
      } else {
        this.cashierPicker.close();
      }
    });

  // 获取已取消状态时，需要在mm:ss之前完成交付
  getLaterPayTime() {
    // 对指定时间操作
    let beginTime = `${this.createDate} ${this.createTime}`
    let time = new Date(beginTime);
    time.setMinutes(time.getMinutes() + 10);
    this.laterPayTime = time;
    let hours = String(time.getHours()).padStart(2, '0');
    let minutes = String(time.getMinutes()).padStart(2, '0');
    return `${hours}:${minutes}`;
  }

  // 到指定时间的倒计时
  countTargetTime(targetTime: Date) {
    const target = new Date(targetTime).getTime();
    const timer = setInterval(() => {
      const now = new Date().getTime();
      const distance = target - now;
      if (distance <= 0) {
        clearInterval(timer);
        // 倒计时结束，取消订单
        this.vm.orderStatus = OrderStatus.CANCEL
        this.orderInfo.cancelOrder()
        return;
      }
      // 分、秒
      const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
      const seconds = Math.floor((distance % (1000 * 60)) / 1000);
      this.countDownTime = `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`
    }, 1000);
  }

  private showToast(msg: string): void {
    this.uiContext.getPromptAction().showToast({ message: `Test: ${msg}` });
  }

  aboutToAppear(): void {
    this.orderInfo = (this.pageParams as TourOrderRouterParam)?.orderInfo
    this.isPulUpPay = (this.pageParams as TourOrderRouterParam)?.isPulUpPay
    this.hotelModel = (this.orderInfo as OrderInfo)?.detailInfo.hotelModel as HotelModel
    this.hotelDate = (this.orderInfo as OrderInfo)?.detailInfo.hotelDate as HotelDateModel
    this.totalPrice = (this.orderInfo as OrderInfo)?.detailInfo?.totalPrice as number
    this.roomType = (this.orderInfo as OrderInfo)?.detailInfo?.roomType as string
    this.orderId = (this.orderInfo as OrderInfo)?.detailInfo.id as string
    this.phoneNum = (this.orderInfo as OrderInfo)?.detailInfo.phoneNum as string
    this.roomDesc = (this.orderInfo as OrderInfo)?.detailInfo.roomDesc as string
    this.startTime = (this.orderInfo as OrderInfo)?.detailInfo.startTime as string
    this.endTime = (this.orderInfo as OrderInfo)?.detailInfo.endTime as string
    this.createDate = (this.orderInfo as OrderInfo)?.detailInfo.createDate as string
    this.createTime = (this.orderInfo as OrderInfo)?.detailInfo.createTime as string
    this.scenicPayType = (this.orderInfo as OrderInfo)?.detailInfo.scenicPayType as string
    this.totalDays = (this.orderInfo as OrderInfo)?.detailInfo.totalDays as number
    this.chooseStatus = (this.orderInfo as OrderInfo)?.detailInfo.chooseStatus as ChooseStatus
    this.passengerInfo = (this.orderInfo as OrderInfo)?.passengerInfo as PassengerInfo[]
    this.vm.orderStatus = this.orderInfo.status
    this.showFinished()
    // 如果是从我的订单页面，点击去付款跳转过来的，需要立即拉起支付弹框
    if (this.isPulUpPay) {
      const pad2 = (n: number) => n.toString().padStart(2, '0');
      let orderTime = new Date();
      this.createDate = `${orderTime.getFullYear()}-${pad2(orderTime.getMonth() + 1)}-${pad2(orderTime.getDate())}`;
      // 拉起支付弹框
      this.cashierPicker
        .reset() // 内部状态重置
        .setAmount(12801) // 支付金额，单位：分
        .setTradeSummary('这里是一行订单摘要') // 订单摘要 (可选，不填则不显示)
        .open();
    }
    // 如果是已取消状态，处理倒计时
    if (this.vm.orderStatus === OrderStatus.PENDING) {
      this.getLaterPayTime()
      this.countTargetTime(this.laterPayTime)
    }
    // 端侧支付回调仅可用于参考，以辅助提升支付结果判定效率，不建议完全依赖。如：实际支付成功，但支付回调没有触发。
    this.travelPaymentKey.value = aggregatedPaymentService.registerPaymentCallback(
      (type: PaymentType, isSuccess: boolean, key?: string) => {
        if (this.travelPaymentKey.value === key) {
          // 关闭支付弹框
          this.cashierPicker.close();
          this.vm.orderStatus = OrderStatus.BOOKED
          this.orderInfo.status = OrderStatus.BOOKED
          const pad2 = (n: number) => n.toString().padStart(2, '0');
          const orderTime = new Date();

          const createDate =
            `${orderTime.getFullYear()}-${pad2(orderTime.getMonth() + 1)}-${pad2(orderTime.getDate())}`;
          this.orderInfo.detailInfo.paymentDate = createDate
          this.orderInfo.hotelPayedData()
        }
      }
    );
  }

  // 判断是否完成订单
  showFinished() {
    const date = new Date()
    if (date.getTime() > this.hotelDate.checkOutDate.getTime()) {
      this.orderInfo.hotelFinish()
      this.vm.orderStatus = OrderStatus.FINISHED
    }
  }

  private CustomDialog(msg: ResourceStr, sureAction: () => void) {
    GlobalContext.getUIContext().showAlertDialog({
      message: msg,
      autoCancel: false,
      alignment: DialogAlignment.Center,
      showInSubWindow: true,
      isModal: true,
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      buttons: [
        {
          value: '取消',
          action: () => {
          }
        },
        {
          value: '确定',
          action: () => {
            sureAction()
          }
        }
      ]
    })

  }

  build() {
    NavDestination() {
      this.render()
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      this.vm.backPage();
      return true
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  TopBuilder() {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        Image($r('app.media.ic_hotel_detail_bg')).width('100%').height(241)
        Column() {
          Row() {
            Image($r('app.media.ic_back_black')).width(40).height(40)
              .onClick(() => {
                this.vm.backPage();
              })
            Text('订单详情').fontSize(20).fontColor('#000000').margin({ left: 8 })
          }.justifyContent(FlexAlign.Start).width('100%').padding({ left: 16, right: 16 })

          this.orderDetail()

        }.padding({ top: BarVM.instance.staBarH })
      }
    }.width('100%').height('100%')
  }

  // 根据不同状态展示不同订单描述文案
  getOrderDescription(status: OrderStatus) {
    let description: string = ''
    switch (status) {
      case OrderStatus.FINISHED:
        description = '您的订单已完成，期待您的再次预定'
        break;
      case OrderStatus.BOOKED:
        description = '请尽快前往酒店办理入住'
        break;
      case OrderStatus.PENDING:
        description = '订单即将关闭，请尽快支付'
        break;
      case OrderStatus.CANCEL:
        description = '您的订单已取消，请重新下单'
        break;
      case OrderStatus.REFUNDED:
        description = '退款已到账'
        break;
      default:
        break;
    }
    return description;
  }

  getOrderStatusText(status: OrderStatus) {
    let statusText: string = ''
    switch (status) {
      case OrderStatus.FINISHED:
        statusText = '已完成'
        break;
      case OrderStatus.BOOKED:
        statusText = '已预定'
        break;
      case OrderStatus.PENDING:
        statusText = '待支付'
        break;
      case OrderStatus.CANCEL:
        statusText = '已取消'
        break;
      case OrderStatus.REFUNDED:
        statusText = '已取消'
        break;
      default:
        break;
    }
    return statusText;
  }

  @Builder
  orderDetail() {
    Scroll() {
      Column() {
        if (this.vm.orderStatus === OrderStatus.PENDING) {
          Row() {
            Row() {
              Image($r('app.media.ic_pending_payment')).width(20).height(20)
              Text(this.getOrderStatusText(this.vm.orderStatus)).titleStatusStyle().margin({ left: 6 })
            }

            Text(this.countDownTime).titleStatusStyle()
          }.justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center).width('100%')

          Text(this.getOrderDescription(this.vm.orderStatus))
            .contentStatusStyle()
        } else {
          Text(this.getOrderStatusText(this.vm.orderStatus))
            .titleStatusStyle()
          Text(this.getOrderDescription(this.vm.orderStatus))
            .contentStatusStyle()
        }

        this.orderContent()

        this.orderHotelInfo()

        if (this.vm.orderStatus === OrderStatus.FINISHED || this.vm.orderStatus === OrderStatus.CANCEL ||
          this.vm.orderStatus === OrderStatus.REFUNDED) {
          Column() {
            Text('住客信息').contentStyle().margin({ bottom: 16 })
            Row() {
              Image($r('app.media.ic_person_info')).width(16).height(16)
              ForEach(this.passengerInfo, (item: PassengerInfo) => {
                Row({ space: 10 }) {
                  Text(item.name)
                    .contentStyle().margin({ left: 8 })
                }.height(46).justifyContent(FlexAlign.SpaceBetween)
              }, (item: PassengerInfo) => item.toString())
            }.margin({ bottom: 16 }).width('100%').justifyContent(FlexAlign.Start)

            Row() {
              Image($r('app.media.ic_phone_tip')).width(16).height(16)
              Text(this.phoneNum.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2')).contentStyle().margin({ left: 8 })
            }.width('100%').justifyContent(FlexAlign.Start)

          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .margin({ top: 12 })
          .padding({
            left: 14,
            right: 14,
            top: 16,
            bottom: 16
          })
        }
      }.padding({ left: 16, right: 16, bottom: 100 }).width('100%').alignItems(HorizontalAlign.Start)
    }
    .margin({ top: 30 })
    .padding({ bottom: BarVM.instance.staBarH })
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.Off)
  }

  @Builder
  orderContent() {
    Column() {
      Row() {
        Image($r('app.media.ic_comfortable_one_abbreviate')).width(72).height(54).borderRadius(8)
        Text(this.hotelModel.name)
          .titleTextStyle()
          .maxLines(2)
          .margin({ left: 10 })
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
      }.alignItems(VerticalAlign.Top).width('100%')

      Row() {
        Text('总价')
          .fontSize(20)
          .fontColor('#000000')
          .fontWeight(500)
          .lineHeight(21)
        Text(`¥${this.totalPrice}`)
          .fontSize(20)
          .fontColor('#FF4A26')
          .fontWeight(500)
          .lineHeight(21)
      }.width('100%').margin({ top: 18, bottom: 16 }).justifyContent(FlexAlign.SpaceBetween)

      Column() {
        Row() {
          Text('订单号：').titleStyle()
          Text(this.orderId).contentStyle()
        }.rowStyle()

        Row() {
          Text('下单时间：').titleStyle()
          Text(`${this.orderInfo.detailInfo.createDate}`).contentStyle()
        }.rowStyle()

        if (this.vm.orderStatus !== OrderStatus.PENDING && this.vm.orderStatus !== OrderStatus.CANCEL) {
          Row() {
            Text('付款时间：').titleStyle()
            Text(`${this.orderInfo.detailInfo.paymentDate}`)
              .contentStyle()

          }.rowStyle()

          Row() {
            Text('支付方式：').titleStyle()
            Text(this.scenicPayType).contentStyle()
          }.rowStyle()
        }

        if (this.vm.orderStatus === OrderStatus.REFUNDED) {
          Row() {
            Text('退款时间：').titleStyle()
            Text(this.orderInfo.detailInfo?.scenicRefundCreateDate).contentStyle()
          }.rowStyle()

          Row() {
            Text('退款账户：').titleStyle()
            Text('中国银行（8888）').contentStyle()
          }.rowStyle()

          Row() {
            Text('退款金额').titleStyle()
            Text(`¥${this.totalPrice.toString()}`).contentStyle()
          }.rowStyle()
        }

        Row() {
          Row() {
            Image($r('app.media.ic_time_interval')).width(16).height(16)
            Column() {
              Text(this.chooseStatus !== ChooseStatus.Hourly ?
                this.vm.formatDate(this.startTime) + '-' + this.vm.formatDate(this.endTime) :
              this.vm.formatDate(this.startTime)).contentStyle()
              Text('入住：14:00后').titleStyle().margin({ top: 8, bottom: 4 })
              Text('离店：14:00前').titleStyle()
            }.alignItems(HorizontalAlign.Start).margin({ left: 10 })

          }.alignItems(VerticalAlign.Top)

          Text(this.chooseStatus !== ChooseStatus.Hourly ? `${this.totalDays.toString()}晚` : '0晚')
            .contentStyle()
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Top)
        .margin({ bottom: 22 })

        Row() {
          Image($r('app.media.ic_location_tip')).width(12).height(15)
          Column() {
            Text('酒店位置').contentStyle()
            Text(this.hotelModel.position)
              .titleStyle()
              .margin({ top: 8, bottom: 8 })
            Text('地图/导航').contentStyle()
              .onClick(() => {
                let petalMapWant: Want = {
                  bundleName: 'com.huawei.hmos.maps.app',
                  uri: 'maps://',
                  parameters: {
                    linkSource: 'com.huawei.travelguide',
                    destinationLatitude: 31.968,
                    destinationLongitude: 118.799,
                    destinationName: this.hotelModel.name,
                    vehicleType: 0,
                  }
                }
                let context = getContext(this) as common.UIAbilityContext;
                context.startAbility(petalMapWant);
              })
            Divider().width(53).color($r('sys.color.comp_divider'));
          }.margin({ left: 10 }).alignItems(HorizontalAlign.Start).layoutWeight(1)
        }.width('100%').justifyContent(FlexAlign.Start).alignItems(VerticalAlign.Top)
      }.width('100%')
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ top: 20 })
    .padding({
      left: 12,
      right: 12,
      top: 16,
      bottom: 16
    })
  }

  @Builder
  orderHotelInfo() {
    Column() {
      Row() {
        Image($r('app.media.ic_comfortable_one_abbreviate')).width(72).height(54).borderRadius(8)
        Column() {
          Text(this.roomType)
            .titleTextStyle()
          Text(this.roomDesc)
            .titleTextStyle()
        }.justifyContent(FlexAlign.SpaceAround).margin({ left: 10 }).alignItems(HorizontalAlign.Start)
      }
      .margin({ bottom: 19 })
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)

      Row() {
        Image($r('app.media.ic_number_of_people')).width(16).height(16)
        Text('该房型最多住2人，最多2成人').contentStyle().margin({ left: 8 })
      }.margin({ bottom: 20 }).width('100%').justifyContent(FlexAlign.Start)

      Row() {
        Image($r('app.media.ic_bed_size')).width(16).height(16)
        if (this.hotelModel.type === '舒适双床房') {
          Text('2张1.2米单人床').contentStyle().margin({ left: 8 })
        } else {
          Text('1张1.5米双人床').contentStyle().margin({ left: 8 })
        }

      }.margin({ bottom: 20 }).width('100%').justifyContent(FlexAlign.Start)

      Row() {
        Image($r('app.media.ic_breakfast')).width(16).height(16)
        Text('无早餐').contentStyle().margin({ left: 8 })
      }.margin({ bottom: 17 }).width('100%').justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ top: 12 })
    .padding({
      left: 12,
      right: 12,
      top: 16,
      bottom: 16
    })
  }



  @Builder
  render() {
    Stack({ alignContent: Alignment.BottomStart }) {
      this.TopBuilder()

      if (this.vm.orderStatus === OrderStatus.PENDING) {
        Row() {
          Row() {
            Text('取消订单')
              .fontSize(14)
              .fontColor('#333333')
              .fontWeight(500)
          }
          .onClick(() => {
            promptAction.openCustomDialog({
              builder: () => {
                this.CustomDialog('确定取消订单？', () => {
                  this.vm.orderStatus = OrderStatus.CANCEL
                  this.orderInfo.cancelOrder()
                })
              },
              alignment: DialogAlignment.Center,
              width: '90%'
            })
              .then((id) => {
                this.vm.dialogId = id
              })
          })
          .width('45%')
          .height(40)
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .borderRadius(24)
          .borderWidth(0.5)
          .borderColor('rgba(0, 0, 0, 0.10)')

          Row() {
            Text('去支付')
              .fontSize(14)
              .fontColor('#333333')
              .fontWeight(500)
          }
          .onClick(() => {
            this.cashierPicker
              .reset()// 内部状态重置
              .setAmount(this.totalPrice * 100)// 支付金额，单位：分
              .setTradeSummary(this.hotelModel.name)// 订单摘要 (可选，不填则不显示)
              .open();
          })
          .width('45%')
          .height(40)
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .borderRadius(24)
          .backgroundColor('#FFE431')
        }
        .height(92)
        .width('100%')
        .backgroundColor('#FFFFFF')
        .padding({ left: 16, right: 16 })
        .justifyContent(FlexAlign.SpaceBetween)
      } else if (this.vm.orderStatus === OrderStatus.FINISHED) {
        Row() {
          Row() {
            Text('报销凭证')
              .fontSize(14)
              .fontColor('#333333')
              .fontWeight(500)
          }
          .onClick(() => {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.REIMBURSEMENT_VOUCHER_PAGE,
              builder: wrapBuilder(ReimbursementVoucherPageBuilder),
              param: this.totalPrice
            })

          })
          .width('45%')
          .height(40)
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .borderRadius(24)
          .borderWidth(0.5)
          .borderColor('rgba(0, 0, 0, 0.10)')

          Row() {
            Text('再次预定')
              .fontSize(14)
              .fontColor('#333333')
              .fontWeight(500)
          }
          .onClick(() => {
            this.orderInfo.bookAgain()
          })
          .width('45%')
          .height(40)
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .borderRadius(24)
          .backgroundColor('#FFE431')
        }
        .height(92)
        .width('100%')
        .backgroundColor('#FFFFFF')
        .padding({ left: 16, right: 16 })
        .justifyContent(FlexAlign.SpaceBetween)
      } else if (this.vm.orderStatus === OrderStatus.CANCEL || this.vm.orderStatus === OrderStatus.REFUNDED) {
        Row() {
          Row() {
            Text('再次预定')
              .fontSize(14)
              .fontColor('#333333')
              .fontWeight(500)
          }
          .onClick(() => {
            this.orderInfo.bookAgain()
          })
          .height(40)
          .width('100%')
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .borderRadius(24)
          .backgroundColor('#FFE431')
        }
        .height(92)
        .width('100%')
        .backgroundColor('#FFFFFF')
        .alignItems(VerticalAlign.Top)
        .padding({ left: 16, right: 16, top: 12 })
        .justifyContent(FlexAlign.SpaceBetween)
      } else if (this.vm.orderStatus === OrderStatus.BOOKED) {
        Row() {
          Row() {
            Text('取消订单')
              .fontSize(14)
              .fontColor('#333333')
              .fontWeight(500)
          }
          .onClick(() => {
            promptAction.openCustomDialog({
              builder: () => {
                this.CustomDialog('确定取消订单？', () => {
                  this.vm.orderStatus = OrderStatus.REFUNDED
                  this.orderInfo.hotelApplyRefund()
                })
              },
              alignment: DialogAlignment.Center,
              width: '90%'
            })
              .then((id) => {
                this.vm.dialogId = id
              })
          })
          .height(40)
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .borderRadius(24)
          .backgroundColor('#FFFFFF')
          .borderWidth(0.5)
          .borderColor('rgba(0, 0, 0, 0.10)')
        }
        .height(92)
        .width('100%')
        .backgroundColor('#FFFFFF')
        .padding({ left: 16, right: 16, top: 12 })
        .alignItems(VerticalAlign.Top)
        .justifyContent(FlexAlign.SpaceBetween)
      }

    }
    .width('100%').height('100%')
  }
}

@Extend(Text)
function titleStyle() {
  .fontSize(12)
  .fontColor('rgba(0, 0, 0, 0.50)')
  .fontWeight(400)
  .lineHeight(14)
}

@Extend(Text)
function contentStyle() {
  .fontSize(12)
  .fontColor('#000000')
  .fontWeight(400)
  .lineHeight(14)
}

@Extend(Text)
function titleTextStyle() {
  .fontColor('#000000')
  .fontSize(14)
  .fontWeight(500)
}

@Extend(Text)
function titleStatusStyle() {
  .fontSize(20)
  .fontColor('#000000')
  .fontWeight(500)
  .lineHeight(24)
}

@Extend(Text)
function contentStatusStyle() {
  .fontSize(14)
  .fontColor('#000000')
  .lineHeight(16)
  .margin({ top: 9 })
}

@Extend(Row)
function rowStyle() {
  .width('100%')
  .justifyContent(FlexAlign.SpaceBetween)
  .margin({ bottom: 10 })
}



