import { ToggleItem } from '../models/CommonModel'

@ComponentV2
export struct ToggleChoose {
  @Param toggleList: ToggleItem[] = []
  @Local choose: string = ''
  @Event chooseChange: (index: number) => void = () => {
  }

  aboutToAppear(): void {
    this.choose = this.toggleList[0].id
  }

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(this.toggleList, (item: ToggleItem,index:number) => {
          Row() {
            Text(item.name)
          }
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.choose === item.id ? $r('sys.color.background_primary') :
          $r('sys.color.background_secondary'))
          .borderRadius(18)
          .flexGrow(1)
          .onClick(() => {
            this.choose = item.id
            this.chooseChange(index)
          })
        }, (item: ToggleItem) => item.id)
      }
      .backgroundColor($r('sys.color.background_secondary'))
      .height(36)
      .borderRadius(18)
      .padding(3)
    }
    .padding({ left: 16, right: 16 })
    .margin({ top: 18, bottom: 8 })
  }
}