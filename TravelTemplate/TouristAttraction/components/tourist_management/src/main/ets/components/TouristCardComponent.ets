import { TouristInfo } from 'module_base';

@Extend(Text)
function touristKeyText() {
  .fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_secondary'));
}

@Extend(Text)
function touristValueText() {
  .fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_primary'));
}

@ComponentV2
export struct TouristCardComponent {
  @Param @Require isInReserve: boolean = false;
  @Param @Require tourist: TouristInfo;
  @Event editTourist: () => void;
  @Event updateCheckStatus: (value: boolean) => void;

  build() {
    Row() {
      Row({ space: 12 }) {
        if (this.isInReserve) {
          Checkbox({})
            .select($$this.tourist.isChecked)
            .shape(CheckBoxShape.CIRCLE)
            .selectedColor($r('sys.color.multi_color_04'))
            .onChange((value: boolean) => { // 更新勾选状态
              this.updateCheckStatus(value);
            });
        }

        Column({ space: 2 }) {
          Text(this.tourist.name)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_L'));
          Row({ space: 4 }) {
            Text('证件号').touristKeyText();
            Text(this.tourist.cardNo).touristValueText();
          };

          Row({ space: 4 }) {
            Text('手机号').touristKeyText();
            Text(this.tourist.phone).touristValueText();
          };
        }.alignItems(HorizontalAlign.Start);
      };

      Row({ space: 24 }) {
        SymbolGlyph($r('sys.symbol.square_and_pencil'))
          .fontSize(24)
          .width(24)
          .height(24)
          .fontColor([$r('sys.color.icon_tertiary')])
          .onClick(() => {
            this.editTourist();
          });
      };
    }
    .padding(12)
    .width('100%')
    .borderRadius(16)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(
      this.isInReserve ? $r('sys.color.comp_background_tertiary') : $r('sys.color.comp_background_primary'));
  }
}