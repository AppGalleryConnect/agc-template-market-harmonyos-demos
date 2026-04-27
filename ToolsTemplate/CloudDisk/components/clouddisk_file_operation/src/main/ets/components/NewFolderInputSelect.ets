import { Constants } from 'common';

const newCreateFolder: string = '新建文件夹'

/**
 * @usage: 用于新建文件夹和文件重命名的输入场景。提供文件图标展示、名称输入和确认取消操作。
 * 关键数据结构：originName（原始名称字符串）、imageSrc（图标资源）、closeWithResult（回调函数，
 * 参数为输入的文本或undefined）。包含输入验证逻辑。
 * @layout: 垂直布局，居中对齐。顶部为文件图标（72x72，居中），中间为文本输入框（灰色背景，圆角），
 * 底部为按钮行（取消和确定按钮横向排列，均分宽度）。整体使用白色圆角背景。
 * @constraints: originName原始名称不能为空，imageSrc图标资源必须有效，
 * closeWithResult回调函数必须正确处理结果（传入undefined表示取消，传入字符串表示确认）
 * @isGen: true
 * @fileType: component
 * @domain: 云存储
 * @zhName: 文件夹输入对话框组件
 * @image: screenshot/screenshot03.jpg
 */
// 编辑文件夹,重命名弹框
@ComponentV2
export struct NewFolderInputSelect {
  @Param originName: string = newCreateFolder
  @Param imageSrc: ResourceStr = $r('app.media.file')
  @Param closeWithResult: (text?: string) => void = (_?: string) => {
  }
  @Local currentName: string = '';

  aboutToAppear(): void {
    this.currentName = this.originName
  }

  // 图标和输入框布局
  @Builder
  inputLayout() {
    Column() {
      Image(this.imageSrc).width(72).height(72)

      TextInput({ text: this.currentName })
        .width('100%')
        .height(48)
        .borderRadius(8)
        .backgroundColor('#F0F3F7')
        .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Medium })
        .placeholderColor($r('sys.color.font_secondary'))
        .lineHeight(16)
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .padding({ left: 10, right: 10 })
        .margin({ top: 24 })
        .onChange((text: string) => {
          this.currentName = text
        })

      Row() {
        Text($r('app.string.cancel'))
          .fontColor($r('sys.color.icon_tertiary'))
          .fontSize(16)
          .lineHeight(22)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .height('100%')
          .layoutWeight(1)
          .onClick(() => {
            this.closeWithResult()
          })

        Text($r('app.string.sure'))
          .fontColor('#2FAFFF')
          .fontSize(16)
          .lineHeight(22)
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .height('100%')
          .layoutWeight(1)
          .onClick(() => {
            this.closeWithResult(this.currentName)
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
      this.inputLayout()
    }
    .width(Constants.FULL_SIZE)
    .height(248)
    .justifyContent(FlexAlign.Center)
  }
}
