import { CommonCharts } from 'componentlib'
import { PositionInfoVM } from '../../viewModels/PositionInfoVM'

@ComponentV2
export struct ProductReturns {
  vm: PositionInfoVM = PositionInfoVM.instance
  @Local fontColor: ResourceStr = $r('sys.color.font_secondary')
  @Local selectedFontColor: string = '#E4480C'
  private controller: TabsController = new TabsController()

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.Start, index: this.vm.currentIndex, controller: this.controller }) {
        TabContent() {
          Column() {
            if (this.vm.xData.length > 0) {
              CommonCharts({ xData: this.vm.xData, seriesData: this.vm.seriesData, label: '收益统计' })
            }
          }
        }
        .tabBar(this.tabBuilder(0, '收益统计'))

        TabContent() {
          Column() {
            if (this.vm.xData.length > 0) {
              CommonCharts({ xData: this.vm.xData, seriesData: this.vm.seriesData, label: '七日年化' })
            }
          }
        }
        .tabBar(this.tabBuilder(1, '七日年化'))
      }
      .vertical(false)
      .barMode(BarMode.Fixed)
      .barWidth('100%')
      .barHeight(56)
      .height(238)
      .animationDuration(400)
      .onChange((index: number) => {
        this.vm.tabChange(index)
      })
      .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {
        if (index === targetIndex) {
          return
        }
        this.vm.selectedIndex = targetIndex
      })
    }
    .backgroundColor($r('sys.color.background_primary'))
    .padding({
      left: 12,
      right: 12,
      bottom: 12
    })
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 12 })
    .borderRadius(16)
  }

  @Builder
  tabBuilder(index: number, name: string) {
    Column() {
      Column() {
        Text(name)
          .fontColor(this.vm.selectedIndex === index ? this.selectedFontColor : this.fontColor)
          .fontSize(14)
          .fontWeight(this.vm.selectedIndex === index ? FontWeight.Bold : FontWeight.Regular)
          .margin({ top: 17, bottom: 7 })
        Divider()
          .strokeWidth(2)
          .color('#E4480C')
          .opacity(this.vm.selectedIndex === index ? 1 : 0)
      }
      .width(56)
    }
    .width('100%')
  }
}