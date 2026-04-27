import { StyleConstants } from '../constants/Styles';
import { ExchangeVM } from '../viewmodel/ExchangeVM';

@ComponentV2
export struct CardItem {
  @Require @Param index: number;
  @Local editFlag: boolean = false;
  vm: ExchangeVM = ExchangeVM.instance;
  shadowOption: ShadowOptions =
    { radius: this.getUIContext().vp2px(8), color: 'rgba(0, 0, 0, 0.2)' }

  build() {
    ListItem() {
      Row() {
        Row() {
          Image(this.vm.exchangeData[this.index].pic).height(StyleConstants.IMAGE_40).width(StyleConstants.IMAGE_64)
          Text(this.vm.exchangeData[this.index].country)
            .mainStyle()
            .margin({ left: StyleConstants.SPACE_12, right: StyleConstants.SPACE_24 })
        }

        Column({ space: StyleConstants.SPACE_2 }) {
          TextInput({ text: this.vm.results[this.index] })
            .subStyle1()
            .fontColor(this.vm.keyboardShow ? $r('sys.color.font_tertiary') : $r('sys.color.font_primary'))
            .onEditChange((editFlag: boolean) => {
              this.editFlag = editFlag;
            })
            .onChange((newText) => {
              if (!this.editFlag) {
                return;
              }
              this.vm.calcBaseValue(newText, this.index);
            })
          Text(this.vm.exchangeData[this.index].name).subStyle2()
        }.alignItems(HorizontalAlign.End).layoutWeight(1)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width(StyleConstants.FULL_PERCENT)
    }
    .margin({ left: StyleConstants.SPACE_16, right: StyleConstants.SPACE_16 })
    .shadow(this.editFlag ? this.shadowOption : undefined)
    .padding(StyleConstants.SPACE_12)
    .borderRadius(StyleConstants.RADIUS_16)
    .backgroundColor($r('sys.color.background_primary'))
  }
}

@Extend(Text)
function mainStyle() {
  .fontWeight(FontWeight.Medium)
  .fontSize($r('sys.float.Body_L'))
  .fontColor($r('sys.color.font_primary'))
}


@Extend(TextInput)
function subStyle1() {
  .textAlign(TextAlign.End)
  .type(InputType.NUMBER_DECIMAL)
  .backgroundColor(Color.Transparent)
  .padding(0)
  .borderRadius(0)
  .fontSize($r('sys.float.Body_L'))
  .fontWeight(FontWeight.Medium)
}

@Extend(Text)
function subStyle2() {
  .fontWeight(FontWeight.Regular)
  .fontSize($r('sys.float.Caption_L'))
  .fontColor($r('sys.color.font_secondary'))
}