import { RouterMap, routerStack } from 'lib_foundation'
import { UserPointRedemptionSku } from 'lib_network'
import { NavTitleBar } from 'lib_widget'
import { CheckInCard } from '../components/CheckInCard'
import { PointsMallVM } from '../viewmodels/PointsMallVM'

@Builder
export function buildPointsMallPage() {
  PointsMallPage()
}

@ComponentV2
struct PointsMallPage {
  vm: PointsMallVM = new PointsMallVM()

  build() {
    NavDestination() {
      NavTitleBar({
        title: '积分商城',
      })
      Scroll() {
        Column({ space: 12 }) {
          this.buildMemberHeader()

          CheckInCard({
            isCheckedToday: this.vm.isCheckedToday,
            checkedDays: this.vm.userPoints?.checkedDays ?? 0,
            handleCheckIn: () => {
              this.vm.handleCheckIn()
            },
          })

          this.buildProductList()
        }
      }
      .padding({
        left: $r('app.float.space_l'),
        right: $r('app.float.space_l'),
      })
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
    .linearGradient({
      colors: [['#33e64566', 0], [$r('app.color.background_color_grey'), 0.3]],
    })
    .onReady(() => {
      this.vm.getUserPoints()
      this.vm.getProductList()
    })
  }

  @Builder
  buildMemberHeader() {
    Column({ space: 8 }) {
      Row() {
        Row() {
          Image($r('app.media.ic_member_point'))
            .width(16)
            .height(16)
            .margin({ right: $r('app.float.space_xs') })

          Text() {
            Span('积分余额 ')
            Span(`${this.vm.userPoints?.totalPoints ?? 0}`).fontSize($r('app.float.font_size_24'))
          }
          .fontWeight(FontWeight.Medium)
          .margin({ right: $r('app.float.space_s') })

          Image($r('app.media.ic_arrow_right'))
            .width(16)
            .height(16)
        }
        .onClick(() => {
          routerStack.pushPath({ name: RouterMap.USER_POINTS_RECORD })
        })

        Blank()

        Button('积分兑换记录')
          .controlSize(ControlSize.SMALL)
          .backgroundColor($r('app.color.theme_color'))
          .fontColor($r('sys.color.font_on_primary'))
          .fontSize($r('sys.float.Body_S'))
          .onClick(() => {
            routerStack.pushPath({ name: RouterMap.USER_REDEMPTION_LIST })
          })
      }
      .width($r('app.string.size_percent_full'))
      .alignItems(VerticalAlign.Center)

      Text(this.vm.isCheckedToday ? '今日积分已领取，坚持领取积分可兑换更多好物' :
        '今天还没有签到，快点击签到领取积分吧~')
        .fontSize($r('app.float.font_size_12'))
        .fontColor($r('app.color.font_color_level1'))
    }
    .alignItems(HorizontalAlign.Start)
    .width($r('app.string.size_percent_full'))
  }

  @Builder
  buildProductList() {
    WaterFlow() {
      ForEach(this.vm.productList, (product: UserPointRedemptionSku) => {
        FlowItem() {
          Column() {
            Image(product.banner)
              .width($r('app.string.size_percent_full'))
              .aspectRatio(1)
            Column({ space: 8 }) {
              Text(product.title)
                .fontSize(14)
                .fontColor($r('app.color.font_color_level1'))
                .fontWeight(FontWeight.Medium)
                .width('100%')
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .height(40)
              Row() {
                Text() {
                  Span(product.price.toString())
                  Span('积分').fontSize($r('app.float.font_size_12'))
                }
                .fontColor($r('app.color.theme_color'))
                .fontWeight(FontWeight.Medium)

                Button(this.vm.isProductValid(product.price) ? '立即兑换' : '积分不足')
                  .controlSize(ControlSize.SMALL)
                  .backgroundColor($r('app.color.theme_color'))
                  .enabled(this.vm.isProductValid(product.price))
                  .onClick(() => {
                    routerStack.pushPath({
                      name: RouterMap.USER_REDEMPTION_SUBMIT,
                      param: product,
                      onPop: () => {
                        this.vm.getUserPoints()
                      },
                    })
                  })
              }
              .width($r('app.string.size_percent_full'))
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .padding($r('app.float.space_m'))
          }
          .backgroundColor($r('app.color.background_color_primary'))
          .borderRadius($r('app.float.border_radius_l'))
        }
      }, (product: UserPointRedemptionSku) => product.skuCode)
    }
    .columnsTemplate(this.vm.columnTemplate)
    .columnsGap(12)
    .rowsGap(12)
    .margin({ bottom: $r('app.float.space_xl') })
    .constraintSize({ maxWidth: 720 })
  }
}
