import { IconTextItem } from '../commons/Interface';

export interface TextPickerBuilderParams {
  textList: IconTextItem[],
  type: string,
  confirm: (data: IconTextItem) => void
}


@Builder
export function textPickerBuilder(builderParams: TextPickerBuilderParams) {
  CommonTextPicker({
    list: builderParams.textList,
    type: builderParams.type,
    handleConfirm: builderParams.confirm,
  })
}

@ComponentV2
export struct CommonTextPicker {
  @Param list: IconTextItem[] = [];
  @Param type: string = '';
  @Event handleConfirm: (data: IconTextItem) => void;

  build() {
    Column() {
      Grid() {
        ForEach(this.list, (item: IconTextItem) => {
          GridItem() {
            Column({ space: 8 }) {
              if (this.type === 'weather') {
                this.weatherView(item)
              }
              if (this.type === 'mood') {
                Image($r(item.icon))
                  .width(40)
              }

              Text(item.text)
                .fontSize(14)
                .fontColor($r('sys.color.font_primary'))
                .lineHeight(19)
            }
            .padding(8)
            .onClick(() => {
              this.handleConfirm?.(item)
            })
          }
        }, (item: IconTextItem) => JSON.stringify(item))
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
      .columnsGap(10)
      .rowsGap(10)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .margin({ bottom: 16 })
    }
    .height('100%')
    .width('100%')
    .padding(16)
  }

  @Builder
  weatherView(item: IconTextItem) {
    Row() {
      SymbolGlyph($r(item.icon))
        .fontColor([$r('sys.color.white')])
        .fontSize(24)
    }
    .width(40)
    .height(40)
    .borderRadius(20)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .linearGradient({
      direction: GradientDirection.Top,
      colors: [['#E63C60', 0.0], ['#FFC2CF', 1]]
    })
  }
}