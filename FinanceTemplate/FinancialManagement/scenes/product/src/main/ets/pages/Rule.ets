import { CommonRuleLine } from 'componentlib';
import { CommonRow } from '../components/CommonRow';
import { CommonRowSecond } from '../components/productInfo/CommonRowSecond';
import { RuleVM } from '../viewModels/RuleVM';

@Builder
export function RuleBuilder() {
  Rule()
}

@ComponentV2
struct Rule {
  vm: RuleVM = RuleVM.instance
  @Local fontColor: ResourceStr = $r('sys.color.font_secondary')
  @Local selectedFontColor: string = '#E4480C'
  private controller: TabsController = new TabsController()

  aboutToAppear(): void {
    this.vm.init()
  }

  @Builder
  leftTwoBuilder(text: string) {
    Text(text)
      .fontSize(16)
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.font_primary'))
  }

  build() {
    NavDestination() {
      Column() {
        Tabs({ barPosition: BarPosition.Start, index: this.vm.currentIndex, controller: this.controller }) {
          TabContent() {
            Column() {
              Scroll() {
                Column() {
                  Column() {
                    Row() {
                      Text('购买规则')
                        .fontSize(18)
                        .fontWeight(FontWeight.Bold)
                        .fontColor($r('sys.color.font_primary'))
                    }
                    .width('100%')
                    .margin({ bottom: 16 })

                    CommonRow({ text: '起点金额', value: this.vm.buyRule?.minimumPurchaseAmount + '元' })

                    CommonRow({ text: '递增金额', value: this.vm.buyRule?.pricePerShare + '元' })

                    CommonRow({ text: '最低持有份额', value: this.vm.buyRule?.minimumHoldingShare + '份' })

                    CommonRow({ text: '产品成立日', value: this.vm.productInfo?.createdTime })
                  }
                  .padding({
                    top: 24,
                    bottom: 4,
                    left: 12,
                    right: 12
                  })
                  .backgroundColor($r('sys.color.background_primary'))
                  .borderRadius(16)
                  .margin({ bottom: 12 })

                  Column() {
                    Row() {
                      Text('购买流程')
                        .fontSize(18)
                        .fontWeight(FontWeight.Bold)
                        .fontColor($r('sys.color.font_primary'))
                    }
                    .width('100%')
                    .margin({ bottom: 16 })

                    CommonRuleLine({
                      isPurchase: true,
                      confirmationDate: this.vm.purchaseProcess?.redemptionDate,
                      redemptionDate: this.vm.purchaseProcess?.redemptionDate
                    })

                    Row() {
                      Row()
                        .width(4)
                        .height(4)
                        .backgroundColor($r('sys.color.icon_tertiary'))
                        .borderRadius('50%')
                        .margin({ left: 8, right: 4 })
                      Text(`17:00点前购买，${this.vm.purchaseProcess?.confirmationDate}可查看持仓并开始计算收益`)
                        .fontSize(10)
                        .fontWeight(FontWeight.Regular)
                        .fontColor($r('sys.color.font_secondary'))
                    }
                    .width('100%')
                    .height(32)
                    .backgroundColor($r('sys.color.comp_background_tertiary'))
                    .borderRadius(8)
                  }
                  .padding({
                    top: 24,
                    bottom: 16,
                    left: 12,
                    right: 12
                  })
                  .backgroundColor($r('sys.color.background_primary'))
                  .borderRadius(16)
                  .margin({ bottom: 12 })

                  CommonRowSecond({ text: '认购费率', value: this.vm.buyRule?.purchaseRate + '%' })

                  CommonRowSecond({ text: '申购费率', value: this.vm.buyRule?.subscriptionRate + '%' })

                  Column() {
                    Text('温馨提示： ')
                      .fontSize(12)
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_secondary'))

                    Text('1.认购/申购费率仅供参考，如遇费率调整，以实际收取为准；')
                      .fontSize(12)
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_secondary'))

                    Text('2.管理费、托管费、销售服务费详见产品说明书。')
                      .fontSize(12)
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_secondary'))
                  }
                  .width('100%')
                  .alignItems(HorizontalAlign.Start)
                }
              }
              .scrollBar(BarState.Off)
            }
            .width('100%')
            .height('100%')
          }
          .tabBar(this.tabBuilder(0, '购买规则'))

          TabContent() {
            Column() {
              Scroll() {
                Column() {
                  Column() {
                    Row() {
                      Text('赎回规则')
                        .fontSize(18)
                        .fontWeight(FontWeight.Bold)
                        .fontColor($r('sys.color.font_primary'))
                    }
                    .width('100%')
                    .margin({ bottom: 16 })

                    CommonRow({ text: '最小赎回份额', value: this.vm.redemptionRule?.minimumRedemptionShare + '元' })
                  }
                  .padding({
                    top: 24,
                    bottom: 4,
                    left: 12,
                    right: 12
                  })
                  .backgroundColor($r('sys.color.background_primary'))
                  .borderRadius(16)
                  .margin({ bottom: 12 })

                  Column() {
                    Row() {
                      Text('赎回流程')
                        .fontSize(18)
                        .fontWeight(FontWeight.Bold)
                        .fontColor($r('sys.color.font_primary'))
                    }
                    .width('100%')
                    .margin({ bottom: 16 })

                    CommonRuleLine({
                      isPurchase: false,
                      confirmationDate: this.vm.redemptionProcess?.confirmationDate,
                      redemptionDate: this.vm.redemptionProcess?.redemptionDate
                    })

                    Row() {
                      Row()
                        .width(4)
                        .height(4)
                        .backgroundColor($r('sys.color.icon_tertiary'))
                        .borderRadius('50%')
                        .margin({ left: 8, right: 4 })
                      Text(`17:00点前购买，${this.vm.redemptionProcess?.confirmationDate}可查看到账及收益`)
                        .fontSize(10)
                        .fontWeight(FontWeight.Regular)
                        .fontColor($r('sys.color.font_secondary'))
                    }
                    .width('100%')
                    .height(32)
                    .backgroundColor($r('sys.color.comp_background_tertiary'))
                    .borderRadius(8)
                  }
                  .padding({
                    top: 24,
                    bottom: 16,
                    left: 12,
                    right: 12
                  })
                  .backgroundColor($r('sys.color.background_primary'))
                  .borderRadius(16)
                  .margin({ bottom: 12 })

                  CommonRowSecond({ text: '赎回费率', value: this.vm.redemptionRule?.redemptionRate + '%' })

                  Column() {
                    Text('温馨提示： ')
                      .fontSize(12)
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_secondary'))
                    Text('赎回费率仅供参考，如遇费率调整，以实际收取为准；')
                      .fontSize(12)
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_secondary'))
                  }
                  .width('100%')
                  .alignItems(HorizontalAlign.Start)
                }
              }
              .scrollBar(BarState.Off)
            }
            .width('100%')
            .height('100%')
          }
          .tabBar(this.tabBuilder(1, '赎回规则'))
        }
        .vertical(false)
        .barMode(BarMode.Fixed)
        .barWidth('100%')
        .barHeight(56)
        .animationDuration(400)
        .onChange((index: number) => {
          this.vm.tabChange(index)
        })
        .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {
          if (index === targetIndex) {
            return
          }
          this.vm.selectedIndex = targetIndex
        })
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16 })
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .title('交易规则')
  }

  @Builder
  tabBuilder(index: number, name: string) {
    Column() {
      Column() {
        Text(name)
          .fontColor(this.vm.selectedIndex === index ? this.selectedFontColor : this.fontColor)
          .fontSize(14)
          .fontWeight(this.vm.selectedIndex === index ? FontWeight.Bold : FontWeight.Regular)
          .margin({ top: 17, bottom: 7 })
        Divider()
          .strokeWidth(2)
          .color('#E4480C')
          .opacity(this.vm.selectedIndex === index ? 1 : 0)
      }
      .width(56)
    }
    .width('100%')
  }
}