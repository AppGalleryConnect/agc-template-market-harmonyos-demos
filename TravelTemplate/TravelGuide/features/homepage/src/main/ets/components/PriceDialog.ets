import { promptAction } from '@kit.ArkUI'
import { HotelListPageVM } from '../viewmodel/HotelListPageVM'

@ComponentV2
export struct PriceDialog {
  // 价格数组
  @Param priceArray: string[] = ['0-150', '150-300', '300-450', '450-600', '600-1000', '1000以上']
  // 选择回调排序方式
  @Param price: number[] = [0, 0]
  // 星级数组
  @Param starArray: string[] = ['二星及以下/经济', '三星/舒适', '四星/高档', '五星/豪华', '奢华酒店', '顶奢酒店']
  @Param @Require vm: HotelListPageVM
  @Local star: string = ''
  @Event onSearch: (minPrice: string, maxPrice: string, star: string) => void = () => {
  }
  @Event clear: () => void = () => {
  }

  build() {
    Column() {
      Row() {
        Text('价格区间').fontSize(14).fontColor('#333333').height(19).textAlign(TextAlign.Center)
      }
      .height(44)
      .width('100%')
      .padding({
        left: 16,
        right: 15
      })
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)

      // 最低价-最高价
      Row() {
        Row() {
          TextInput({ placeholder: '最低价', text: $$this.vm.priceMinString })
            .placeholderFont({
              size: $r('sys.float.Body_L'),
              weight: FontWeight.Medium
            })
            .placeholderColor($r('sys.color.font_secondary'))
            .type(InputType.Number)
            .textAlign(TextAlign.Center)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
            .fontSize(12)
            .backgroundColor('#F2F4F5')
            .borderRadius(17)
            .borderWidth(0.5)
            .borderColor('rgba(0, 0, 0, 0.03)')
            .width('100%')
            .height('100%')
        }
        .layoutWeight(1)
        .height('100%')

        Divider()
          .height(1)
          .width(10)
          .margin({
            left: 6,
            right: 5
          })
          .backgroundColor('rgba(112, 112, 112, 0.4)')

        Row() {
          TextInput({ placeholder: '最高价', text: $$this.vm.priceMaxString })
            .placeholderFont({
              size: $r('sys.float.Body_L'),
              weight: FontWeight.Medium
            })
            .placeholderColor($r('sys.color.font_secondary'))
            .type(InputType.Number)
            .textAlign(TextAlign.Center)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
            .fontSize(12)
            .backgroundColor('#F2F4F5')
            .borderRadius(17)
            .borderWidth(0.5)
            .borderColor('rgba(0, 0, 0, 0.03)')
            .width('100%')
            .height('100%')
        }
        .layoutWeight(1)
        .height('100%')

      }
      .height(36)
      .width('100%')
      .padding({
        left: 16,
        right: 15
      })
      .alignItems(VerticalAlign.Center)

      // 价格数组：3*2
      Column() {
        Grid() {
          ForEach(this.priceArray, (item: string, index: number) => {
            GridItem() {
              Column() {
                Text(item)
                  .fontSize(12)
                  .fontColor('rgba(0, 0, 0, 0.8)')
                  .fontWeight(FontWeight.Medium)
              }
              .onClick(() => {
                // 获取价格最低价 和 最高价
                this.vm.currentPriceIndex = index
                this.getPriceString(item)
              })
              .height(36)
              .width('100%')
              .borderRadius(8)
              .backgroundColor(this.vm.currentPriceIndex === index ? '#FFE431' : '#F6F8F9')
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            }
            .height(36)
            .width('100%')

          },(item: string) => JSON.stringify(item))
        }
        .width('100%')
        .columnsTemplate('1fr 1fr 1fr')
        .rowsTemplate('1fr 1fr')
        .rowsGap(8)
        .columnsGap(8)
      }
      .width('100%')
      .height(80)
      .padding({
        left: 16,
        right: 16
      })
      .margin({
        top: 8
      })

      Row() {
        Text('星级').fontSize(14).fontColor('#333333').height(19).textAlign(TextAlign.Center)
      }
      .height(44)
      .width('100%')
      .padding({
        left: 16,
        right: 15
      })
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)

      // 星级数组：3*2
      Column() {
        Grid() {
          ForEach(this.starArray, (item: string, index: number) => {
            GridItem() {
              Column() {
                Text(item)
                  .fontSize(12)
                  .fontColor('rgba(0, 0, 0, 0.8)')
                  .fontWeight(FontWeight.Medium)
              }
              .onClick(() => {
                this.vm.currentStarIndex = index
                this.getStarString(this.vm.currentStarIndex)
              })
              .height(36)
              .width('100%')
              .borderRadius(8)
              .backgroundColor(this.vm.currentStarIndex === index ? '#FFE431' : '#F6F8F9')
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            }
            .height(36)
            .width('100%')

          },(item: string) => JSON.stringify(item))
        }
        .width('100%')
        .columnsTemplate('1fr 1fr 1fr')
        .rowsTemplate('1fr 1fr')
        .rowsGap(8)
        .columnsGap(8)
      }
      .width('100%')
      .height(80)
      .padding({
        left: 16,
        right: 16
      })


      Row() {
        Text('清空')
          .fontSize(14)
          .fontColor('#333333')
          .fontWeight(500)
          .padding({
            top: 12,
            left: 27,
            bottom: 12,
            right: 27
          })
          .borderWidth(0.5)
          .borderRadius(24)
          .borderColor('rgba(0, 0, 0, 0.10)')
          .onClick(() => {
            this.vm.priceMinString = ''
            this.vm.priceMaxString = ''
            this.vm.currentPriceIndex = -1
            this.vm.currentStarIndex = -1
            this.clear()
          })
        Column() {
          Text(`查看酒店`).fontSize(14).fontColor('#333333').fontWeight(500)
        }
        .onClick(() => {
          if (this.vm.currentStarIndex < 0) {
            if (this.vm.currentPriceIndex === 5) {
              if (this.vm.priceMinString === '') {
                promptAction.showToast({
                  message: '请填写完整的价格范围'
                })
                return;
              }
            } else {
              if (this.vm.priceMinString === '' || this.vm.priceMaxString === '') {
                promptAction.showToast({
                  message: '请填写完整的价格范围'
                })
                return;
              }
            }
            this.onSearch(this.vm.priceMinString, this.vm.priceMaxString, this.star)
          } else {
            this.onSearch(this.vm.priceMinString, this.vm.priceMaxString, this.star)
          }
        })
        .margin({ left: 10 })
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)
        .height(40)
        .backgroundColor('#FEE231')
        .borderRadius(24)
      }.height(60).justifyContent(FlexAlign.SpaceBetween).padding({ left: 16, right: 16 }).margin({ top: 10 })
    }
    .borderRadius({
      bottomLeft: 24,
      bottomRight: 24
    })
    .backgroundColor(Color.White)
  }

  // 获取价格最低价和最高价
  getPriceString(item: string) {
    if (item.indexOf('-') >= 0) {
      this.vm.priceMinString = item.split('-')[0]
      this.vm.priceMaxString = item.split('-')[1]
    } else if (item.indexOf('以上') >= 0) {
      this.vm.priceMinString = item.split('以上')[0]
      this.vm.priceMaxString = ''
    }

  }

  getStarString(item: number) {
    switch (item) {
      case 0:
        this.star = '二星'
        break;
      case 1:
        this.star = '三星'
        break;
      case 2:
        this.star = '四星'
        break;
      case 3:
        this.star = '五星'
        break;
      case 4:
        this.star = '奢华'
        break;
      case 5:
        this.star = '顶奢'
        break;
    }
  }
}