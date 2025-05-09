import { FormatUtil } from 'commonlib'

@ComponentV2
export struct TransactionInfo {
  @Param productName: string = ''
  @Param amount: number = 0
  @Param date: string = ''
  @Param bankCardNo: string = ''

  build() {
    Column() {
      Text('交易信息')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .margin({ bottom: 16 })

      Flex() {
        Row() {
          Text('产品名称')
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_primary'))
        }
        .width('37.5%')
        .margin({ right: 8 })

        Row() {
          Text(this.productName)
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
        }
        .flexGrow(1)
        .justifyContent(FlexAlign.End)
      }
      .margin({ bottom: 12 })

      Flex({ alignItems: ItemAlign.Start }) {
        Row() {
          Text('购买金额')
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_primary'))
        }
        .width('37.5%')
        .margin({ right: 8 })

        Row() {
          Text(this.amount + '')
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
        }
        .flexGrow(1)
        .justifyContent(FlexAlign.End)
      }
      .margin({ bottom: 12 })

      Flex() {
        Row() {
          Text('购买日期')
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_primary'))
        }
        .width('37.5%')
        .margin({ right: 8 })

        Row() {
          Text(this.date)
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
        }
        .flexGrow(1)
        .justifyContent(FlexAlign.End)
      }
      .margin({ bottom: 12 })

      Flex() {
        Row() {
          Text('交易账号')
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_primary'))
        }
        .width('37.5%')
        .margin({ right: 8 })

        Row() {
          Text(FormatUtil.encryptBankCardNo(this.bankCardNo))
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
        }
        .flexGrow(1)
        .justifyContent(FlexAlign.End)
      }
      .margin({ bottom: 12 })
    }
    .alignItems(HorizontalAlign.Start)
    .padding({
      top: 24,
      bottom: 16,
      left: 12,
      right: 12
    })
    .backgroundColor(Color.White)
    .borderRadius(16)
  }
}