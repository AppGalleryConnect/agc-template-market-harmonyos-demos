export interface RenameDialogParams {
  musicName: string
  index: number
  nameCancelHandle: () => void //删除点击事件
  nameSaveHandle: (index: number, musicName: string) => void //保存点击事件
}

@ComponentV2
export struct RenameDialog {
  @Param @Require params: RenameDialogParams
  @Local musicName: string = ''

  cancelHandle() {
    this.params.nameCancelHandle()
  }

  saveNameHandle() {
    this.params.nameSaveHandle(this.params.index, this.musicName)
  }

  aboutToAppear(): void {
    this.musicName = this.params.musicName
  }

  build() {
    Column() {
      Row() {
        Divider().height(1).width(16)
        Text('重命名').fontSize(20).fontColor('#E6FFFFFF')
        Image($r('app.media.ic_music_close')).width(16).height(16)
          .onClick(() => {
            this.cancelHandle()
          })
      }.margin({ top: 18 }).padding({ left: 5, right: 5 })
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')

      Row() {
        Text('音频名称').fontSize(16).fontColor('#E6FFFFFF')
      }.margin({ top: 24 }).width('100%')

      Stack({ alignContent: Alignment.End }) {
        TextInput({ text: this.musicName, placeholder: '请重新编辑音频名称' })
          .height(44)
          .width('100%')
          .backgroundColor('rgba(255,255,255,0.1)')
          .placeholderColor('#66ffffff')
          .fontColor(Color.White)
          .padding({ left: 16, right: 44 })
          .borderRadius(20)
          .onChange((value) => {
            this.musicName = value;
          })

        Image($r('app.media.ic_edit'))
          .width(20)
          .height(20)
          .fillColor(Color.White)
          .margin({ right: 20 })
      }
      .width('100%').margin({ top: 15 })

      Row() {
        Text('取消')
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .height(40)
          .halfLeading(true)
          .borderRadius(20)
          .fontSize(16)
          .fontColor('#01FCEA')
          .border({ width: 1, color: '#01FCEA' })
          .onClick(() => {
            this.cancelHandle()
          })
        Divider().height(1).width(16)
        Text('保存')
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .height(40)
          .halfLeading(true)
          .borderRadius(20)
          .fontSize(16)
          .fontColor('#000000')
          .backgroundColor('#01FCEA')
          .onClick(() => {
            this.saveNameHandle()
          })
      }.alignItems(VerticalAlign.Center)
      .margin({ top: 28 })
    }
    .width('100%')
    .height(246)
    .backgroundColor('#202E3E')
    .borderRadius(20)
    .padding({ left: 16, right: 16 })
  }
}