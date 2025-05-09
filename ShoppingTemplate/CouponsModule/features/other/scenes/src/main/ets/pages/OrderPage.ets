import { CommonConstants, OnPopParams, RouterMap, RouterModule } from 'commonlib';
import { CommonHeader } from 'componentlib';


@Preview
@ComponentV2
export struct OrderPage {
  @Local curIndex: number = 0;
  @Local couponId: string = '';
  @Local totalMoney: number = 0;
  @Local reduce: number = 0;
  @Local isExpress: boolean = true

  aboutToAppear(): void {
    // 预订单创建时统计,所花金额
    this.totalMoney = 1356
  }

  private toSelectCoupon() {
    RouterModule.push({
      url: RouterMap.SELECT_COUPONS,
      param: { totalMoney: this.totalMoney, selectId: this.couponId },
      onPop: (res) => {
        // 选择优惠券后接收结果并减免显示
        const params = res.result as OnPopParams;
        this.couponId = params.selectId;
        this.reduce = params.reduce;
      },
    })
  }

  build() {
    Column() {
      CommonHeader({ title: '订单', transparent: true })

      Column({ space: 14 }) {
        this.switchBuilder()
        Row() {
          Row() {
            Image($r('app.media.ic_location_2')).width(12)
          }
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('app.color.light_red'))
          .width(24)
          .height(24)
          .borderRadius('50%')
          .alignSelf(ItemAlign.Start)
          .margin({ right: $r('app.string.margin_4') })

          Column({ space: 4 }) {
            Text('南京市雨花区雨花客厅1幢12A').commonTextStyle1()
            Text('索* 130****0000').fontSize($r('app.string.font_size_12')).fontColor('rgba(0, 0, 0, 0.6)')
          }.alignItems(HorizontalAlign.Start).layoutWeight(1)

          Image($r('app.media.ic_arrow_right')).width(7)
        }.justifyContent(FlexAlign.Center)
      }
      .commonStyle().margin({ top: $r('app.string.margin_8'), bottom: $r('app.string.margin_12') })

      Column({ space: 26 }) {
        Row() {
          Image($r('app.media.ic_goods_1')).width(86).height(86).borderRadius($r('app.string.border_radius_8'))
          Column({ space: 4 }) {
            Text('90绒子含量+石墨烯...').commonTextStyle2()
            Text('规格：白色21;170/88A').commonTextStyle3()
            Text('数量：2').commonTextStyle3()
            Blank().layoutWeight(1)
            Text('运费险 | 7天无理由').commonTextStyle3()
          }
          .layoutWeight(1)
          .margin({ left: $r('app.string.margin_8'), bottom: $r('app.string.margin_2') })
          .alignItems(HorizontalAlign.Start)

          Column({ space: 8 }) {
            Text() {
              Span('¥').fontSize($r('app.string.font_size_12'))
              Span('1356').fontSize($r('app.string.font_size_18'))
            }.fontColor($r('app.color.remind_orange')).fontWeight(FontWeight.Medium)

            Text('¥ 1388.8')
              .fontColor('rgba(0, 0, 0, 0.4)')
              .fontSize($r('app.string.font_size_10'))
              .decoration({ type: TextDecorationType.LineThrough })
          }
        }.height(86).alignItems(VerticalAlign.Top)

        Row() {
          Text('配送服务').commonTextStyle2()
          Text(this.isExpress ? '快递发货' : '到店自提').commonTextStyle1()
        }.justifyContent(FlexAlign.SpaceBetween).width(CommonConstants.FULL_WIDTH)

        Row() {
          Text('优惠券').commonTextStyle2()
          Row({ space: 7 }) {
            Text(!this.couponId ? '去选择' : `- ¥ ${this.reduce.toFixed(2)}`)
              .fontSize($r('app.string.font_size_14'))
              .fontColor(this.couponId ? $r('app.color.remind_orange') : 'rgba(0, 0, 0, 0.4)')
            Image($r('app.media.ic_arrow_right')).width(7)
          }
          .onClick(() => {
            this.toSelectCoupon()
          })
        }.justifyContent(FlexAlign.SpaceBetween).width(CommonConstants.FULL_WIDTH)

        Row() {
          Text('订单总金额').commonTextStyle2()
          Text(`¥ ${(this.totalMoney - this.reduce).toFixed(2)}`)
            .fontWeight(FontWeight.Medium)
            .fontColor('rgba(0, 0, 0, 0.9)')
        }.justifyContent(FlexAlign.SpaceBetween).width(CommonConstants.FULL_WIDTH)

        Row() {
          Text('备注').commonTextStyle2()
          Row({ space: 7 }) {
            Text('选填，建议先与商家沟通后再填写').commonTextStyle3()
            Image($r('app.media.ic_arrow_right')).width(7)
          }
        }.justifyContent(FlexAlign.SpaceBetween).width(CommonConstants.FULL_WIDTH)
      }.commonStyle()
    }
    .width(CommonConstants.FULL_WIDTH)
    .height(CommonConstants.FULL_HEIGHT)
    .padding({ left: $r('app.string.padding_16'), right: $r('app.string.padding_16') })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .linearGradient({
      angle: 180,
      colors: [
        ['#FFD8DD', 0],
        ['#F1F3F5', 0.4],
      ],
    })
  }

  @Builder
  switchBuilder() {
    Stack() {
      Row()
        .width('50%')
        .backgroundColor($r('app.color.sys_background_white'))
        .borderRadius('50%')
        .height(40)
        .position({ left: this.isExpress ? 2 : undefined, right: this.isExpress ? undefined : 2, top: 2 })

      Row() {
        Text('快递发货').onClick(() => {
          animateTo({ duration: 300 }, () => {
            this.isExpress = true
          })
        }).switchTextStyle().fontColor(this.isExpress ? 'rgba(0, 0, 0, 0.9)' : 'rgba(0, 0, 0, 0.6)')
        Text('到店自提').onClick(() => {
          animateTo({ duration: 300 }, () => {
            this.isExpress = false
          })
        }).switchTextStyle().fontColor(!this.isExpress ? 'rgba(0, 0, 0, 0.9)' : 'rgba(0, 0, 0, 0.6)')
      }.justifyContent(FlexAlign.SpaceEvenly).width(CommonConstants.FULL_WIDTH)
    }
    .height(44)
    .width(CommonConstants.FULL_WIDTH)
    .backgroundColor('rgba(0, 0, 0, 0.05)')
    .borderRadius('50%')
  }
}

@Extend(Column)
function commonStyle() {
  .width(CommonConstants.FULL_WIDTH)
  .borderRadius($r('app.string.border_radius_16'))
  .backgroundColor($r('app.color.sys_background_white'))
  .padding({
    left: 12,
    right: 12,
    top: 16,
    bottom: 16,
  })
}

@Extend(Text)
function switchTextStyle() {
  .layoutWeight(1)
  .textAlign(TextAlign.Center)
  .height(CommonConstants.FULL_HEIGHT)
  .fontWeight(FontWeight.Medium)
  .fontSize($r('app.string.font_size_14'))
}

@Extend(Text)
function commonTextStyle1() {
  .fontWeight(FontWeight.Medium)
  .fontSize($r('app.string.font_size_14'))
  .fontColor('rgba(0, 0, 0, 0.9)')
}

@Extend(Text)
function commonTextStyle2() {
  .fontWeight(FontWeight.Medium)
  .fontSize($r('app.string.font_size_14'))
  .fontColor('rgba(0, 0, 0, 0.6)')
}

@Extend(Text)
function commonTextStyle3() {
  .fontSize($r('app.string.font_size_12'))
  .fontColor('rgba(0, 0, 0, 0.4)')
}

@Builder
export function OrderPageBuilder() {
  OrderPage()
}




