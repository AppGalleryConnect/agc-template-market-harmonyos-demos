@CustomDialog
export struct RenameCustomDialog {
  fileName: string = ''
  controller?: CustomDialogController
  cancel: () => void = () => {
  }
  confirm: (name: string) => void = () => {
  }

  build() {
    Column() {
      Text('重命名')
        .fontSize($r('sys.float.Subtitle_L'))
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 12 })
      TextInput({ text: $$this.fileName, placeholder: '请输入文件名称' })
        .backgroundColor('rgba(0, 0, 0, 0.1)')
        .margin({ bottom: 15 })
        .borderRadius(8)
      Row() {
        Row() {
          Text('取消')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_emphasize'))
            .fontWeight(FontWeight.Medium)
        }
        .width(120)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .margin({ right: 16 })
        .onClick(() => {
          this.cancel()
        })

        Row() {
          Text('确定')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_emphasize'))
            .fontWeight(FontWeight.Medium)
        }
        .width(120)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.confirm(this.fileName ?? '')
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .padding({
      left: 12,
      right: 12,
      top: 11,
      bottom: 8,
    })
  }
}