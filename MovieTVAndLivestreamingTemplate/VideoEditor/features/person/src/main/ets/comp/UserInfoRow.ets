/**
 * @usage: 用于展示用户信息行，包含左侧标题、副标题和右侧内容及箭头图标。
 * 关键参数：leftTitle左侧标题，subTitle副标题，rightContent右侧内容，rightOnClick点击回调，
 * isSwitch是否为开关模式，switchButton开关回调。
 * 包含if逻辑：当subTitle存在时显示副标题文本。
 * @layout: 横向排列。左侧为纵向排列的标题和副标题（左对齐），中间为空白占位，
 * 右侧为内容文本（右对齐）和箭头图标。
 * @constraints:
 * @zhName: 用户信息行
 * @fileType: component
 * @isGen: true
 */
@ComponentV2
export struct UserInfoRow {
  @Param leftTitle: string = ''
  @Param subTitle: string = ''
  @Param rightContent: string = ''
  @Event rightOnClick: () => void
  @Event switchButton: (isOn: boolean) => void
  @Param isSwitch: boolean = false

  aboutToAppear(): void {
  }

  build() {
    Row() {
      Column({ space: 2 }) {
        Text(this.leftTitle)
          .height(21)
        if (this.subTitle) {
          Text(this.subTitle).height(19).fontWeight(400).fontSize(14).fontColor($r('sys.color.font_secondary'))
        }
      }
      .alignItems(HorizontalAlign.Start)

      Blank()
      Text(this.rightContent)
        .height(19)
        .textAlign(TextAlign.End)
        .width(120)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_secondary'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Image($r('app.media.iconRight'))
        .size({ width: 24, height: 24 })
    }
    .onClick(() => {
      if (this.rightOnClick) {
        this.rightOnClick()
      }
    })
    .size({ width: '100%', height: 48 })
    .padding({ left: 12, right: 12 })
  }
}