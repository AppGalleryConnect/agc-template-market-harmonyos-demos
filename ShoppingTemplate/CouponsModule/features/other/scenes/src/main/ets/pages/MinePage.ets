import { ClickGridItem, ClickListItem, CommonConstants, RouterMap, RouterModule } from 'commonlib'
import { CommonHeader } from 'componentlib'

@ComponentV2
export struct MinePage {
  build() {
    Column() {
      CommonHeader({ title: '我的', transparent: true })
      this.topBuilder()
      this.middleBuilder()
      this.bottomBuilder()
    }
    .justifyContent(FlexAlign.Start)
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
  topBuilder() {
    Row() {
      Row({ space: 12 }) {
        Image($r('app.media.ic_avatar')).width(64).borderRadius('50%').clip(true)
        Row() {
          Column({ space: 10 }) {
            Text('华为用户').fontColor('rgba(0, 0, 0, 0.9)').fontSize($r('app.string.font_size_18'))
            Text() {
              ImageSpan($r('app.media.ic_phone')).height(16).margin({ right: $r('app.string.margin_2') })
              Span('135****0000').fontSize($r('app.string.font_size_12'))
            }.fontColor('rgba(0, 0, 0, 0.6)')
          }
          .alignItems(HorizontalAlign.Start)
        }.alignItems(VerticalAlign.Center).layoutWeight(1)
      }
      .layoutWeight(1).alignItems(VerticalAlign.Center).height(64)

      Button() {
        Text() {
          ImageSpan($r('app.media.ic_link')).height(16)
          Span(' 解除关联')
        }
        .fontColor('rgba(0, 0, 0, 0.9)').fontSize($r('app.string.font_size_14'))
      }
      .padding({
        left: 9,
        right: 9,
        top: 7,
        bottom: 7,
      })
      .backgroundColor('rgba(0, 0, 0, 0.05)')
    }
    .alignItems(VerticalAlign.Top)
    .commonStyle()
    .margin({ top: $r('app.string.margin_8'), bottom: $r('app.string.margin_12') })
  }

  @Builder
  middleBuilder() {
    Row() {
      this.gridItemBuilder({ icon: $r('app.media.ic_pay_pending'), title: '待支付' })
      this.gridItemBuilder({ icon: $r('app.media.ic_paid'), title: '已支付' })
      this.gridItemBuilder({ icon: $r('app.media.ic_all'), title: '全部' })
    }
    .commonStyle()
  }

  @Builder
  bottomBuilder() {
    Column() {
      Text('常用服务').titleStyle()
      List({ space: 8 }) {
        this.listItemBuilder({
          icon: $r('app.media.ic_coupons'), label: '优惠券', click: () => {
            RouterModule.push({ url: RouterMap.MY_COUPONS })
          },
        })
        this.listItemBuilder({ icon: $r('app.media.ic_location_1'), label: '地址管理' })
        this.listItemBuilder({ icon: $r('app.media.ic_call'), label: '客服中心' })
        this.listItemBuilder({ icon: $r('app.media.ic_setting'), label: '设置' })
      }
    }
    .layoutWeight(1)
  }

  @Builder
  gridItemBuilder(item: ClickGridItem) {
    Column({ space: 6 }) {
      Image(item.icon).width(30)
      Text(item.title).fontSize($r('app.string.font_size_12')).fontColor('rgba(0, 0, 0, 0.9)')
    }.onClick(() => {
      item.click && item.click()
    })
    .layoutWeight(1)
    .margin({ top: $r('app.string.margin_10'), bottom: $r('app.string.margin_10') })
  }

  @Builder
  listItemBuilder(item: ClickListItem) {
    ListItem() {
      Row() {
        Image(item.icon).width(24).margin({ right: $r('app.string.margin_12') })
        Text(item.label).flexGrow(1).fontColor('rgba(0, 0, 0, 0.9)').fontWeight(FontWeight.Medium)
        Image($r('app.media.ic_arrow_right')).width(7)
      }
      .commonStyle()
      .onClick(() => {
        item.click && item.click()
      })
    }
  }
}

@Extend(Row)
function commonStyle() {
  .width(CommonConstants.FULL_WIDTH)
  .borderRadius($r('app.string.border_radius_16'))
  .backgroundColor($r('app.color.sys_background_white'))
  .padding($r('app.string.padding_12'))
}

@Extend(Text)
function titleStyle() {
  .fontSize($r('app.string.font_size_20'))
  .fontColor('rgba(0, 0, 0, 0.9)')
  .fontWeight(FontWeight.Medium)
  .width(CommonConstants.FULL_WIDTH)
  .margin({ top: $r('app.string.padding_16'), bottom: $r('app.string.padding_10') })
}

@Builder
export function MinePageBuilder() {
  MinePage()
}

