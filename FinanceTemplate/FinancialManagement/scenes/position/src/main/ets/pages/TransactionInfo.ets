import { TransactionInfoVM } from '../viewModels/TransactionInfoVM'
import { State } from 'network/src/main/ets/types/responseTypes/GetTransactionRecordInfoResp';
import { CommonTimeLine } from 'componentlib';
import { TransactionInfo } from '../components/TransactionInfo';
import { FormatUtil } from 'commonlib'

@Builder
export function TransactionRecordInfoBuilder() {
  TransactionRecordInfo()
}

@ComponentV2
struct TransactionRecordInfo {
  vm: TransactionInfoVM = TransactionInfoVM.instance

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          if (this.vm.transactionInfo) {
            Column() {
              if (this.vm.transactionInfo.state === State.IN_PROGRESS) {
                Image($r('app.media.ic_success_lined'))
                  .width(48)
                  .height(48)
                  .margin({ bottom: 12 })
                Text(FormatUtil.getTransactionStateTitle(this.vm.transactionInfo.type, this.vm.transactionInfo.state))
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))
                List() {
                  ForEach(this.vm.timeLineList, (item: object, index: number) => {
                    CommonTimeLine({ bean: item, index: index, totalSize: this.vm.totalSize })
                  }, (item: object[]) => JSON.stringify(item))
                }
                .margin({ top: 28 })
              } else {
                Text() {
                  Span(this.vm.transactionInfo.productName)
                  Span(`(${this.vm.transactionInfo.productNumber})`)
                }
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))

                Text(this.vm.transactionInfo.amount + '元')
                  .fontSize(24)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))
                  .margin({ top: 8, bottom: 8 })

                Text(FormatUtil.getTransactionStateTitle(this.vm.transactionInfo.type, this.vm.transactionInfo.state))
                  .fontSize(14)
                  .fontWeight(FontWeight.Regular)
                  .fontColor(FormatUtil.getStateFontColor(this.vm.transactionInfo.state))
                if (this.vm.transactionInfo.state === 3) {
                  Text(this.vm.transactionInfo.msg)
                    .fontSize(14)
                    .fontWeight(FontWeight.Regular)
                    .fontColor($r('sys.color.font_secondary'))
                    .margin({ top: 16 })
                }
              }
            }
            .width('100%')
            .padding({
              top: 24,
              bottom: 16,
              left: 12,
              right: 12
            })
            .margin({ top: 8, bottom: 12 })
            .backgroundColor(Color.White)
            .borderRadius(16)

            TransactionInfo({
              productName: this.vm.transactionInfo.productName,
              amount: this.vm.transactionInfo.amount,
              date: this.vm.transactionInfo.date,
              bankCardNo: this.vm.transactionInfo.bankCardNumber
            })
          }

        }
        .padding({ left: 16, right: 16 })
      }
      .scrollBar(BarState.Off)
    }
    .title('交易详情')
    .backgroundColor($r('sys.color.background_secondary'))
    .onShown(() => {
      this.vm.init()
    })
    .onHidden(() => {
      this.vm.clear()
    })
  }
}