import { CommonUtils, GroupOrderStatus, MyGroupInfo, RouterMap, RouterModule } from 'utils'

@Builder
export function BookGroupDetailBuilder() {
  BookGroupDetail()
}

@ComponentV2
export struct BookGroupDetail {
  @Local groupInfo: MyGroupInfo = new MyGroupInfo();

  aboutToAppear(): void {
    const paramList: Array<MyGroupInfo> = RouterModule.getNavParam({ url: RouterMap.MY_BOOK_GROUP_DETAIL });
    if (paramList.length) {
      this.groupInfo = paramList[paramList.length - 1];
    }
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column({ space: 10 }) {
            this.TitleInfo()
            this.GroupInfoCard()
            if (this.isAvailable) {
              this.QRCodeCard()
            }
            if (this.isUseUp) {
              this.UsageRecord()
            }
            this.OrderCard()

          }.alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .height('100%')
        .align(Alignment.Top)
        .padding(10)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
    }
    .title('订单详情', { backgroundColor: Color.White })
    .backgroundColor($r('app.color.common_page_bg'))
  }

  @Computed
  get isAvailable() {
    return this.groupInfo.status === GroupOrderStatus.AVAILABLE;
  }

  @Computed
  get isUseUp() {
    return this.groupInfo.status === GroupOrderStatus.USE_UP;
  }

  @Computed
  get isRefund() {
    return this.groupInfo.status === GroupOrderStatus.REFUND;
  }

  @Computed
  get getTitle() {
    if (this.isRefund) {
      return '已退款';
    }
    if (this.isUseUp) {
      return '已使用';
    }
    return '待使用';
  }

  @Computed
  get getTitleIcon() {
    if (this.isRefund) {
      return $r('app.media.ic_refund');
    }
    if (this.isUseUp) {
      return $r('app.media.ic_group_finish');
    }
    return $r('app.media.ic_clock');
  }

  @Builder
  TitleInfo() {
    Row({ space: 10 }) {
      Image(this.getTitleIcon)
        .width(20).height(20)
      Text(this.getTitle).fontSize(16).fontWeight(500)
    }
    .padding({ top: 12, bottom: 12 })
  }

  @Builder
  GroupInfoCard() {
    Column() {
      // 上半部分
      Row() {
        Text(this.groupInfo.title)
          .fontSize(16)
          .fontWeight(500)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
        Blank()
        Text('￥' + CommonUtils.handleCash(this.groupInfo.vipPrice))
          .fontSize(12)
          .fontWeight(500)
          .fontColor('#E84026')
          .margin({ left: 53 })
      }
      .padding(10)
      .width('100%')
      .backgroundColor(Color.White)
      .borderWidth({ bottom: 0.5 })
      .borderColor($r('app.color.grey_20'))
      .borderRadius({
        topLeft: 8,
        topRight: 8,
      })

      // 下半部分
      Column({ space: 10 }) {
        Text('套餐内容').fontSize(14).fontWeight(500)
        Row({ space: 30 }) {
          Text('适用部位').fontSize(12)
          Text(this.groupInfo.groupContent.location).fontSize(12)
        }.width('100%').alignItems(VerticalAlign.Top)

        Row({ space: 30 }) {
          Text('包含项目').fontSize(12)
          Text(this.groupInfo.groupContent.including).fontSize(12).layoutWeight(1).textAlign(TextAlign.Start)
        }.width('100%').alignItems(VerticalAlign.Top)

        Row({ space: 30 }) {
          Text('附赠项目').fontSize(12)
          Text(this.groupInfo.groupContent.present).fontSize(12)
        }.width('100%').alignItems(VerticalAlign.Top)
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .padding(10)
      .backgroundColor(Color.White)
      .borderRadius({ bottomLeft: 8, bottomRight: 8 })
    }

  }

  @Builder
  QRCodeCard() {
    Column() {
      Text('团购码').fontSize(16).fontWeight(500)
      QRCode(this.groupInfo.groupSerialNo).width(150).height(150)
        .margin({ top: 10, bottom: 16 })
      Text(this.groupInfo.groupSerialNo).fontSize(16)
    }
    .width('100%')
    .padding({ top: 14, bottom: 24 })
    .borderRadius(8)
    .backgroundColor(Color.White)
  }

  @Builder
  UsageRecord() {
    Column({ space: 10 }) {
      Text('使用记录').fontWeight(500)
      Column({ space: 10 }) {
        Row() {
          Text('使用时间：').fontSize(12).width(80)
          Text(CommonUtils.formatDateTime(this.groupInfo?.consumeTime)).fontSize(12)
        }

        Row() {
          Text('使用券码：').fontSize(12).width(80)
          Text(this.groupInfo.groupSerialNo).fontSize(12).decoration({ type: TextDecorationType.LineThrough })
        }
      }
      .alignItems(HorizontalAlign.Start)
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(10)
    .borderRadius(8)
    .backgroundColor(Color.White)
  }

  @Builder
  OrderCard() {
    Column({ space: 10 }) {
      Text('订单信息').fontWeight(500)
      Column({ space: 10 }) {
        Row() {
          Text('订单号').fontSize(12).width(80)
          Text(this.groupInfo.orderNo).fontSize(12)
        }

        Row() {
          Text('交易方式').fontSize(12).width(80)
          Text('华为支付').fontSize(12)
        }

        Row() {
          Text('手机号').fontSize(12).width(80)
          Text(this.groupInfo.contactPhone).fontSize(12)
        }

        Row() {
          Text('下单时间').fontSize(12).width(80)
          Text(CommonUtils.formatDateTime(this.groupInfo.orderTime)).fontSize(12)
        }

        Row() {
          Text('付款时间').fontSize(12).width(80)
          Text(CommonUtils.formatDateTime(this.groupInfo.payTime)).fontSize(12)
        }

        if (this.isRefund && this.groupInfo.refundTime) {
          Row() {
            Text('退款时间').fontSize(12).width(80)
            Text(CommonUtils.formatDateTime(this.groupInfo.refundTime)).fontSize(12)
          }
        }
      }
      .alignItems(HorizontalAlign.Start)

    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(10)
    .borderRadius(8)
    .backgroundColor(Color.White)
  }
}
