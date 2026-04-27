import { CircleButtonModifier } from '../common/CircleButtonModifier';
import { Constant } from '../common/Constant';

@ComponentV2
export struct ContentTag {
  @Param pageNum: number = 0;
  @Param icon: ResourceStr = '';
  @Param label: string = '';
  @Event onClickEvent: () => void = () => {
  };
  @Local btnModifier: CircleButtonModifier = new CircleButtonModifier();

  build() {
    Column({ space: Constant.PADDING_S }) {
      if (this.pageNum) {
        Row() {
          Text(this.pageNum.toString().padStart(2, '0'))
            .fontSize(24)
            .fontWeight(FontWeight.Normal)
            .fontColor($r('sys.color.font_primary'))
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .borderRadius(Constant.HALF_PERCENT)
        .stateStyles({
          normal: {
            .backgroundColor($r('sys.color.comp_background_tertiary'))
          },
          clicked: {
            .backgroundColor($r('sys.color.interactive_pressed'))
          },
        })
      } else {
        Button() {
          SymbolGlyph(this.icon as Resource)
            .fontSize(24)
            .fontColor([$r('sys.color.icon_primary')])
            .fontWeight(FontWeight.Medium)
        }
        .attributeModifier(this.btnModifier)
      }

      Text(this.label)
        .fontSize($r('sys.float.Body_S'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_secondary'))
    }
    .onClick(() => {
      this.onClickEvent();
    })
  }
}