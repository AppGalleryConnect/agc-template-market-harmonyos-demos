import { OrderDetailBean, TimeLineNode } from './TimeLineNode'

@ComponentV2
export struct CommonTimeLine {
  @Param timeLineList: OrderDetailBean[] = []
  @Param totalSize: number = 0
  @Local filterTimeLineList: OrderDetailBean[] = this.timeLineList.filter((item: OrderDetailBean, index: number) => {
    return true
  })
  @Local changeTotalSize: number = this.totalSize
  @Local isExpand: boolean = false

  aboutToAppear(): void {
    this.filterTimeLineList = this.timeLineList.filter((item: OrderDetailBean, index: number) => {
      if (index <= this.totalSize - 1) {
        return true
      }
      return false
    })
    this.filterTimeLineList.forEach((item: OrderDetailBean, index: number) => {
      if (index === this.totalSize - 1) {
        item.nodeStatus = 1
      }
    })
  }

  build() {
    List() {
      ForEach(this.filterTimeLineList, (item: object, index: number) => {
        ListItem() {
          TimeLineNode({ bean: item, index: index, totalSize: this.changeTotalSize })
        }
      }, (item: object) => JSON.stringify(item))

      // 收起和展开
      ListItem() {
        Row() {
          if (this.isExpand) {
            Row() {
              Text('展开').font({ size: 12 }).fontColor('rgba(0, 0, 0, 0.6)')

              Image($r('app.media.ic_pull_up')).size({ width: 16, height: 16 }).margin({ left: 4 })
            }.onClick(() => {
              this.isExpand = !this.isExpand
              this.filterTimeLineList = this.timeLineList.filter((item: OrderDetailBean, index: number) => {
                if (index <= this.totalSize - 1) {
                  return true
                }
                return false
              })
              this.changeTotalSize = this.totalSize
            })
          } else {
            Row() {
              Text('收起').font({ size: 12 }).fontColor('rgba(0, 0, 0, 0.6)')

              Image($r('app.media.ic_pull_down')).size({ width: 16, height: 16 }).margin({ left: 4 })
            }.onClick(() => {
              this.isExpand = !this.isExpand
              this.filterTimeLineList = this.timeLineList.filter((item: OrderDetailBean, index: number) => {
                return index === this.totalSize - 1
              })
              this.changeTotalSize = 1
            })
          }
        }.width('100%').justifyContent(FlexAlign.Center).margin({ top: 17, bottom: 17 })
      }
    }.edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
  }
}