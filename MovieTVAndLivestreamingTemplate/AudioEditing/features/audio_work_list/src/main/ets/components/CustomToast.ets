/**
 * 自定义Toast组件
 */
@ComponentV2
export struct CustomToast {
  @Param message: string = ''
  @Param visible: boolean = false

  build() {
    if (this.visible) {
      Text(this.message)
        .fontSize(14)
        .fontColor('#FFFFFFFF')
        .backgroundColor('#202E3E')
        .height(36)
        .borderRadius(18)
        .padding({ left: 16, right: 16 })
        .textAlign(TextAlign.Center)
    }
  }
}
