export enum NodeStatus {
  Active = 1,
  InActive = 0,
}

export class OrderNodeContentItem {
  nodeName?: string // 节点内容数组字符串
  color?: string // 节点字体颜色
}

export class OrderDetailBean {
  nodeStatus?: number //当前节点状态
  nextNodeStatus?: number //下一个节点的状态
  nodeName?: string //节点名称
  nodeContent?: OrderNodeContentItem[] // 节点内容
  nodeTime?: string //节点时间
}

@ComponentV2
export struct TimeLineNode {
  @Param bean: OrderDetailBean = new OrderDetailBean()
  @Param index: number = 0
  @Param totalSize: number = 0
  @Local minHeight: number = 58
  // 节点图标的高度
  @Local nodeIconHeight: number = 0
  // 节点文本内容的高度
  @Local nodeContentHeight: number = 0
  // 是否已调整
  @Local isAdjusted: boolean = false

  build() {
    Row() {
      RelativeContainer() {
        // 时间轴节点
        if (this.bean.nodeStatus === NodeStatus.Active) {
          Image($r('app.media.ic_process_ok'))
            .width(14)
            .height(14)
            .alignRules({
              middle: { anchor: '__container__', align: HorizontalAlign.Center }
            })
            .margin({ top: 4 })
        } else {
          Row()
            .width(7)
            .height(7)
            .backgroundColor('rgba(255, 75, 75, 1)')
            .borderRadius('50%')
            .alignRules({
              middle: { anchor: '__container__', align: HorizontalAlign.Center }
            })
            .margin({ top: 4 })
        }
        // 时间轴
        if (this.totalSize > 1) {
          if (this.index < this.totalSize - 1) {
            Column()
              .width(1)
              .height(this.minHeight)
              .backgroundColor('rgba(255, 75, 75, 1)')
              .onAreaChange((old, area) => {
                if (this.isAdjusted) {
                  return
                }
                this.nodeIconHeight = Number(area.height)
                if (this.nodeContentHeight > 0) {
                  const _height = this.nodeIconHeight - this.nodeContentHeight
                  this.minHeight += (20 - _height)
                  this.isAdjusted = true
                }
              })
              .alignRules({
                middle: { anchor: '__container__', align: HorizontalAlign.Center }
              })
              .margin({ top: this.index === 0 ? 4 : 0 })
          } else {
            Column()
              .width(1)
              .height(10)
              .backgroundColor('rgba(255, 75, 75, 1)')
              .onAreaChange((old, area) => {
                if (this.isAdjusted) {
                  return
                }
                this.nodeIconHeight = Number(area.height)
                if (this.nodeContentHeight > 0) {
                  const _height = this.nodeIconHeight - this.nodeContentHeight
                  this.minHeight += (20 - _height)
                  this.isAdjusted = true
                }
              })
              .alignRules({
                middle: { anchor: '__container__', align: HorizontalAlign.Center }
              })
          }
        }
      }
      .width(14)
      .height(this.index === this.totalSize - 1 ? this.nodeContentHeight : this.minHeight)
      .margin({ right: 5 })

      // 内容区域
      Column() {
        Text(this.bean.nodeName)
          .fontSize(14)
          .fontColor(Color.Black)
          .fontWeight(FontWeight.Regular)

        // 文本内容
        ForEach(this.bean.nodeContent, (item: OrderNodeContentItem, index) => {
          Text(item.nodeName)
            .fontSize(10)
            .fontWeight(FontWeight.Regular)
            .fontColor(item.color)
            .margin({ top: 1 })
        }, (item: OrderNodeContentItem) => JSON.stringify(item))

        Text(this.bean.nodeTime)
          .fontSize(10)
          .fontWeight(FontWeight.Regular)
          .fontColor('rgba(142, 142, 142, 1)')
          .margin({ top: 1 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .onAreaChange((old, area) => {
        this.nodeContentHeight = Number(area.height)
      })

    }
    .alignItems(VerticalAlign.Top)
    .width('100%')
  }

  getTitleColor(state: number) {
    if (state === NodeStatus.Active) {
      return $r('sys.color.font_primary')
    } else if (state === NodeStatus.InActive) {
      return $r('sys.color.font_tertiary')
    } else {
      return $r('sys.color.font_primary')
    }
  }

  getDateColor(state: number) {
    if (state === NodeStatus.Active) {
      return $r('sys.color.font_secondary')
    } else if (state === NodeStatus.InActive) {
      return $r('sys.color.font_tertiary')
    } else {
      return $r('sys.color.font_secondary')
    }
  }
}