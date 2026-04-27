/**
 * @usage: 文件修改弹框组件：以弹框形式修改文件名称。
 * @layout: 图标 + 输入框内容区 + 底部按钮行，Column/Row 组合布局，宽度自适应。
 * @constraints: 弹框高度固定显示，底部按钮文案固定显示。
 * @isGen: false
 * @fileType: component
 * @domain: 云存储
 * @zhName: 重命名弹框
 * @subPage:
 * @component:
 */
@ComponentV2
export struct RenameDialog {
  @Require @Param name: string
  @Require @Param icon: ResourceStr
  @Local currentName: string = ''
  @Param changeCompletedAction: (success: boolean, text?: string) => void = () => {
  }

  aboutToAppear(): void {
    this.currentName = this.name
  }

  // 图标、输入框布局
  @Builder
  buildDialog() {
    Column() {
      Image(this.icon).width(72).height(72)

      TextInput({ text: this.currentName })
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_secondary'))
        .width('100%')
        .height(48)
        .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Medium })
        .placeholderColor($r('sys.color.font_secondary'))
        .backgroundColor('#F0F3F7')
        .lineHeight(16)
        .padding({ left: 10, right: 10 })
        .margin({ top: 24 })
        .borderRadius(8)
        .onChange((text: string) => {
          this.currentName = text
        })

      Row() {
        Text($r('app.string.operation_item_cancel'))
          .fontSize(16)
          .fontColor($r('sys.color.icon_tertiary'))
          .lineHeight(22)
          .height('100%')
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .onClick(() => {
            this.changeCompletedAction(false)
          })

        Text($r('app.string.operation_item_sure'))
          .textAlign(TextAlign.Center)
          .fontColor('#2FAFFF')
          .fontSize(16)
          .lineHeight(22)
          .fontWeight(FontWeight.Medium)
          .height('100%')
          .layoutWeight(1)
          .onClick(() => {
            this.changeCompletedAction(true, this.currentName)
          })
      }.width('100%').height(40).margin({ top: 24 })
    }
    .padding({
      top: 24,
      bottom: 16,
      left: 24,
      right: 24
    })
    .width('100%')
    .borderRadius(32)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(Color.White)
  }

  build() {
    Column() {
      this.buildDialog()
    }
    .width('100%')
    .height(248)
    .justifyContent(FlexAlign.Center)
  }
}
