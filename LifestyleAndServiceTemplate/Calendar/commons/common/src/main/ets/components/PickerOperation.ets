import { TextStyleModifier } from '../style/CommonStyle'

@ComponentV2
export struct PickerOperation {
  @Event cancel: () => void = () => {
  }
  @Event confirm: () => void = () => {
  }

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween }) {
      Row() {
        Text('取消')
          .attributeModifier(new TextStyleModifier('font_primary/Body_L/Bold'))
      }
      .onClick(() => {
        this.cancel()
      })

      Row() {
        Text('确认')
          .attributeModifier(new TextStyleModifier('#FFE94949/Body_L/Bold'))
      }
      .onClick(() => {
        this.confirm()
      })
    }
    .width('100%')
    .padding({
      left: 20,
      right: 20,
      top: 10,
      bottom: 10,
    })
    .backgroundColor(Color.White)
    .border({
      width: { bottom: 1 },
      color: { bottom: '#eee' },
    })
  }
}