import { BankCard, ValuationStoreAPI } from 'common'
import { phoneRouterControl } from 'oh_router'

@Builder
export function AddBankCardPageBuilder() {
  AddBankCardPage()
}

@ComponentV2
export struct AddBankCardPage {
  @Local name: string = ''
  @Local cardNo: string = ''

  build() {
    NavDestination() {
      Column() {
        Column({ space: 12 }) {
          TextInput({ placeholder: '持卡人姓名', text: this.name })
            .onChange((v: string) => {
              this.name = v
            })
            .height(40)
            .borderRadius(8)
            .backgroundColor('rgba(0,0,0,0.05)')
          TextInput({ placeholder: '银行卡卡号', text: this.cardNo })
            .onChange((v: string) => {
              this.cardNo = v
            })
            .maxLength(22)
            .type(InputType.Number)
            .height(40)
            .borderRadius(8)
            .backgroundColor('rgba(0,0,0,0.05)')
        }
        .width('92%')
        .padding({
          left: 12,
          right: 12,
          top: 16,
          bottom: 16
        })
        .borderRadius(12)
        .backgroundColor(Color.White)
        .margin({ left: '4%', right: '4%', top: 12 })

        Blank()

        Row() {
          Button('添加')
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundColor('rgba(255,75,75,1)')
            .borderRadius(24)
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
              if (digits.length < 16 ) {
                this.getUIContext().getPromptAction().showToast({ message: '银行卡卡号格式错误' })
                return
              }
              const newCard: BankCard = {
                bankIcon: $r('app.media.icon_china_bank'),
                bankName: '中国银行',
                cardNo: `${this.cardNo.slice(0, 2)}************${this.cardNo.slice(-4)}`,
                rotateColor: ['rgba(255, 75, 75, 1)', 'rgba(184, 28, 34, 1)']
              }
              ValuationStoreAPI.addBankCard(newCard)
              phoneRouterControl.popPage()
            })
        }
        .width('100%')
        .height(72)
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('rgba(242,243,245,1)')
    }
    .title('添加银行卡')
    .hideToolBar(true)
    .padding({ top: 44 })
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
  }
}