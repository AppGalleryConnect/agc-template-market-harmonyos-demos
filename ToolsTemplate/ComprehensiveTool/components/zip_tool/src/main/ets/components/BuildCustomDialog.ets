@CustomDialog
export struct BuildCustomDialog {
  fileName: string = ''
  controller?: CustomDialogController
  cancel: () => void = () => {
  }
  confirm: (fileName: string) => void = () => {
  }

  build() {
    Column() {
      Text('新建文件夹')
        .fontSize($r('sys.float.Subtitle_L'))
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 12 })
      TextInput({ text: $$this.fileName, placeholder: '请输入文件夹名称' })
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
          this.confirm(this.fileName)
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