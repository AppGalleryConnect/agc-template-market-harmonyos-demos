import { SymbolGlyphModifier } from '@kit.ArkUI';
import { JSON } from '@kit.ArkTS';
import { Type } from '../constant/Constant';

@ComponentV2
export struct SearchFilterContent {
  @Param placeHolder: string = '';
  @Local selectIndex: number = 0;
  @Local searchWord: string = '';
  @Param typeList: string[] = [];
  @Param @Once onContentChange: (name: string, index: number, searchWord: string) => void =
    (name: string, index: number, searchWord: string) => {
    };

  build() {
    Column() {
      Search({ placeholder: this.placeHolder, value: $$this.searchWord })
        .width('100%')
        .backgroundColor('#E5E7E8')
        .placeholderColor($r('sys.color.font_secondary'))
        .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
        .cancelButton({
          style: CancelButtonStyle.INPUT,
          icon: new SymbolGlyphModifier($r('sys.symbol.xmark_circle')).fontColor([Color.Gray])
            .outlineColor(Color.Gray)
        })
        .margin({ bottom: 15 })
        .borderRadius(20)
        .onChange(() => {
          this.onContentChange('', this.selectIndex, this.searchWord)
        })

      List({ space: 16 }) {
        ForEach(this.typeList, (item: string, index: number) => {
          ListItem() {
            Row() {
              Button(item, { type: ButtonType.Capsule, stateEffect: true })
                .fontColor(
                  this.selectIndex === index ? $r('sys.color.font_on_primary') : $r('sys.color.font_secondary')
                )
                .backgroundColor(this.selectIndex === index ? '#FF9019' : $r('sys.color.comp_background_tertiary'))
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(this.selectIndex === index ? FontWeight.Bold : FontWeight.Regular)
            }
            .justifyContent(FlexAlign.Center)
            .width(75)
            .height(40)
            .onClick(() => {
              this.selectIndex = index;
              this.onContentChange(item, this.selectIndex, this.searchWord)
            })
          }
        }, (item: Type) => JSON.stringify(item))
      }
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .height(40)
      .margin({ bottom: 15 })
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })

    }
  }
}