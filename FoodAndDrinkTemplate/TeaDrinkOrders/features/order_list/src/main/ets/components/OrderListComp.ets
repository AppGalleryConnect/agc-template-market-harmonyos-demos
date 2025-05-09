import {
  BaseResponse,
  CallTelSheetBuilder,
  CardManager,
  CommonUrl,
  Constants,
  EmptyComp,
  FormDataClass,
  GoodsOfOrder,
  HttpCode,
  HttpRequest,
  HttpRequestApi,
  IndexPageRouter,
  MyOrderInfo,
  OrderDetailRouter,
  OrderListTypeEnum,
  OrderStateEnum,
  orderStateMap,
  OrderTypeEnum,
  orderTypeMap,
  PayTypeSheetBuilder,
  RouterMap,
  StoreInfoModel,
  TabBarType,
  Utils,
} from 'common';
import { common } from '@kit.AbilityKit';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

@ComponentV2
export struct OrderListComp {
  @Consumer('pageStack') pageStack?: NavPathStack
  @Consumer('currentIndex') currentIndex?: TabBarType
  @Local storeModel: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  @Local orderList: Array<MyOrderInfo> = [];
  @Local orderListType: number = OrderListTypeEnum.TODAY_LIST
  @Local pageNum: number = 0
  @Local paySheetFlag: boolean = false
  @Local callTelSheet: boolean = false
  bindOrderInfo: MyOrderInfo = new MyOrderInfo()
  bindTel: string = ''
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  aboutToAppear(): void {
    this.getMyOrder()
  }

  @Monitor('currentIndex')
  indexChange(monitor: IMonitor) {
    if (monitor.value()?.now === TabBarType.ORDER_LIST) {
      this.getMyOrder()
    }
  }

  getMyOrder() {
    HttpRequest.getMyOrder(this.pageNum, this.orderListType).then((resp: Array<MyOrderInfo>) => {
      this.orderList = resp
    })
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.today_order_list'))
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.orderListType === OrderListTypeEnum.TODAY_LIST ? Color.White : $r('sys.color.mask_secondary'))
          .backgroundColor(this.orderListType === OrderListTypeEnum.TODAY_LIST ? '#486602' :
            '#00000000')
          .borderRadius(18)
          .textAlign(TextAlign.Center)
          .padding({
            top: 8,
            bottom: 8,
          })
          .layoutWeight(1)
          .onClick(() => {
            this.orderListType = OrderListTypeEnum.TODAY_LIST
            this.getMyOrder()
          })
        Text($r('app.string.history_order_list'))
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.orderListType === OrderListTypeEnum.HISTORY_LIST ? Color.White :
          $r('sys.color.mask_secondary'))
          .backgroundColor(this.orderListType === OrderListTypeEnum.HISTORY_LIST ? '#486602' : '#00000000')
          .borderRadius(18)
          .textAlign(TextAlign.Center)
          .padding({
            top: 8,
            bottom: 8,
          })
          .layoutWeight(1)
          .onClick(() => {
            this.orderListType = OrderListTypeEnum.HISTORY_LIST
            this.getMyOrder()
          })
      }
      .width(Constants.FULL_SIZE)
      .constraintSize({ maxWidth: Constants.FULL_SIZE })
      .margin({ top: 16, left: Constants.BORDER_WIDTH, right: Constants.BORDER_WIDTH })
      .padding(2)
      .backgroundColor('#0D000000')
      .borderRadius(20)

      List({ space: 12 }) {
        ForEach(this.orderList, (orderInfo: MyOrderInfo) => {
          ListItem() {
            this.orderCard(orderInfo)
          }
          .swipeAction([OrderStateEnum.COMPLETED, OrderStateEnum.CANCELED].includes(orderInfo.order?.state) ? {
            end: {
              builder: () => {
                this.deleteCard(orderInfo.order?.id)
              },
            },

          } : null)
        }, (orderInfo: MyOrderInfo) => `${orderInfo.order?.id}${orderInfo.order?.state}`)
      }
      .contentStartOffset(Constants.BORDER_WIDTH)
      .contentEndOffset(Constants.BORDER_WIDTH)
      .layoutWeight(1)
      .bindSheet($$this.paySheetFlag, PayTypeSheetBuilder(this.bindOrderInfo.order.money || 0, (flag: boolean) => {
        if (flag) {
          this.confirmOrder()
        }
        this.paySheetFlag = false
      }), {
        height: 290,
        blurStyle:
        BlurStyle.Thick,
        showClose:
        false,
      })
      .visibility(this.orderList.length ? Visibility.Visible : Visibility.None)

      Column() {
        EmptyComp()
      }
      .justifyContent(FlexAlign.Center)
      .layoutWeight(1)
      .visibility(this.orderList.length ? Visibility.None : Visibility.Visible)

    }
    .bindSheet($$this.callTelSheet, CallTelSheetBuilder(this.bindTel, () => {
      this.callTelSheet = false
    }), {
      height: 290,
      blurStyle: BlurStyle.Thick,
      showClose: false,
    })
    .height(Constants.FULL_SIZE)
    .width(Constants.FULL_SIZE)
  }

  @Builder
  orderCard(orderInfo: MyOrderInfo) {
    Column() {
      Row() {
        Row() {
          Text(orderTypeMap[orderInfo.order.orderType??OrderTypeEnum.PICK_SELF])
            .fontSize(10)
            .fontColor('#486602')
            .padding({ left: 7, right: 7 })
            .height(16)
            .borderRadius(4)
            .backgroundColor('#33A9D542')
          Text(orderInfo.order.storeName)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ left: 8 })
        }.constraintSize({ maxWidth: 220 })

        Row() {
          Text(orderStateMap[orderInfo.order.state])
            .fontSize(12)
            .fontColor([OrderStateEnum.TO_BE_PAID, OrderStateEnum.MAKING,
              OrderStateEnum.DELIVERING].includes(orderInfo.order.state) ? $r('sys.color.font_primary')
              : $r('app.color.mainColor'))
          Image($r('app.media.ic_right')).width(12).margin({ left: 8 })
        }
      }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween)

      Row() {
        List({ space: 6 }) {
          ForEach(orderInfo.good, (item: GoodsOfOrder) => {
            ListItem() {
              Row() {
                Image(`${CommonUrl.CLOUD_STORAGE_URL}${item.logo}`)
                  .width(60)
                  .height(60)
                  .borderRadius(8)
                if (orderInfo.good?.length === 1) {
                  Column() {
                    Text(item.name).fontSize(14).fontColor($r('sys.color.font_primary')).maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis });
                    Text(item.spec?.split(',').join(' | '))
                      .fontSize(10)
                      .fontColor($r('sys.color.mask_tertiary'))
                      .margin({ top: 4 })
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis });
                  }.height(60).margin({ left: 8 }).alignItems(HorizontalAlign.Start).layoutWeight(1)
                }
              }.layoutWeight(1)
            }
          }, (item: GoodsOfOrder) => JSON.stringify(item))
        }
        .listDirection(Axis.Horizontal)
        .scrollBar(BarState.Off)
        .layoutWeight(1)

        Column() {
          Text() {
            Span($r('app.string.currency_symbol')).fontSize(10)
            Span(orderInfo.order.money?.toString()).fontSize(16)
          }
          .fontWeight(500)
          .fontColor('#241400')

          Text($r('app.string.total_num', `${orderInfo.num}`))
            .fontColor($r('sys.color.mask_secondary'))
            .fontSize(10)
            .margin({ top: 4 })
        }
        .height(60)
        .margin({ left: 2 })
        .alignItems(HorizontalAlign.End)
        .backgroundColor(Color.White)
      }
      .width(Constants.FULL_SIZE)
      .margin({ top: 11 })

      // 订单时间
      Text(orderInfo.order.time).fontSize(10).fontColor($r('sys.color.font_secondary')).margin({ top: 6 })
      Row({ space: 8 }) {
        if (orderInfo.order.state === OrderStateEnum.CANCELED) {
          Text($r('app.string.one_more_order'))
            .fontSize(12)
            .fontColor('#486602')
            .border({ width: 1, color: '#BACD3C', radius: 14 })
            .backgroundColor('#33A9D542')
            .padding({
              left: 16,
              right: 16,
              top: 6,
              bottom: 6,
            })
            .onClick(() => {
              this.currentIndex = TabBarType.ORDER
            })
        } else if (orderInfo.order.state === OrderStateEnum.TO_BE_PAID) {
          Text($r('app.string.cancel_order'))
            .fontSize(12)
            .fontColor($r('sys.color.font_primary'))
            .border({ width: 1, color: $r('sys.color.mask_secondary'), radius: 14 })
            .padding({
              left: 16,
              right: 16,
              top: 6,
              bottom: 6,
            })
            .onClick(() => {
              HttpRequest.cancelOrder(orderInfo.order.id ?? '').then(() => {
                this.getMyOrder()
              })
            })
          Text($r('app.string.pay_now'))
            .fontSize(12)
            .fontColor('#486602')
            .border({ width: 1, color: '#BACD3C', radius: 14 })
            .backgroundColor('#33A9D542')
            .padding({
              left: 16,
              right: 16,
              top: 6,
              bottom: 6,
            })
            .onClick(() => {
              this.bindOrderInfo = orderInfo
              this.paySheetFlag = true
            })
        } else if ([OrderStateEnum.MAKING, OrderStateEnum.DELIVERING,
          OrderStateEnum.COMPLETED].includes(orderInfo.order.state!)) {
          Text($r('app.string.contact_us'))
            .fontSize(12)
            .fontColor($r('sys.color.font_primary'))
            .border({ width: 1, color: $r('sys.color.mask_secondary'), radius: 14 })
            .padding({
              left: 16,
              right: 16,
              top: 6,
              bottom: 6,
            })
            .onClick(() => {
              this.bindTel = orderInfo.order.tel || ''
              this.callTelSheet = true
            })
          Text($r('app.string.one_more_order'))
            .fontSize(12)
            .fontColor('#486602')
            .border({ width: 1, color: '#BACD3C', radius: 14 })
            .backgroundColor('#33A9D542')
            .padding({
              left: 16,
              right: 16,
              top: 6,
              bottom: 6,
            })
            .onClick(() => {
              this.currentIndex = TabBarType.ORDER
            })
        }
      }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.End)
    }
    .width(Constants.FULL_SIZE)
    .constraintSize({ maxWidth: Constants.FULL_SIZE })
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(8)
    .padding(12)
    .margin({
      left: 16,
      right: 16,
    })
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      this.pageStack?.pushPathByName(RouterMap.ORDER_DETAIL_PAGE, { orderId: orderInfo.order.id } as OrderDetailRouter,
        (popInfo: PopInfo) => {
          let result = popInfo.result as IndexPageRouter
          this.currentIndex = result.index ?? TabBarType.ORDER;
        })
    })
  }

  @Builder
  deleteCard(orderId: string) {
    Column() {
      Image($r('app.media.ic_delete')).width(16)
      Text($r('app.string.delete'))
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.white'))
        .margin({ top: 8 })
    }
    .backgroundColor('#FF0000')
    .width(78)
    .height(Constants.FULL_SIZE)
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
    .margin({ right: Constants.BORDER_WIDTH })
    .onClick(() => {
      HttpRequestApi.deleteOrder(orderId).then((res) => {
        if (res.code === HttpCode.SUCCESS) {
          this.getMyOrder()
          promptAction.showToast({ message: $r('app.string.deleteSuccessfully') })
        } else {
          promptAction.showToast({ message: $r('app.string.deleteFailed') })
        }
      })
    })
  }

  confirmOrder() {
    // 拉华为支付
    HttpRequest.getPurchase(this.context).finally(() => {
      HttpRequestApi.getHuaweiPayInfo(this.bindOrderInfo.order.id ?? '').then((resp: BaseResponse) => {
        if (resp.code === HttpCode.SUCCESS) {
          promptAction.showToast({ message: $r('app.string.pay_success') })
          let dataClass = new FormDataClass()
          dataClass.storeName = this.storeModel.storeInfo.name || ''
          dataClass.storeType = this.storeModel.orderType
          dataClass.orderState = true
          dataClass.orderId = this.bindOrderInfo.order.id || ''
          dataClass.orderPickNum = this.bindOrderInfo.order.oid || ''
          dataClass.makingNum = this.storeModel.storeInfo.makingNum || 0
          dataClass.makingWaitMin = this.storeModel.storeInfo.makingWaitTime || 0
          dataClass.deliveryTime = this.bindOrderInfo.delivery.estimatedTime
          let distance = Utils.getDistance(this.bindOrderInfo.delivery.distance) || ''
          dataClass.distance = `${distance} ${this.bindOrderInfo.delivery.remainingTime}`
          CardManager.get().updateCard(dataClass)
          this.getMyOrder()
        } else {
          promptAction.showToast({ message: $r('app.string.pay_failed') })
        }
      }).catch((e: BusinessError) => {
        console.error(`getHuaweiPayInfo error: ${JSON.stringify(e)}.`);
        promptAction.showToast({ message: $r('app.string.pay_failed_msg', JSON.stringify(e)) })
      })
    })

  }
}