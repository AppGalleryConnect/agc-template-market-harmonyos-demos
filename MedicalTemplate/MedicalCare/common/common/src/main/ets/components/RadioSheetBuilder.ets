interface RadioSheetBuilderParam {
  title: string, // sheet标题
  dataArray: string[], // 列表数据
  checkedItem: string, // 默认选中项
  dataChangeListener: (index: number, data: string) => void // 选中数据变化时的回调
  hasMultiHeight?: boolean
}

/**
 * 具有多个Radio列表的单选组件
 */
@Builder
export function RadioSheetBuilder(param: RadioSheetBuilderParam) {
  Column() {
    Text(param.title)
      .fontSize(20)
      .fontWeight(700)
      .padding({
        top: param.hasMultiHeight !== false ? 15 : 26,
        bottom: 15,
        left: 16,
        right: 16
      })
      .width('100%')

    List() {
      ForEach(param.dataArray ?? [], (item: string, index) => {
        ListItem() {
          Row() {
            Text(item)
              .fontSize(16)

            Blank()
              .layoutWeight(1)

            Radio({ group: 'radioGroup', value: item })
              .checked(item === param.checkedItem)
              .onClick(() => {
                param.dataChangeListener?.(index, item)
              })

          }
        }
        .padding({
          top: 24,
          bottom: 14
        })
        .onClick(() => {
          // 此处触发radioButton变化
          param.dataChangeListener(index, item)
        })
      }, (item: string) => {
        return item
      })
    }
    .width('100%')
    .divider({
      strokeWidth: 0.5,
      color: $r('sys.color.ohos_id_color_list_separator')
    })
    .padding({
      left: 28,
      right: 28
    })
  }
  .width('100%')
}