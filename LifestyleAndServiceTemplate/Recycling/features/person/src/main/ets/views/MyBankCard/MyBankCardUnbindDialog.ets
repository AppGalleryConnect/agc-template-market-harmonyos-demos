import { BankCard } from 'common'
import { MyBankCardPageVM } from '../../viewmodel/MyBankCardPageVM'
import { promptAction } from '@kit.ArkUI'

@ComponentV2
export struct MyBankCardUnbindDialog {
  @Param @Require vm: MyBankCardPageVM
  @Param deleteId: number = 0

  build() {
    Column() {
      // 标题
      Text('是否解绑该银行卡')
        .width('100%')
        .height(56)
        .fontSize(20)
        .fontColor('rgba(0, 0, 0, 0.90)')
        .textAlign(TextAlign.Center)
        .margin({ top: 16, bottom: 16 })

      Row() {
        Text('取消')
          .height(40)
          .fontSize(16)
          .fontColor('rgba(0, 0, 0, 0.6)')
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .margin({ right: 8 })
          .border({ color: 'rgba(0, 0, 0, 0.2)', width: 1, radius: 22 })
          .backgroundColor('rgba(255, 255, 255, 1)')
          .onClick(() => {
            promptAction.closeCustomDialog(this.vm.closeUnbindId)
          })

        Text('解绑')
          .height(40)
          .fontSize(16)
          .fontColor('rgba(255, 255, 255, 1)')
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .backgroundColor('rgba(255, 75, 75, 1)')
          .borderRadius(22)
          .onClick(() => {
            this.vm.bankCardTool.bankCards = this.vm.bankCardTool.bankCards.filter((item: BankCard, index: number) => {
              return index !== this.deleteId
            })
            promptAction.closeCustomDialog(this.vm.closeUnbindId)
            // 给出提示
            promptAction.showToast({
              message: '银行卡已解绑成功'
            })
          })
      }.width('100%').margin({ bottom: 24 })

    }.width('100%').padding({ left: 16, right: 16 }).backgroundColor('rgba(255, 255, 255, 1)')
  }
}