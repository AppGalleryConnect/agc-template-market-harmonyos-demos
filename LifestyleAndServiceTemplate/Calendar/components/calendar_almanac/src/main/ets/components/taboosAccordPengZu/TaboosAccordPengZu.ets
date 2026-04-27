import { BaseTextStyleModifier } from 'base_apis'
import { AlmanacVM } from '../../viewModel/ViewModel'

@ComponentV2
export struct TaboosAccordPengZu {
  /**
   * 凶神宜忌点击事件
   */
  @Event onXiongShenYiJiClick: (xiongShenYiJi: string[]) => void = () => {}
  /**
   * 吉神宜趋点击事件
   */
  @Event onJiShenYiQuClick: (jiShenYiQu: string[]) => void = () => {}
  /**
   * 彭祖白忌点击事件
   */
  @Event onPengZuBaiJiClick: (pengZuBaiJi: string) => void = () => {}

  almanacVM: AlmanacVM = AlmanacVM.instance;

  build() {
    Column() {
      Column({ space: 5 }) {
        Text('彭祖百忌')
          .attributeModifier(new BaseTextStyleModifier('font_primary/Body_L/Bold'))
        Column() {
          Text(this.almanacVM.pengZuBaiJi)
            .attributeModifier(new BaseTextStyleModifier('font_primary/Body_M/Regular'))
        }
      }
      .width('100%')
      .padding({ bottom: 16 })
      .border({ width: { bottom: 1 }, color: $r('app.color.splits_color') })
      .onClick(() => {
        this.onPengZuBaiJiClick(this.almanacVM.pengZuBaiJi)
      })
      Flex() {
        Column() {
          Text('吉神宜趋')
            .attributeModifier(new BaseTextStyleModifier('font_primary/Body_L/Bold'))
          Column() {
            Text() {
              ForEach(this.almanacVM.jiShenYiQu, (item: string) => {
                Span(item + ' ')
              }, (item: string) => item)
            }
            .attributeModifier(new BaseTextStyleModifier('font_primary/Body_M/Regular'))
          }
          .padding(12)
        }
        .onClick(() => {
          this.onJiShenYiQuClick(this.almanacVM.jiShenYiQu)
        })
        .width('50%')
        .border({ color: $r('app.color.splits_color'), width: { right: 1 } })
        .justifyContent(FlexAlign.Center)

        Column() {
          Text('凶神宜忌')
            .attributeModifier(new BaseTextStyleModifier('font_primary/Body_L/Bold'))
          Column() {
            Text() {
              ForEach(this.almanacVM.xiongShenYiJi, (item: string) => {
                Span(item + ' ')
              }, (item: string) => item)
            }
            .attributeModifier(new BaseTextStyleModifier('font_primary/Body_M/Regular'))
          }
          .padding(12)
        }.width('50%')
        .onClick(() => {
          this.onXiongShenYiJiClick(this.almanacVM.xiongShenYiJi)
        })
      }.margin({ top: 15 })
    }
    .backgroundColor($r('sys.color.background_primary'))
    .margin({ top: 12 })
    .borderRadius(16)
    .padding({
      top: 16,
      bottom: 16,
      left: 12,
      right: 12,
    })
  }
}
