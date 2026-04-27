@CustomDialog
export struct DelDialog {
  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }
  controller: CustomDialogController;

  build() {
    Column() {
      Text('删除')
        .width('100%')
        .textAlign(TextAlign.Center)
        .height(56)
        .halfLeading(true)
        .fontColor('#E6FFFFFF')
      Text('是否删除该音频，删除后将不能恢复')
        .width('100%')
        .textAlign(TextAlign.Center)
        .height(56)
        .halfLeading(true)
        .fontColor('#99FFFFFF')
      Row() {
        Text('取消')
          .width(144)
          .height(40)
          .fontSize(16)
          .textAlign(TextAlign.Center)
          .halfLeading(true)
          .borderRadius(40)
          .fontColor('#01FCEA')
          .border({ width: 1, color: '#01FCEA' })
          .margin({ right: 8 })
          .onClick(()=>{
            this.cancel()
          })

        Text('确定')
          .width(144)
          .height(40)
          .fontSize(16)
          .textAlign(TextAlign.Center)
          .halfLeading(true)
          .borderRadius(40)
          .fontColor('#000000')
          .backgroundColor('#01FCEA')
          .onClick(()=>{
            this.confirm()
          })

      }.width('100%').justifyContent(FlexAlign.Center)
      .margin({ top: 16 })
    }.width(328).height(192)
  }
}