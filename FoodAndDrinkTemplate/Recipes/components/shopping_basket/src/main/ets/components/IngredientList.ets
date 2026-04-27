import { IngredientItem } from '../types/Index'

@ComponentV2
export struct IngredientList {
  @Param @Require list: IngredientItem[]
  @Param isFinished: boolean = false
  @Param index: number = 0
  @Param isAllTab: boolean = false
  @Event callback: (item: IngredientItem) => void = () => {
  }

  build() {
    List({ space: 8 }) {
      ForEach(this.list, (item: IngredientItem) => {
        ListItem() {
          Row() {
            Checkbox({ name: item.name, group: `group${this.isFinished}${this.index}` })
              .select(this.isFinished)
              .height(24)
              .width(24)
              .selectedColor('#E84026')
              .shape(CheckBoxShape.CIRCLE)
              .onChange(() => {
                this.callback(item)
              })
            Text(item.name)
              .fontSize(12)
              .fontColor(this.isFinished ? $r('sys.color.font_secondary') : $r('sys.color.font_primary'))
              .layoutWeight(1)
              .decoration(this.isFinished ? {
                type: TextDecorationType.LineThrough,
                color: $r('sys.color.font_secondary'),
                style: TextDecorationStyle.SOLID,
              } : {
                type: TextDecorationType.None,
                color: Color.Black,
                style: TextDecorationStyle.SOLID,
              })
              .margin({ left: 8 })
            Text() {
              Span(this.isAllTab && item.unit ? item.sum : item.quantity)
              Span(item.unit)
            }
            .fontSize(12)
            .fontColor($r('sys.color.font_primary'))
            .layoutWeight(1)
            .margin({ left: 12 })
            .visibility(this.isFinished ? Visibility.None : Visibility.Visible)
          }
          .width('100%')
          .padding({
            top: 8,
            bottom: 8,
            left: 12,
            right: 12,
          })
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .borderRadius(16)
        }
      }, (item: IngredientItem) => JSON.stringify(item))
    }
    .contentEndOffset(12)
  }
}