import { Divider } from '../model/Divider';
import { TextStyleModifier } from '../model/TextStyleModifier';
import { AlmanacVM } from '../viewmodel/ViewModel';

@ComponentV2
export struct FiveElementsClashElements {
  /**
   * 传入的当前时间
   */
  @Param selectedTime: Date = new Date()
  /**
   * list组件公用分割线
   */
  @Local egDivider: Divider = new Divider(1, 1, 1, '#cccccc')

  /**
   * 五行点击事件
   */
  @Event onFiveElementClick:( fiveElement: string[]) => void = () => {}
  /**
   * 冲煞点击事件
   */
  @Event onClashElementsClick:(clashElements: string) => void = () => {}

  almanacVM: AlmanacVM = AlmanacVM.instance;

  build() {
    List() {
      ListItem() {
        Column({ space: 5 }) {
          Text('五行：')
            .attributeModifier(new TextStyleModifier('#966426/Body_L/Bold'))
          Text() {
            ForEach(this.almanacVM.fiveElement, (item: string) => {
              Span(item + ' ')
            }, (item: string) => item)
          }
          .attributeModifier(new TextStyleModifier('font_primary/Body_M/Regular'))
        }
        .width('50%')
        .alignItems(HorizontalAlign.Start)
        .onClick(() => {
          this.onFiveElementClick(this.almanacVM.fiveElement)
        })
      }

      ListItem() {
        Column({ space: 5 }) {
          Text('冲煞：')
            .attributeModifier(new TextStyleModifier('#966426/Body_L/Bold'))
          Text(this.almanacVM.clashElements)
            .attributeModifier(new TextStyleModifier('font_primary/Body_M/Regular'))
        }
        .width('50%')
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
        .onClick(() => {
          this.onClashElementsClick(this.almanacVM.clashElements)
        })
      }
    }
    .width('100%')
    .listDirection(Axis.Horizontal)
    .edgeEffect(EdgeEffect.None)
    .divider(this.egDivider)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .scrollBar(BarState.Off)
    .padding({
      left: 12,
      top: 16,
      bottom: 16,
      right: 12,
    })
    .margin({ top: 26 })
  }
}
