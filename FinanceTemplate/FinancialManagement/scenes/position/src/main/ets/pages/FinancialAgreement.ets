import { FormatUtil, RouterMap } from 'commonlib'
import { OtherVM } from '../viewModels/OtherVM'

@Builder
export function FinancialAgreementBuilder() {
  FinancialAgreement()
}

@Entry
@ComponentV2
struct FinancialAgreement {
  vm: OtherVM = OtherVM.instance

  build() {
    NavDestination() {
      Column() {
        Column() {
          Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
            Text('协议1')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
            Image($r('app.media.icc_arrow_right'))
              .width(7)
              .height(14)
          }
          .width('100%')
          .height(48)
          .onClick(() => {
            FormatUtil.jumpToNext(RouterMap.PRIVACY, '协议1')
          })

          Divider().color($r('sys.color.comp_divider'))

          Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
            Text('协议2')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
            Image($r('app.media.icc_arrow_right'))
              .width(7)
              .height(14)
          }
          .width('100%')
          .height(48)
          .onClick(() => {
            FormatUtil.jumpToNext(RouterMap.PRIVACY, '协议2')
          })
        }
        .borderRadius(16)
        .backgroundColor(Color.White)
        .padding({ left: 12, right: 12 })
        .margin({ bottom: 16 })
      }
      .padding({ left: 16, right: 16 })
    }
    .title('我的理财协议')
    .backgroundColor($r('sys.color.background_secondary'))
  }
}