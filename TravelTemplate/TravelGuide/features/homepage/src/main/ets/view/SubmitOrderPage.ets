import { BarVM, RandomUtil, RouterMap, TValueType } from 'common';
import { phoneRouterControl } from 'oh_router';
import { AppStorageV2, CounterComponent, CounterType, PersistenceV2, promptAction } from '@kit.ArkUI';
import { SubmitOrderPageVM } from '../viewmodel/SubmitOrderPageVM';
import deviceInfo from '@ohos.deviceInfo';
import { HotelOrderDetailPageBuilder } from './HotelOrderDetailPage';
import { HotelOrderParam } from './HotelDetailsPage';
import {
  HotelDateModel,
  HotelModel,
  MyOrderList,
  MyPassengerList,
  OrderDetailInfo,
  OrderInfo,
  OrderStatus,
  OrderType,
  OrderUtil,
  PassengerInfo,
  TourOrderRouterParam,
  TravelAggregatedPaymentKey,
  TravelPeopleModel
} from 'common_travel_guide';
import { aggregatedPaymentService, CashierPicker, PaymentType } from 'aggregated_payment';
import { SelectTravelPeople } from '../components/SelectTravelPeople';
import { ChooseStatus } from '../viewmodel/HotelPageVM';

@Builder
export function SubmitOrderPageBuilder(params: TValueType) {
  SubmitOrderPage({
    pageParams: params as HotelOrderParam
  })
}

phoneRouterControl.registerPageBuilder('SubmitOrderPage', wrapBuilder(SubmitOrderPageBuilder))

@ComponentV2
export struct SubmitOrderPage {
  vm: SubmitOrderPageVM = new SubmitOrderPageVM()
  @Param pageParams: TValueType = null
  @Local hotelModel: HotelModel = Object()
  @Local hotelDate: HotelDateModel = Object()
  @Local chooseStatus: ChooseStatus = ChooseStatus.Domestic
  @Local totalPrice: number = 0
  @Local roomType: string = ''
  @Local passengerList: MyPassengerList = PersistenceV2.connect(MyPassengerList, () => new MyPassengerList())!
  @Local orderList: MyOrderList = AppStorageV2.connect(MyOrderList, () => new MyOrderList())!
  @Local personInfo: PassengerInfo[] = []
  @Local orderInfo: string = 'orderInfo'
  @Local travelPaymentKey: TravelAggregatedPaymentKey =
    AppStorageV2.connect(TravelAggregatedPaymentKey, 'travelAggregatedPaymentKey',
      () => new TravelAggregatedPaymentKey())!;
  private uiContext: UIContext = this.getUIContext();
  private navPathStack: NavPathStack = new NavPathStack();

  private showToast(msg: string): void {
    this.uiContext.getPromptAction().showToast({ message: msg });
  }

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
        aggregatedPaymentService.requestPaymentByAliPay({ orderInfo: this.orderInfo }, this.navPathStack);
        this.vm.payType = PaymentType.ALIPAY

      } else if (type === PaymentType.HUAWEI) {
        /**
         * 请求拉起华为支付
         */
        if (deviceInfo.marketName === 'emulator') {
          this.showToast('华为支付在模拟器场景下无任何响应');
          return;
        }
        aggregatedPaymentService.requestPaymentByHuawei(this.uiContext, { orderStr: '' });
        this.vm.payType = PaymentType.HUAWEI

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
        this.vm.payType = PaymentType.WECHAT
      }
    })
    .onWillDismiss((reason: DismissReason) => {
      if (reason === DismissReason.TOUCH_OUTSIDE) {
        this.showToast('已拦截点击其它区域进行关闭的交互方式');
      } else {
        this.cashierPicker.close();
      }
    });

  @Computed
  get priceCalculate() {
    return (this.totalPrice * this.vm.roomNum).toFixed(2)
  }

  totalDays() {
    let timeDiff: number = this.hotelDate.checkOutDate.getTime() - this.hotelDate.checkInDate.getTime();
    return Math.floor(timeDiff / (24 * 60 * 60 * 1000));
  }
  regPhone(phone:string){
    const phoneRegex = /^1(?:3[0-9]|4[014-9]|5[0-35-9]|6[2567]|7[0-8]|8[0-9]|9[0-35-9])\d{8}$/;
    return phoneRegex.test(phone)
  }

  aboutToAppear(): void {
    this.hotelModel = (this.pageParams as HotelOrderParam)?.hotelModel
    this.hotelDate = (this.pageParams as HotelOrderParam)?.hotelDate
    if ((this.pageParams as HotelOrderParam)?.hotelPageVM) {
      this.chooseStatus = (this.pageParams as HotelOrderParam)?.hotelPageVM.chooseStatus
    } else {
      this.chooseStatus = (this.pageParams as OrderDetailInfo)?.chooseStatus as ChooseStatus
    }
    if ((this.pageParams as HotelOrderParam)?.roomType) {
      this.roomType = (this.pageParams as HotelOrderParam)?.roomType
    } else {
      this.roomType = (this.pageParams as OrderDetailInfo)?.roomName as string
    }
    if (this.roomType === '豪华大床房') {
      this.totalPrice = this.hotelModel.price
    } else if (this.roomType === '舒适大床房') {
      this.totalPrice = this.hotelModel.bigRoomPrice
    } else {
      this.totalPrice = this.hotelModel.doubleBedRoomPrice
    }

    // 端侧支付回调仅可用于参考，以辅助提升支付结果判定效率，不建议完全依赖。如：实际支付成功，但支付回调没有触发。
    this.travelPaymentKey.value = aggregatedPaymentService.registerPaymentCallback(
      (type: PaymentType, isSuccess: boolean, key?: string) => {
        if (this.travelPaymentKey.value === key) {
          // 关闭支付弹框
          this.cashierPicker.close();
          // 模拟支付成功或失败
          const random = RandomUtil.getRandomIndex(2)
          if (random === 1) {
            // 已预定
            this.vm.orderStatus = OrderStatus.BOOKED
          } else {
            // 待付款
            this.vm.orderStatus = OrderStatus.PENDING
          }
          // 处理订单数据
          let id: string = Date.now().toString()
          const orderDetailInfo = new OrderDetailInfo()
          const pad2 = (n: number) => n.toString().padStart(2, '0');
          const orderTime = new Date();
          const createTime =
            `${pad2(orderTime.getHours())}:${pad2(orderTime.getMinutes())}:${pad2(orderTime.getSeconds())}`;
          const createDate =
            `${orderTime.getFullYear()}-${pad2(orderTime.getMonth() + 1)}-${pad2(orderTime.getDate())}`;

          orderDetailInfo.startTime = `${this.hotelDate.checkInDate.getFullYear()}-${this.hotelDate.checkInDate.getMonth() +
            1}-${this.hotelDate.checkInDate.getDate()}`
          orderDetailInfo.endTime = `${this.hotelDate.checkOutDate.getFullYear()}-${this.hotelDate.checkOutDate.getMonth() +
            1}-${this.hotelDate.checkOutDate.getDate()}`
          orderDetailInfo.hotelModel = this.hotelModel
          orderDetailInfo.hotelDate = this.hotelDate
          orderDetailInfo.chooseStatus = this.chooseStatus
          orderDetailInfo.phoneNum = this.vm.contactPhone as string
          orderDetailInfo.totalPrice = Number(this.priceCalculate)
          orderDetailInfo.id = id
          orderDetailInfo.roomName = this.roomType
          orderDetailInfo.roomDesc =
            this.chooseStatus !== ChooseStatus.Hourly ? `${this.vm.roomNum}间${this.totalDays()}晚` :
              `${this.vm.roomNum}间`
          orderDetailInfo.totalDays = this.totalDays()
          orderDetailInfo.createTime = createTime
          orderDetailInfo.createDate = createDate
          orderDetailInfo.hotelName = this.hotelModel.name
          orderDetailInfo.scenicPayType = OrderUtil.getPayTypeText(this.vm.payType);
          const orderInfo: OrderInfo = new OrderInfo(
            OrderType.HOTEL,
            this.totalPrice * this.vm.roomNum,
            this.hotelModel.name,
            this.vm.orderStatus,
            orderDetailInfo
          )
          orderInfo.passengerInfo = this.personInfo
          this.orderList.add(orderInfo)
          if (this.vm.orderStatus === OrderStatus.BOOKED) {
            orderInfo.hotelPayedData()
            orderDetailInfo.paymentDate = createDate
          }
          let param: TourOrderRouterParam = {
            orderInfo: orderInfo,
            isPulUpPay: false
          }
          phoneRouterControl.jumpPage({
            pageName: RouterMap.HOTEL_ORDER_DETAIL_PAGE,
            builder: wrapBuilder(HotelOrderDetailPageBuilder),
            param: param
          })
        }

      }
    );
  }

  build() {
    NavDestination() {
      this.render()
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  scrollerContent() {
    Scroll() {
      Column() {
        Column() {
          Row() {
            Text() {
              Span(this.hotelDate.getDateLabel(this.hotelDate.checkInDate))
              if (this.chooseStatus !== ChooseStatus.Hourly) {
                Span('  -  ')
                Span(this.hotelDate.getDateLabel(this.hotelDate.checkOutDate))
                Span('  |  ')
                Span(`${this.totalDays()}晚`)
              }
            }.fontColor('#333333').fontSize(14).fontWeight(500)
          }

          Row() {
            Text() {
              Span(this.roomType)
              Span('  |  ')
              Span(this.roomType === '舒适双床房' ? '双床' : '单床')
              Span('  |  ')
              Span('自助餐')
            }.fontColor('#333333').fontSize(14).fontWeight(500)
          }
        }
        .height(68)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .padding(12)
        .width('100%')
        .margin({ top: 8 })
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(HorizontalAlign.Start)

        Column() {
          Row() {
            Text('入住信息')
              .textTitle()
          }.height(46).justifyContent(FlexAlign.Start).width('100%')

          Row() {
            Row() {
              Text('入住信息')
                .width('23%')
                .textContent()
              Text(`${this.vm.roomNum}间（每间最多住2人）`)
                .textInfo()
            }

            CounterComponent({
              options: {
                type: CounterType.LIST,
                numberOptions: {
                  min: 0,
                  value: 1,
                  max: 10,
                  onChange: (value: number) => {
                    this.vm.roomNum = value
                  }
                }
              }
            }).layoutWeight(1)


          }.height(46).justifyContent(FlexAlign.SpaceBetween).width('100%')
        }
        .borderRadius(16)
        .backgroundColor('#FFFFFF')
        .margin({ top: 10, bottom: 10 })
        .padding({ left: 12, right: 12 })
        .width('100%')


        // 出行人信息
        SelectTravelPeople({
          routerPeopleList: this.vm.travelPersonList,
          routerPhone: this.vm.contactPhone,
          onConfirm: (list: TravelPeopleModel[], phone: string | number) => {
            this.vm.travelPersonList = list
            this.vm.selectPersonNum = list.length
            this.vm.contactPhone = phone
          }
        })


        Column() {
          Text('发票')
            .textTitle()
          Column() {
            Text('酒店开具发票').margin({ bottom: 4 })
              .textInfo()
            Text() {
              Span('离店时至酒店前台开具')
              Span('  |  ')
              Span('仅支持开具普票')
              Span('  |  ')
              Span('电子发票')
            }.fontColor('rgba(0, 0, 0, 0.40)').fontWeight(400).fontSize(12)
          }.alignItems(HorizontalAlign.Start)
        }
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.SpaceBetween)
        .height(101)
        .borderRadius(16)
        .backgroundColor('#FFFFFF')
        .margin({ top: 10 })
        .padding({
          left: 12,
          right: 12,
          top: 16,
          bottom: 18
        })
        .width('100%')

        Column() {
          Text('支付方式')
            .textTitle()
          Row() {
            Text('立即支付')
              .fontSize(14)
              .fontColor('#333333')
              .fontWeight(400)

            Image(this.vm.check ? $r('app.media.ic_checked') : $r('app.media.ic_unchecked'))
              .width(20)
              .height(20)
              .onClick(() => {
                this.vm.check = !this.vm.check
              })

          }
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ left: 12, right: 12 })
          .width('100%')
          .height(44)
          .backgroundColor('#F6F8F9')
          .borderRadius(8)
        }
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.SpaceBetween)
        .height(101)
        .borderRadius(16)
        .backgroundColor('#FFFFFF')
        .margin({ top: 10 })
        .padding({
          left: 12,
          right: 12,
          top: 16,
          bottom: 12
        })
        .width('100%')
      }.width('100%')
    }
    .layoutWeight(1)
    .align(Alignment.TopStart)
    .width('100%')
    .scrollBar(BarState.Off)
    .padding({ left: 16, right: 16, bottom: 20 })
  }

  @Builder
  bottomContent() {
    Row() {
      Row() {
        Text('在线付')
          .fontSize(12)
          .fontColor('rgba(0, 0, 0, 0.50)')
          .fontWeight(500)
        Text() {
          Span('¥')
          Span(this.priceCalculate)
        }
        .fontSize(14)
        .fontColor('#FF4A26')
        .fontWeight(500)
      }

      Text('提交订单')
        .onClick(() => {
          if(this.vm.contactPhone) {
            if(!this.regPhone(this.vm.contactPhone.toString())){
              this.showToast('手机号格式错误');
              return
            }
          }
          // 选择的出行人
          let passengerList: PassengerInfo[] = []
          this.vm.travelPersonList.forEach((personItem: TravelPeopleModel) => {
            let passengerInfo = new PassengerInfo()
            passengerInfo.name = personItem.name
            passengerInfo.phone = personItem.phone
            passengerInfo.idNumber = personItem.idNumber
            passengerList.push(passengerInfo)
          })
          this.personInfo = passengerList

          if (this.personInfo.length === 0) {
            promptAction.showToast({
              message: '请添加入住人',
            })
            return
          }

          if (this.vm.check) {
            this.cashierPicker
              .reset()// 内部状态重置
              .setAmount(this.totalPrice * 100)// 支付金额，单位：分
              .setTradeSummary(this.hotelModel.name)// 订单摘要 (可选，不填则不显示)
              .open();

          } else {
            promptAction.showToast({
              message: '请选择立即支付',
            })
          }
        })
        .fontSize(14)
        .fontColor('#333333')
        .fontWeight(500)
        .padding({
          left: 20,
          right: 20,
          top: 12,
          bottom: 12
        })
        .borderRadius(24)
        .backgroundColor('#FFE431')
    }
    .height(92)
    .width('100%')
    .backgroundColor('#FFFFFF')
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  render() {
    Column() {
      Stack({ alignContent: Alignment.Top }) {
        Image($r('app.media.ic_order_bg')).width('100%').objectFit(ImageFit.Contain)
        Column() {
          Row() {
            Image($r('app.media.ic_back_black')).width(40).height(40)
              .onClick(() => {
                phoneRouterControl.popPage()
              })
            Text(this.hotelModel.name)
              .fontSize(16)
              .fontColor('#333333')
              .fontWeight(500)
              .margin({ left: 8 })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }.width('100%').padding({ left: 16, right: 16 })

          this.scrollerContent()

          this.bottomContent()

        }.margin({ top: BarVM.instance.staBarH }).width('100%')
      }
    }.width('100%').height('100%').justifyContent(FlexAlign.SpaceBetween)
  }
}

@Extend(Text)
function textTitle() {
  .fontSize(16)
  .fontColor('#333333')
  .fontWeight(500)
}

@Extend(Text)
function textContent() {
  .fontSize(14)
  .fontColor('rgba(0, 0, 0, 0.50)')
  .fontWeight(400)
}

@Extend(Text)
function textInfo() {
  .fontSize(14)
  .fontColor('#333333')
  .fontWeight(500)
}