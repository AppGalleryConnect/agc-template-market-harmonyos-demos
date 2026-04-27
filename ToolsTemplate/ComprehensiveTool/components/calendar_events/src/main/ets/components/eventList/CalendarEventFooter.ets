@ComponentV2
export struct CalendarEventFooter {
  @Event onDelete: () => void = () => {
  }
  @Event onEdit: () => void = () => {
  }

  build() {
    Flex({ justifyContent: FlexAlign.SpaceAround }) {
      Column({ space: 5 }) {
        Image($r('app.media.delete_footer')).width(24).height(24)
        Text('删除')
          .fontSize(10)
      }
      .onClick(() => {
        this.onDelete()
      })

      Column({ space: 5 }) {
        Image($r('app.media.edit')).width(24).height(24)
        Text('编辑')
          .fontSize(10)
      }
      .onClick(() => {
        this.onEdit()
      })
    }
    .padding({ bottom: Number(AppStorage.get('bottomRectHeight')), top: 10 })
    .backgroundColor($r('sys.color.background_primary'))
  }
}