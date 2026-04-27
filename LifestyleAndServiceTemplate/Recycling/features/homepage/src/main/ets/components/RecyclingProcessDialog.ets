import { MainPageVM, RecycleProcessInfo } from '../viewmodel/MainPageVM'

@ComponentV2
export struct RecyclingProcessDialog {
  @Param @Require vm: MainPageVM

  // 主题
  @Builder
  buildTitle() {
    RelativeContainer() {
      Text('回收流程').fontSize(20).fontColor('rgba(0, 0, 0, 0.85)').fontWeight(FontWeight.Medium)
        .alignRules({
          middle: { anchor: '__container__', align: HorizontalAlign.Center },
          center: { anchor: '__container__', align: VerticalAlign.Center }
        })

      Image($r('app.media.ic_close_btn'))
        .width(20)
        .height(20)
        .margin({ right: 21 })
        .alignRules({
          right: { anchor: '__container__', align: HorizontalAlign.End },
          center: { anchor: '__container__', align: VerticalAlign.Center }
        })
        .onClick(() => {
          this.vm.showRecycleProcess = false
        })
    }
    .width('100%')
    .height(56)
  }

  @Builder
  buildRecyclingProcessItem(item: RecycleProcessInfo, index: number) {
    Column() {
      Row() {
        Row() {
          Row() {
            Image(item.icon).width(24).height(24)
          }
          .width(36)
          .height(36)
          .borderRadius(18)
          .margin({ left: 12 })
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .linearGradient({
            angle: 90, // 渐变角度（0点方向顺时针）
            colors: [
              ['rgba(255, 75, 75, 1)', 0.0], // 起始颜色及位置
              ['rgba(255, 119, 119, 1)', 1.0]// 结束颜色及位置
            ]
          })

          Column() {
            Text(item.name).fontSize(16).fontColor('rgba(0, 0, 0, 1)').fontWeight(FontWeight.Medium)

            Text(item.des)
              .fontSize(12)
              .fontColor('rgba(0, 0, 0, 0.6)')
              .fontWeight(FontWeight.Regular)
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 16})
        }
        .width('100%')
        .height('100%')
        .border({ radius: 28 })
        .alignItems(VerticalAlign.Center)
        .backgroundColor('rgba(255, 255, 255, 1)')
        .shadow({
          radius: 28,
          offsetY: vp2px(3),
          offsetX: vp2px(0),
          color: 'rgba(0, 0, 0, 0.16)'
        })
      }
      .width('100%')
      .height(70)
      .borderRadius(35)
      .backgroundColor('rgba(255, 233, 233, 1)')
      .border({ width: 1, color: 'rgba(255, 75, 75, 1)' })
      .padding({
        left: 8,
        right: 8,
        top: 7,
        bottom: 7
      })

      if (item.hasNext) {
        Image($r('app.media.ic_recycling_process_next'))
          .width(24)
          .height(24)
      }

    }
    .width('100%')
    .margin({ top: index === 0 ? 12 : 0 })
    .padding({ left: 16, right: 16 })
    .alignItems(HorizontalAlign.Center)
  }

  // 内容
  @Builder
  buildContent() {
    Column() {
      ForEach(this.vm.recycleProcessArr, (item: RecycleProcessInfo, index: number) => {
        this.buildRecyclingProcessItem(item, index)
      }, (item: RecycleProcessInfo, index: number) => JSON.stringify(item) + index)
    }
    .width('100%')
  }

  build() {
    Column() {
      this.buildTitle()

      this.buildContent()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(255, 255, 255, 1)')
  }
}