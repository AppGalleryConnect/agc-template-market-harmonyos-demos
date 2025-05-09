import { FormatUtil } from 'commonlib'
import { RouterMap } from 'commonlib/src/main/ets/constants/CommonEnum'
import { CommonProductProfile } from 'componentlib'
import { PositionIntroduction } from '../components/PositionInfo/PositionIntroduction'
import { ProductReturns } from '../components/PositionInfo/PositionReturns'
import { RedemptionRule } from '../components/PositionInfo/RedemptionRule'
import { PurchaseBar } from '../components/PurchaseBar'
import { PositionInfoVM } from '../viewModels/PositionInfoVM'

@Builder
export function PositionInfoBuilder() {
  PositionInfo()
}

@ComponentV2
struct PositionInfo {
  vm: PositionInfoVM = PositionInfoVM.instance

  @Builder
  contentBuilder(label: string, value: string) {
    Flex() {
      Row() {
        Text(label)
          .fontSize(18)
          .fontColor(Color.Grey)
      }
      .flexShrink(0)
      .width(100)

      Row() {
        Text(value)
          .fontSize(18)
      }
      .flexGrow(1)
    }
    .margin({ bottom: 20 })
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          PositionIntroduction()
          Column() {
            Flex({ justifyContent: FlexAlign.SpaceAround }) {
              Row() {
                Image($r('app.media.ic_record'))
                  .width(24)
                  .height(24)
                  .margin({ right: 8 })
                Text('交易记录')
                  .fontSize(14)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_primary'))
                  .onClick(() => {
                    FormatUtil.jumpToNext(RouterMap.POSITION_RECORD, this.vm.positionInfo)
                  })
              }

              Row() {
                Image($r('app.media.ic_detail'))
                  .width(24)
                  .height(24)
                  .margin({ right: 8 })
                Text('收益明细')
                  .fontSize(14)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_primary'))
              }
              .onClick(() => {
                FormatUtil.jumpToNext(RouterMap.REVENUE_INFO, this.vm.positionInfo?.id)
              })
            }
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(16)
          .padding({ top: 16, bottom: 16 })
          .margin({ bottom: 12 })

          // 图表
          ProductReturns()

          Flex({ justifyContent: FlexAlign.SpaceBetween }) {
            Text('分红方式')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
            Text(this.vm.positionInfo?.dividendDistributionMethod)
              .fontSize(14)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_secondary'))
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(16)
          .padding({
            top: 16,
            bottom: 16,
            left: 12,
            right: 12
          })
          .margin({ bottom: 12 })

          // 赎回规则
          RedemptionRule()
          //  产品档案
          CommonProductProfile({
            productProfile: this.vm.productProfile, changeFactory: (router: RouterMap, param?: ESObject) => {
              FormatUtil.jumpToNext(router, param)
            }
          })
        }
        .padding({ left: 16, right: 16 })
      }
      .scrollBar(BarState.Off)
      .height('calc(100% - 56vp)')

      PurchaseBar()
    }
    .title('持仓详情')
    .backgroundColor($r('sys.color.background_secondary'))
    .onShown(() => {
      this.vm.init()
    })
    .onHidden(() => {
      this.vm.clear()
    })
  }
}