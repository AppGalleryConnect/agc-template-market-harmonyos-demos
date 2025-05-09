import { ISettingData } from 'network/src/main/ets/mocks/Constants'

@ComponentV2
export struct CommonFilter {
  @Param text: string = ''
  @Param list: ISettingData[] = []
  @Param value: number = 0
  @Local currentValue: number = 0
  @Event changeValue: (value: number) => void = () => {
  }

  aboutToAppear(): void {
    this.currentValue = this.value
  }

  build() {
    Column() {
      Text('销售状态')
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .fontSize(16)
        .margin({ bottom: 12 })

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.list, (item: ISettingData) => {
          Stack() {
            Row()
              .contentStyles()
              .backgroundColor(item.value === this.currentValue ? '#E4480C' :
              $r('sys.color.comp_background_tertiary'))
              .opacity(0.2)

            Row() {
              Text(item.label)
                .fontSize(14)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_primary'))
            }
            .contentStyles()
            .justifyContent(FlexAlign.Center)
            .backgroundColor(item.value === this.currentValue ? '' :
            $r('sys.color.comp_background_tertiary'))
          }
          .onClick(() => {
            this.currentValue = item.value
            this.changeValue(item.value)
          })
        }, (item: ISettingData[]) => JSON.stringify(item))
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Styles
  contentStyles() {
    .width(76)
    .height(28)
    .borderRadius(27)
    .margin({ right: 8, bottom: 8 })
  }
}