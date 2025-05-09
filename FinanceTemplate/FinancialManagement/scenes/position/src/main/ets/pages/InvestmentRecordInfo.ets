import { FormatUtil } from 'commonlib'
import { InvestmentRecordInfoVM } from '../viewModels/InvestmentRecordInfoVM';
import { TransactionInfo } from '../components/TransactionInfo';

@Builder
export function InvestmentRecordInfoBuilder() {
  InvestmentRecordInfo()
}

@ComponentV2
struct InvestmentRecordInfo {
  vm: InvestmentRecordInfoVM = InvestmentRecordInfoVM.instance

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          if (this.vm.investmentInfo) {
            Column() {
              Text() {
                Span(this.vm.investmentInfo.productName)
                Span(`(${this.vm.investmentInfo.productNumber})`)
              }
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))

              Text(this.vm.investmentInfo.amount + '')
                .fontSize(24)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .margin({ top: 8, bottom: 8 })

              Text(FormatUtil.getStateTitle(this.vm.investmentRecordItem?.state ?? 1))
                .fontSize(14)
                .fontWeight(FontWeight.Regular)
                .fontColor('rgba(0,0,0,0.90)')
            }
            .width('100%')
            .padding({
              top: 24,
              bottom: 16,
              left: 12,
              right: 12
            })
            .margin({ bottom: 12 })
            .backgroundColor(Color.White)
            .borderRadius(16)

            TransactionInfo({
              productName: this.vm.investmentInfo.productName,
              amount: this.vm.investmentRecordItem?.money,
              date: this.vm.investmentRecordItem?.date,
              bankCardNo: this.vm.investmentInfo.bankCardNo
            })
          }

        }
        .padding({ left: 16, right: 16 })
      }
      .scrollBar(BarState.Off)
    }
    .title('记录详情')
    .backgroundColor($r('sys.color.background_secondary'))
    .onShown(() => {
      this.vm.init()
    })
  }
}