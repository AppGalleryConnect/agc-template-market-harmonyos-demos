import { Constants, copyString, GetMyOrderResp, OrderListEnum, OrderTable, OrderTypeEnum } from 'common/Index';

@Component
export struct PaymentDetailsComp {
  @StorageProp('storeType') storeType: number = 1
  @Prop overallFontSize: number = 12
  @Prop @Watch('orderDetailChange') orderDetail: GetMyOrderResp;
  @Prop tableInfo: OrderTable = new OrderTable()
  @State order: GetMyOrderResp = new GetMyOrderResp()

  aboutToAppear(): void {
    this.orderDetailChange()
  }

  orderDetailChange() {
    this.order = this.orderDetail
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.order_time')).fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_secondary'))
        Text(this.order.order?.time).fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_primary'))
      }
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ top: 12, bottom: 12 })

      // 订单号
      Row() {
        Text($r('app.string.order_id')).fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_secondary'))
        Row() {
          Text(this.order.order?.orderNum)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_primary'))
          Image($r('app.media.copy')).width(16).margin({ left: 4 })
            .onClick(() => {
              copyString(this.order.order?.orderNum || '')
            })
        }.justifyContent(FlexAlign.End).layoutWeight(1)
      }
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ top: 12, bottom: 12 })


      // 取餐方式
      Row() {
        Text($r('app.string.order_type')).fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_secondary'))
        Row() {
          Text(Number(this.order.order?.orderType) === OrderTypeEnum.STORE_DINING ?
          $r('app.string.store_dining') :
          $r('app.string.picking')).fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_primary'))
        }.justifyContent(FlexAlign.End).layoutWeight(1)
      }
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ top: 12, bottom: 12 })

      if (Number(this.order.order?.dnState) !== OrderListEnum.CANCELED) {
        Row() {
          Text($r('app.string.dinner_num_label'))
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
          Text(this.order.order?.tableware)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_primary'))
        }
        .width(Constants.FULL_SIZE)
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ top: 12, bottom: 12 })
      }

      Row() {
        Text($r('app.string.remark')).fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_secondary'))
        Text(this.order.order?.note || $r('app.string.none'))
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_primary'))
          .width(200)
          .maxLines(1)
          .textAlign(TextAlign.End)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ top: 12, bottom: 12 })
    }.width(Constants.FULL_SIZE)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .padding({
      left: 12,
      right: 12,
      top: 4,
      bottom: 4,
    })
  }
}