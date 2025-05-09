import {
  BaseResponse,
  CardManager,
  Constants,
  FormDataClass,
  HttpCode,
  HttpRequest,
  HttpRequestApi,
  IndexPageRouter,
  MyOrderInfo,
  OrderStateEnum,
  OrderTypeEnum,
  PayTypeSheetBuilder,
  StoreInfoModel,
  TabBarType,
  Utils,
} from 'common/Index';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';

@Styles
function cardStyle() {
  .width(Constants.FULL_SIZE)
  .constraintSize({ maxWidth: Constants.FULL_SIZE })
  .backgroundColor($r('sys.color.comp_background_list_card'))
  .borderRadius(12)
  .padding(12)
  .margin({
    left: 16,
    right: 16,
  });
}

@ComponentV2
export struct OrderTypeComp {
  @Consumer('pageStack') pageStack?: NavPathStack
  @Consumer('currentIndex') currentIndex?: TabBarType
  @Local storeModel: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  @Param @Require orderDetail: MyOrderInfo
  @Param orderState: number = OrderStateEnum.TO_BE_PAID
  @Local timer: number = 0
  @Local countdownMin: number = 0
  @Local countdownSec: number = 0
  @Local paySheetFlag: boolean = false
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  @Event
  getOrderInfo: () => void = () => {
  }

  aboutToAppear(): void {
    if (this.orderState === OrderStateEnum.TO_BE_PAID) {
      this.openTimer()
    }
  }

  aboutToDisappear(): void {
    if (this.timer) {
      clearInterval(this.timer)
    }
  }

  confirmOrder() {
    // 拉华为支付
    HttpRequest.getPurchase(this.context).finally(() => {
      HttpRequestApi.getHuaweiPayInfo(this.orderDetail.order?.id ?? '').then((resp: BaseResponse) => {
        if (resp.code === HttpCode.SUCCESS) {
          promptAction.showToast({ message: $r('app.string.pay_success') })
          let dataClass = new FormDataClass()
          dataClass.storeName = this.storeModel.storeInfo.name || ''
          dataClass.storeType = this.storeModel.orderType
          dataClass.orderState = true
          dataClass.orderId = this.orderDetail.order.id || ''
          dataClass.orderPickNum = this.orderDetail.order.oid || ''
          dataClass.makingNum = this.storeModel.storeInfo.makingNum || 0
          dataClass.makingWaitMin = this.storeModel.storeInfo.makingWaitTime || 0
          dataClass.deliveryTime = this.orderDetail.delivery.estimatedTime
          let distance = Utils.getDistance(this.orderDetail.delivery.distance) || ''
          dataClass.distance = `${distance} ${this.orderDetail.delivery.remainingTime}`
          CardManager.get().updateCard(dataClass)
          this.getOrderInfo()
        } else {
          promptAction.showToast({ message: $r('app.string.pay_failed') })
        }
      }).catch((e: BusinessError) => {
        console.error(`getHuaweiPayInfo error: ${JSON.stringify(e)}.`);
        promptAction.showToast({ message: $r('app.string.pay_failed_msg', JSON.stringify(e)) })
      })
    })

  }

  openTimer() {
    if (this.timer) {
      clearInterval(this.timer)
    }
    let orderTime = new Date(this.orderDetail.order?.time!)
    orderTime.setMinutes(orderTime.getMinutes() + 30)
    let countdownSec = Math.floor((orderTime.getTime() - new Date().getTime()) / 1000)
    this.countdownSec = countdownSec >= 0 ? countdownSec : 0
    this.countdownMin = Math.floor(this.countdownSec / Constants.SECOND_TO_MIN)
    this.timer = setInterval(() => {
      if (this.countdownSec <= 0) {
        clearInterval(this.timer)
        HttpRequest.cancelOrder(this.orderDetail.order?.id ?? '')
        this.getOrderInfo()
        return
      }
      this.countdownSec--
      if (this.countdownSec > Constants.SECOND_TO_MIN) {
        this.countdownMin = Math.floor(this.countdownSec / Constants.SECOND_TO_MIN)
      } else {
        this.countdownMin = 0
      }
    }, Constants.DELAY_TIME_1000)
  }

  @Builder
  waitPayBuilder() {
    Column() {
      Text($r('app.string.to_be_paid'))
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
      Text() {
        Span($r('app.string.please')).fontColor($r('sys.color.mask_secondary'))
        if (this.countdownMin) {
          Span($r('app.string.minute_params', `${this.countdownMin}`)).fontColor('#FF0000')
        }
        Span($r('app.string.second_params', `${this.countdownSec % 60}`)).fontColor('#FF0000')
        Span($r('app.string.timeout_cancel')).fontColor($r('sys.color.mask_secondary'))
      }.fontSize(14).margin({ top: 8, bottom: 16 })

      Row({ space: 12 }) {
        Text($r('app.string.pay'))
          .fontSize(12)
          .fontColor(Color.White)
          .backgroundColor('#486602')
          .borderRadius(23)
          .padding({
            left: 16,
            right: 16,
            top: 4,
            bottom: 4,
          })
          .onClick(() => {
            this.paySheetFlag = true
          })
        Text($r('app.string.cancel'))
          .fontSize(12)
          .fontColor($r('sys.color.mask_secondary'))
          .lineHeight(16)
          .borderRadius(23)
          .borderWidth(1)
          .borderColor('#4D000000')
          .padding({
            left: 16,
            right: 16,
            top: 4,
            bottom: 4,
          })
          .onClick(() => {
            HttpRequest.cancelOrder(this.orderDetail.order?.id ?? '').then(() => {
              this.getOrderInfo()
            })
          })
      }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.Center)
    }
    .cardStyle()
    .width(Constants.FULL_SIZE)
    .bindSheet($$this.paySheetFlag, PayTypeSheetBuilder(this.orderDetail.order?.money || 0, (flag: boolean) => {
      if (flag) {
        this.confirmOrder()
      }
      this.paySheetFlag = false
    }), {
      height: 290,
      backgroundColor: '#E6FFFFFF',
      blurStyle: BlurStyle.Thick,
      showClose: false,
    });
  }

  @Builder
  makingBuilder(title: ResourceStr, isCompleted: boolean = false) {
    Column() {
      Text(title)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))

      if (this.orderDetail.order.orderType === OrderTypeEnum.TAKEAWAY_DELIVERY) {
        if (isCompleted) {
          Row({ space: 12 }) {
            Text($r('app.string.one_more_order'))
              .fontSize(12)
              .fontColor(Color.White)
              .backgroundColor('#486602')
              .borderRadius(23)
              .padding({
                left: 16,
                right: 16,
                top: 4,
                bottom: 4,
              })
              .onClick(() => {
                this.pageStack?.pop({index:TabBarType.ORDER} as IndexPageRouter)
              })
          }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.Center).margin({ top: 12 })
        }
        Row() {
          Text($r('app.string.order_id_prefix'))
            .fontSize(14)
            .fontColor($r('sys.color.black'))
          Text(this.orderDetail.order?.orderNum)
            .fontSize(14)
            .fontColor($r('sys.color.black'))
          Image($r('app.media.ic_copy')).width(16).margin({ left: 10 })
        }
        .borderRadius(12)
        .padding({ left: 12, right: 12 })
        .justifyContent(FlexAlign.Center)
        .margin({ top: 15 })
        .height(32)
        .backgroundColor('#0D000000')
        .onClick(()=>{
          Utils.copyString(this.orderDetail.order?.orderNum)
        })
      } else {
        Row() {
          Text(this.orderDetail.order?.oid)
            .fontSize(24)
            .fontColor($r('sys.color.black'))
            .height(30)
          Text($r('app.string.pick_order_id'))
            .fontSize(14)
            .fontColor($r('sys.color.white'))
            .backgroundImage($r('app.media.bg_pick_num'))
            .backgroundImageSize({ width: 82, height: 30 })
            .height(30)
            .padding({ left: 20, right: 20 })
            .margin({ left: 4 })
        }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.Center).height(30).margin({ top: 15 })
      }

    }
    .cardStyle()
    .width(Constants.FULL_SIZE)
  }

  @Builder
  deliveringBuilder() {
    Column() {
      Text($r('app.string.delivering_title'))
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))

      Row() {
        Text($r('app.string.estimated_delivery_pre'))
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
        Text(this.orderDetail.delivery.estimatedTime)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#486602')
        Text($r('app.string.estimated_delivery_post'))
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
      }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.Center).margin({ top: 15 })

      Row() {
        Text($r('app.string.order_id_prefix'))
          .fontSize(14)
          .fontColor($r('sys.color.black'))
        Text(this.orderDetail.order?.orderNum)
          .fontSize(14)
          .fontColor($r('sys.color.black'))
        Image($r('app.media.ic_copy')).width(16).margin({ left: 10 })
      }
      .justifyContent(FlexAlign.Center)
      .margin({ top: 15 })
      .height(32)
      .borderRadius(12)
      .padding({ left: 12, right: 12 })
      .backgroundColor('#0D000000')
      .onClick(()=>{
        Utils.copyString(this.orderDetail.order?.orderNum)
      })
    }
    .cardStyle()
    .width(Constants.FULL_SIZE)
  }

  @Builder
  canceledBuilder() {
    Column() {
      Text($r('app.string.canceled')).fontSize(20).fontWeight(500).fontColor($r('sys.color.font_primary'))

      Text($r('app.string.use_close_order'))
        .fontSize(10)
        .fontWeight(400)
        .fontColor($r('sys.color.mask_secondary'))
        .margin({ top: 15 })
    }.cardStyle()
    .width(Constants.FULL_SIZE)
    .backgroundColor($r('sys.color.comp_background_list_card'))
  }

  build() {
    Column() {
      if (this.orderState === OrderStateEnum.TO_BE_PAID) {
        this.waitPayBuilder()
      } else if (this.orderState === OrderStateEnum.MAKING) {
        this.makingBuilder($r('app.string.making'))
      } else if (this.orderState === OrderStateEnum.DELIVERING) {
        this.deliveringBuilder()
      } else if (this.orderState === OrderStateEnum.COMPLETED) {
        this.makingBuilder($r('app.string.order_completed'), true)
      } else if (this.orderState === OrderStateEnum.CANCELED) {
        this.canceledBuilder()
      }
    }.margin({ top: 12 })
  }
}