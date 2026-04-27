import { AppStorageV2 } from '@kit.ArkUI'
import { BreakpointModel } from 'common'
import { GridRowColSetting } from 'common/src/main/ets/constant/GridRowColSetting';
import { CommonPageVM } from '../viewmodel/CommonPageVM';

@ComponentV2
export struct PriceSelectDialog {
  @Param @Require vm: CommonPageVM
  // 价格数组
  @Param priceArray: string[] = ['0-499', '500-999', '1000-1499', '1500-1999', '2000-2999', '3000以上']
  // 选择回调排序方式
  @Param price: number[] = [0, 0]
  // 回调函数
  @Param priceResult: (arr: string[]) => void = (arr: string[]) => {
  }
  // 输入框中的最低价
  @Local priceMinString: string = ''
  // 输入框中的最高价
  @Local priceMaxString: string = ''
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  // 屏幕的宽度
  @Local selectItemHeight: number = GridRowColSetting.checkColumnCountModel() ? 40 : 80;
  // Grid三列字符串
  @Local gridThreeColumnsModel: string = GridRowColSetting.getColumnCountModel(3)
  // Grid单行字符串
  @Local gridSingleRowsModel: string = GridRowColSetting.checkColumnCountModel() ? '1fr' : '1fr 1fr'

  @Monitor('breakPointModel.currentBreakpoint')
  breakPointChange() {
    this.selectItemHeight = GridRowColSetting.checkColumnCountModel() ? 40 : 80
    this.gridThreeColumnsModel = GridRowColSetting.getColumnCountModel(3)
    this.gridSingleRowsModel = GridRowColSetting.checkColumnCountModel() ? '1fr' : '1fr 1fr'
  }

  aboutToAppear(): void {
    this.priceMinString = this.vm.priceSelected[0] === 0 ? '' : this.vm.priceSelected[0].toString()
    this.priceMaxString = this.vm.priceSelected[1] === 100000 ? '' : this.vm.priceSelected[1].toString()
  }

  build() {
    Column() {
      // 价格范围
      Row() {
        Text('价格范围（元）').fontSize(16).fontColor('rgba(0, 0, 0, 0.9)').height(19).textAlign(TextAlign.Center)
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
          TextInput({ placeholder: '最低价', text: this.priceMinString })
            .placeholderFont({
              size: $r('sys.float.Body_L'),
              weight: FontWeight.Medium
            })
            .placeholderColor($r('sys.color.font_secondary'))
            .type(InputType.Number)
            .textAlign(TextAlign.Center)
            .fontColor('rgba(0, 0, 0, 0.85)')
            .fontWeight(FontWeight.Medium)
            .fontSize(14)
            .backgroundColor('rgba(255, 255, 255, 1)')
            .borderRadius(8)
            .borderWidth(1)
            .borderColor('rgba(112, 112, 112, 0.1)')
            .width('100%')
            .height('100%')
            .onChange((value: string) => {
              this.priceMinString = value
            })
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
          TextInput({ placeholder: '最高价', text: this.priceMaxString })
            .placeholderFont({
              size: $r('sys.float.Body_L'),
              weight: FontWeight.Medium
            })
            .placeholderColor($r('sys.color.font_secondary'))
            .type(InputType.Number)
            .textAlign(TextAlign.Center)
            .fontColor('rgba(0, 0, 0, 0.85)')
            .fontWeight(FontWeight.Medium)
            .fontSize(14)
            .backgroundColor('rgba(255, 255, 255, 1)')
            .borderRadius(8)
            .borderWidth(1)
            .borderColor('rgba(112, 112, 112, 0.1)')
            .width('100%')
            .height('100%')
            .onChange((value: string) => {
              this.priceMaxString = value
            })
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
                  .fontSize(14)
                  .fontColor('rgba(0, 0, 0, 0.8)')
                  .fontWeight(FontWeight.Medium)
                  .onClick(() => {
                    // 获取价格最低价 和 最高价
                    this.getPriceString(item)
                  })
              }
              .height(36)
              .width('100%')
              .borderRadius(8)
              .backgroundColor('rgba(0, 0, 0, 0.05)')
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            }
            .height(36)
            .width('100%')

          }, (item: string, index: number) => JSON.stringify(item) + index)
        }
        .width('100%')
        .columnsTemplate(this.gridThreeColumnsModel)
        .rowsTemplate(this.gridSingleRowsModel)
        .rowsGap(8)
        .columnsGap(8)
      }
      .width('100%')
      .height(this.selectItemHeight)
      .padding({
        left: 16,
        right: 16
      })
      .margin({
        top: 8
      })

      // 重置 和 确定
      Row() {
        Text('重置')
          .height(40)
          .fontSize(16)
          .fontColor('rgba(255, 75, 75, 1)')
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .borderRadius(8)
          .borderWidth(1)
          .borderColor('rgba(255, 75, 75, 1)')
          .layoutWeight(1)
          .margin({
            right: 8
          })
          .backgroundColor(Color.White)
          .onClick(() => {
            this.priceMinString = ''
            this.priceMaxString = ''
          })

        Text('确定')
          .height(40)
          .fontSize(16)
          .fontColor('rgba(255, 255, 255, 1)')
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .borderRadius(8)
          .layoutWeight(1)
          .margin({
            right: 8
          })
          .backgroundColor('rgba(255, 75, 75, 1)')
          .onClick(() => {
            if (this.priceMinString === '' && this.priceMaxString === '') {
              this.priceResult(['', ''])
            } else if (this.priceMaxString === '' && this.priceMinString !== '') {
              this.priceResult([this.priceMinString, ''])
            } else if (this.priceMaxString !== '' && this.priceMinString === '') {
              this.priceResult(['', this.priceMaxString])
            } else {
              this.priceResult([this.priceMinString, this.priceMaxString])
            }
          })
      }
      .width('100%')
      .height(40)
      .padding({
        left: 16,
        right: 16
      })
      .margin({
        top: 24,
        bottom: 24
      })
    }
    .borderRadius({
      bottomLeft: 32,
      bottomRight: 32
    })
    .backgroundColor(Color.White)
  }

  // 获取价格最低价和最高价
  getPriceString(item: string) {
    if (item.indexOf('-') >= 0) {
      this.priceMinString = item.split('-')[0]
      this.priceMaxString = item.split('-')[1]
    } else if (item.indexOf('以上') >= 0) {
      this.priceMinString = item.split('以上')[0]
      this.priceMaxString = ''
    }

  }
}