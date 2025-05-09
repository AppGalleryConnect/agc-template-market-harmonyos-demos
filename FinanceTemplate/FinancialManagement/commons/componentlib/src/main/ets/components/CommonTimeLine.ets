export class OrderDetailBean {
  nodeStatus?: number //当前节点状态
  nextNodeStatus?: number //下一个节点的状态
  nodeName?: string //节点名称
  nodeTime?: string //节点时间
}

@ComponentV2
export struct CommonTimeLine {
  @Param bean: OrderDetailBean = new OrderDetailBean()
  @Param index: number = 0
  @Param totalSize: number = 0
  @Param minHeight: number = 54

  build() {
    Row() {
      Column() {
        // 时间轴节点
        if (this.bean.nodeStatus === 1) {
          Image($r('app.media.ic_selected'))
            .width(16)
            .height(16)
        } else {
          Row()
            .width(8)
            .height(8)
            .backgroundColor('#C4C4C4')
            .borderRadius('50%')
            .margin({ bottom: 2 })
        }


        // 时间轴
        if (this.index < this.totalSize - 1) {
          Column()
            .width(2)
            .height(this.minHeight)
            .backgroundColor(this.bean.nextNodeStatus === 1 ? '#E4480C' : $r('sys.color.comp_divider'))
        }
      }
      .width(13)
      .margin({ right: 16 })

      // 内容区域
      Column() {
        Text(this.bean.nodeName)
          .fontSize(14)
          .fontColor(this.getTitleColor(this.bean.nodeStatus ?? 0))
          .fontWeight(FontWeight.Medium)

        Text(this.bean.nodeTime)
          .fontSize(12)
          .fontWeight(FontWeight.Regular)
          .fontColor(this.getDateColor(this.bean.nodeStatus ?? 0))
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .width('84%')
      .translate({ y: -4 })
    }
    .alignItems(VerticalAlign.Top)
    .width('100%')
    .padding(this.index === 0 ? { top: 4 } : { top: 2 })
  }

  getTitleColor(state: number) {
    if (state === 1) {
      return $r('sys.color.font_primary')
    } else if (state === 0) {
      return $r('sys.color.font_tertiary')
    } else {
      return $r('sys.color.font_primary')
    }
  }

  getDateColor(state: number) {
    if (state === 1) {
      return $r('sys.color.font_secondary')
    } else if (state === 0) {
      return $r('sys.color.font_tertiary')
    } else {
      return $r('sys.color.font_secondary')
    }
  }
}