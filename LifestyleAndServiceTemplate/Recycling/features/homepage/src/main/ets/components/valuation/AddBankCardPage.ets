import { BankCard, ValuationStoreAPI } from 'common'
import { phoneRouterControl, RouterPopInfo } from 'oh_router'

@ComponentV2
export struct AddBankCardPage {
  @Local cardNo: string = ''
  @Local name: string = ''

  build() {
    NavDestination() {
      Column() {
        Column({ space: 12 }) {
          TextInput({ placeholder: '持卡人姓名', text: this.name })
            .height(40)
            .backgroundColor('rgba(0,0,0,0.05)')
            .onChange((v: string) => {
              this.name = v
            })
            .borderRadius(8)
          TextInput({ placeholder: '银行卡卡号', text: this.cardNo })
            .onChange((v: string) => {
              this.cardNo = v
            })
            .borderRadius(8)
            .maxLength(22)
            .type(InputType.Number)
            .height(40)
            .backgroundColor('rgba(0,0,0,0.05)')
        }
        .padding({
          right: 12,
          top: 16,
          left: 12,
          bottom: 16
        })
        .width('92%')
        .borderRadius(12)
        .margin({ left: '4%', right: '4%', top: 12 })
        .backgroundColor(Color.White)

        Blank()

        Row() {
          Button('添加')
            .fontSize($r('sys.float.Body_L'))
            .backgroundColor('rgba(255,75,75,1)')
            .borderRadius(24)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
            .height(48)
            .width('90%')
            .onClick(() => {
              const name = this.name.trim()
              const raw = this.cardNo.trim()
              if (!name) {
                this.getUIContext().getPromptAction().showToast({ message: '持卡人姓名为必填' })
                return
              }
              const isZh = /^[\u4e00-\u9fa5·]{2,20}$/.test(name)
              const isEn = /^[A-Za-z][A-Za-z \.'-]{1,29}$/.test(name)
              if (!isZh && !isEn) {
                this.getUIContext().getPromptAction().showToast({ message: '持卡人姓名格式错误' })
                return
              }
              if (!raw) {
                this.getUIContext().getPromptAction().showToast({ message: '银行卡卡号为必填' })
                return
              }
              const digits = raw.replace(/\s+/g, '')
              if (digits.length < 16) {
                this.getUIContext().getPromptAction().showToast({ message: '银行卡卡号格式错误' })
                return
              }
              const newCard: BankCard = {
                bankIcon: $r('app.media.icon_china_bank'),
                bankName: '中国银行',
                cardNo: `${digits.slice(0, 2)}************${digits.slice(-4)}`,
                rotateColor: ['rgba(255, 75, 75, 1)', 'rgba(184, 28, 34, 1)']
              }
              ValuationStoreAPI.addBankCard(newCard)
              const popInfo: RouterPopInfo = {}
              phoneRouterControl.popPage(popInfo)
            })
        }
        .width('100%')
        .height(72)
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 28 })
      }
      .width('100%')
      .backgroundColor('rgba(242,243,245,1)')
      .height('100%')
    }
    .title('添加银行卡')
    .padding({ top: 44 })
    .hideToolBar(true)
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
  }
}


@Builder
export function AddBankCardPageBuilder() {
  AddBankCardPage()
}