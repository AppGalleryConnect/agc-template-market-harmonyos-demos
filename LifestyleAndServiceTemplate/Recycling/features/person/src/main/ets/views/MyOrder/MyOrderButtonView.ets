@ComponentV2
export struct MyOrderButtonView {
  // 点击事件
  @Param clickEvent: () => void = () => {
  }
  // 点击事件2
  @Param clickEvent2: () => void = () => {
  }
  // 按钮类型
  @Param type: string = 'cancel'

  build() {
    if (this.type === 'cancel' || this.type === 'delete') {
      Row() {
        Text(this.type === 'cancel' ? '取消订单' : '删除订单')
          .font({ size: 16 })
          .fontColor('rgba(0, 0, 0, 0.6)')
          .border({ width: 1, color: 'rgba(0, 0, 0, 0.2)', radius: 20 })
          .textAlign(TextAlign.Center)
          .backgroundColor('rgba(245, 245, 245, 1)')
          .height(40)
          .onClick(() => {
            this.clickEvent()
          })
          .layoutWeight(1)
          .margin({
            left: 16,
            right: 16,
          })

      }
      .width('100%')
      .padding({
        top: 16,
        bottom: 28,
        left: 12,
        right: 12
      })
      .backgroundColor('rgba(245, 245, 245, 1)')
      .alignRules({
        bottom: { align: VerticalAlign.Bottom, anchor: '__container__' }
      })
    } else if (this.type === 'confirm') {
      Row() {
        Text('取消订单')
          .font({ size: 16 })
          .fontColor('rgba(0, 0, 0, 0.6)')
          .border({ width: 1, color: 'rgba(0, 0, 0, 0.2)', radius: 20 })
          .layoutWeight(1)
          .height(40)
          .textAlign(TextAlign.Center)
          .backgroundColor('rgba(245, 245, 245, 1)')
          .margin({
            right: 8
          })
          .onClick(() => {
            this.clickEvent()
          })

        Text('确认收款')
          .font({ size: 16 })
          .fontColor('rgba(255, 255, 255, 1)')
          .border({ radius: 20 })
          .layoutWeight(1)
          .backgroundColor('rgba(255, 75, 75, 1)')
          .textAlign(TextAlign.Center)
          .height(40)
          .onClick(() => {
            this.clickEvent2()
          })

      }
      .width('100%')
      .backgroundColor('rgba(245, 245, 245, 1)')
      .padding({
        top: 16,
        left: 12,
        bottom: 28,
        right: 12
      })
      .alignRules({
        bottom: { align: VerticalAlign.Bottom, anchor: '__container__' }
      })
    }

  }
}