import { FormatUtil } from 'commonlib';
import { AccountVM } from '../viewModels/AccountVM';

@Entry
@ComponentV2
struct FinancialAccount {
  vm: AccountVM = AccountVM.instance

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Column() {
            Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
              Text('银行卡')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
              Text(FormatUtil.encryptBankCardNo(this.vm.account.bankCardNo))
                .fontSize(14)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_secondary'))
            }
            .width('100%')
            .height(48)

            Divider().color($r('sys.color.comp_divider'))

            Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
              Text('登记机构')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
              Text(this.vm.account.bankName)
                .fontSize(14)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_secondary'))
            }
            .width('100%')
            .height(48)
          }
          .borderRadius(16)
          .backgroundColor(Color.White)
          .padding({ left: 12, right: 12 })
          .margin({ bottom: 16 })

          Column() {
            Text('说明：')
              .fontSize(12)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_secondary'))

            Text('1.“理财账号”是登记机构分配的与客户相关的号码，“理财交易账号”是银行分配的与登记机构交互数据的号码。')
              .fontSize(12)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_secondary'))

            Text('2.若存在尚未确认份额的认购/申购、分红等在途交易，无法提交理财账号关闭申请；如需提交关闭申请，请您对在途交易撤单或待分红入账后，再发起关闭理财账号申请。')
              .fontSize(12)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_secondary'))

            Text('3.仅可修改账单地址和邮编，如需修改其他账户信息，请前往 银行营业网点办理。')
              .fontSize(12)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_secondary'))
          }
          .alignItems(HorizontalAlign.Start)
        }
        .padding({ left: 16, right: 16 })
      }
      .scrollBar(BarState.Off)
    }
    .title('我的理财账号')
    .backgroundColor($r('sys.color.background_secondary'))
    .onShown(() => {
      this.vm.init()
    })
  }
}

@Builder
export function FinancialAccountBuilder() {
  FinancialAccount()
}