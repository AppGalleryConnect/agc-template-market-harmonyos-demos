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