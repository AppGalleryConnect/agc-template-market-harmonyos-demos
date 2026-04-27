import { call } from '@kit.TelephonyKit';

@Builder
export function CustomerServiceDialogBuilder(title: string = '客服', phone: string = '000-****-0000',
  onCancel?: () => void,
  closeIcon?: ResourceStr,
  sheetHeight?: number) {
  CustomerServiceDialog({
    title,
    phone,
    onCancel: onCancel ?? (() => {
    }),
    closeIcon,
    sheetHeight: sheetHeight ?? 170
  })
}

@ComponentV2
export struct CustomerServiceDialog {
  @Param phone: string = '000-****-0000'
  @Param title: string = '客服'
  @Param onCancel: () => void = () => {
  }
  @Param closeIcon: ResourceStr = ''
  @Param sheetHeight: number = 170

  @Computed
  get checkPhoneNumber(): string {
    const phoneLength: number = this.phone.length
    if (phoneLength <= 4) {
      return this.phone
    }
    const startIndex: number = Math.floor((phoneLength - 4) / 2)
    return this.phone.slice(0, startIndex) + '∗∗∗∗' + this.phone.slice(startIndex + 4, phoneLength)
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.chevron_backward')).width(18).height(18).opacity(0)
        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('rgba(0,0,0,1)')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        if (this.closeIcon) {
          Image(this.closeIcon)
            .width(18)
            .height(18)
            .onClick(() => {
              this.onCancel && this.onCancel()
            })
        }
      }
      .width('92%')
      .margin({ top: 12, bottom: 12 })

      Row()
        .backgroundColor('rgba(0, 0, 0, 0.05)')
        .height(1)
        .width('100%')
      Text(this.checkPhoneNumber)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('rgba(0,0,0,0.95)')
        .margin({ top: 12, bottom: 16 })
        .onClick(() => {
          // 检查设备通话能力
          const isSupport = call.hasVoiceCapability();
          if (isSupport) {
            // 跳转拨号界面（支持 tel: 格式）
            try {
              call.makeCall(this.convertPhoneNumber(), (err) => {
              });
            } catch (error) {
            }
          }
        })

      Row()
        .backgroundColor('rgba(0, 0, 0, 0.05)')
        .height(6)
        .width('100%')

      Text('取消')
        .fontSize(16)
        .fontColor('rgba(0,0,0,0.6)')
        .textAlign(TextAlign.Center)
        .width('100%')
        .margin({ top: 4 })
        .height(64)
        .padding({ bottom: 20 })
        .onClick(() => {
          this.onCancel && this.onCancel()
        })
    }
    .width('100%')
    .height(this.sheetHeight)
  }

  // 转化电话号码格式
  convertPhoneNumber(): string {
    let phoneNumber: string = ''
    for (let i = 0; i < this.phone.length; i++) {
      if (this.phone[i] === '-') {
        phoneNumber += ''
        continue
      }
      phoneNumber += this.phone[i]
    }
    return `tel:${phoneNumber}`
  }
}
