import { allCancel, RecordingList, recordingList } from 'commonlib'

@Component
export struct recordingComponent {
  @State isBill: boolean = false
  @State private firstValue: string = '最近三天'
  @State index: number = 0
  @Link totalSelected: number
  @Link totalPrice: number
  @Link listItem: RecordingList[]
  @Link selectAll: boolean

  build() {
    Column() {
      Column() {
        Row() {
          Text(this.firstValue)
            .fontSize(14)
            .fontColor($r('app.color.tab_font_color_selected'))
            .margin({left:16})
          Image($r('app.media.arrow_bottom'))
            .width(24)
            .height(24)
            .margin({left:7,right:7})
        }
        .bindMenu([
          {
            value: '最近三天',
            action: () => {
              this.firstValue = '最近三天'
              this.index = 0
              this.listItem = recordingList[this.index]
              this.selectAll = false
              this.totalSelected = 0
              this.totalPrice = 0
              allCancel()
            }
          },
          {
            value: '最近一月',
            action: () => {
              this.firstValue = '最近一月'
              this.index = 1
              this.listItem = recordingList[this.index]
              this.selectAll = false
              this.totalSelected = 0
              this.totalPrice = 0
              allCancel()
            }
          },
          {
            value: '最近三月',
            action: () => {
              this.firstValue = '最近三月'
              this.index = 2
              this.listItem = recordingList[this.index]
              this.selectAll = false
              this.totalSelected = 0
              this.totalPrice = 0
              allCancel()
            }
          },
        ])
        .backgroundColor($r('app.color.tab_background_color_selected'))
        .alignItems(VerticalAlign.Center)
        .width(108)
        .height(40)
        .borderRadius(67)
        .margin({ top: 16 })

        Column() {
          ForEach(recordingList, (listItem: RecordingList[], index: number) => {
            if (index === this.index) {
              Scroll() {
                Column() {
                  ForEach(listItem, (item: RecordingList, index: number) => {

                    Row() {
                      if (this.isBill) {
                        Checkbox()
                          .width(20)
                          .height(20)
                          .margin({ left: 14, right: 14 })
                          .onChange((checked) => {
                            checked ? this.totalSelected++ : this.totalSelected--
                            checked ? this.totalPrice += item.price : this.totalPrice -= item.price
                            this.totalSelected === listItem.length ? this.selectAll = true : this.selectAll = false
                            item.checked = checked
                          })
                          .select(item.checked)
                      }
                      Column() {
                        Row() {
                          Image($r('app.media.clock'))
                            .width(16)
                            .height(16)
                          this.textBuilder(item.startData + ' ', 8)
                          this.textBuilder(item.startTime + '-', 0)
                          this.textBuilder(item.endTime, 0)
                        }

                        Row() {
                          Image($r('app.media.goTo'))
                            .width(16)
                            .height(16)
                          this.textBuilder(item.startLocation + '-', 8)
                          this.textBuilder(item.endLocation, 0)
                        }
                        .margin({ top: 8 })

                        Row() {
                          Image($r('app.media.payment'))
                            .width(16)
                            .height(16)
                          this.textBuilder('￥' + item.price, 8)
                        }
                        .margin({ top: 8 })

                        if (index !== listItem.length - 1) {
                          Divider()
                            .width('100%')
                            .margin({ top: 13 })
                        }

                      }
                      .alignItems(HorizontalAlign.Start)
                      .margin({ top: 12 })
                      .width(290)
                    }
                    .alignItems(VerticalAlign.Center)

                  }, (item: string, index: number) => item + index)
                }
              }
            }
          }, (item: string, index: number) => item + index)
        }
        .alignItems(HorizontalAlign.Center)
        .borderRadius(16)
        .margin({ top: 16 })
        .height(this.isBill ? 298 : 610)
        .width('100%')
        .backgroundColor($r('app.color.tab_font_color_selected'))
      }
      .width(328)
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  textBuilder(text: string, margin: number) {
    Text(text)
      .fontColor($r('app.color.tab_font_color'))
      .fontSize(14)
      .margin({ left: margin })
  }
}