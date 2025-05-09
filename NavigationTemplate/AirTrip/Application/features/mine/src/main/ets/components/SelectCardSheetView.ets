import { BaseSelectedListItem } from 'common'

@ComponentV2
export struct SelectCardSheetView {
  @Param listData: BaseSelectedListItem[] = []
  @Param selectedItem: BaseSelectedListItem = this.listData[0]
  @Event selectCard: (data: BaseSelectedListItem) => void = (data: BaseSelectedListItem) => {}

  build() {
    List() {
      ForEach(this.listData, (item: BaseSelectedListItem, index: number) => {
        ListItem() {
          Row() {
            Text(item.label).fontWeight(400).fontColor(this.selectedItem.type === item.type ? $r('sys.color.ohos_id_color_emphasize') : '#191919')
            if (this.selectedItem.type === item.type) {
              Image($r('app.media.ic_selected')).width(16).height(16)
            }
          }
          .width('100%')
          .padding({ top: 14, bottom: 14 })
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(() => {
            this.selectCard && this.selectCard(item)
          })
        }
      })
    }
    .width('100%')
    .padding({left: 16, right: 16})
    .divider({ strokeWidth: 0.5, color: $r('sys.color.ohos_id_color_button_divider') })
  }
}