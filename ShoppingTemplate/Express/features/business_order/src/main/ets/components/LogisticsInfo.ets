import { CommonUtil, Logistics, STATUS_MAP } from 'lib_foundation'
import { nodeListData } from '../constants'


@ComponentV2
export struct LogisticsInfo {
  @Param minHeight: number = 54;
  @Param logisticsList: Logistics[] = [];

  getNodeIcon(node: Logistics, index: number) {
    const nodeItem = nodeListData.find((item) => item.status === node.nodeStatus)
    if (index === 0) {
      return nodeItem?.selectedImage ?? '';
    }
    return nodeItem?.image ?? '';
  }

  build() {
    Column() {
      ForEach(this.logisticsList, (node: Logistics, index: number) => {
        Flex({ alignItems: ItemAlign.Start }) {
          Column() {
            Image(this.getNodeIcon(node, index))
              .width(24)
              .height(28)
            if (index !== this.logisticsList.length - 1) {
              Column()
                .width(2)
                .height(this.minHeight)
                .borderWidth({ right: 1 })
                .borderColor($r('sys.color.comp_divider'))
                .borderStyle(BorderStyle.Dashed)
                .margin({ left: -1 })
            }
          }

          Column() {
            Text(STATUS_MAP[node.nodeStatus])
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .lineHeight(19)
              .margin({ top: 4 })


            Text(CommonUtil.formatDate(node.occurrenceTime, 'YYYY-MM-DD HH:mm'))
              .fontSize(10)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: 4, bottom: 4 })

            Text(node.description)
              .fontSize(10)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_primary'))
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 8 })
          .flexGrow(1)
        }
        .width('100%')
      }, (item: Logistics[]) => JSON.stringify(item))
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .borderRadius({ topLeft: 16, topRight: 16 })
  }
}