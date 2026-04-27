@ComponentV2
export struct CalendarSheetHeader {
  @Param title: string = ''
  @BuilderParam calendarEventBuilder: () => void
  @Event onClose: () => void = () => {}
  @Event onConfirm: () => void = () => {}

  build() {
    Column() {
      Column() {
        Flex({ justifyContent: FlexAlign.SpaceBetween }) {
          Row({ space: 8 }) {
            Row() {
              Image($r('app.media.sheet_close')).width(18).height(18)
            }
            .justifyContent(FlexAlign.Center)
            .width(40)
            .height(40)
            .backgroundColor('#E6E8E9')
            .borderRadius('50%')
            .onClick(() => {
              this.onClose()
            })

            Text(this.title)
              .fontWeight(FontWeight.Bold)
              .fontSize(20)
          }

          Row() {
            Image($r('app.media.sheet_confirm')).width(40).height(40)
          }
          .onClick(() => {
            this.onConfirm()
          })
        }

        this.calendarEventBuilder()
      }.margin({ top: 16, left: 16, right: 16 })
    }
    .backgroundColor('#F1F3F5')
  }
}