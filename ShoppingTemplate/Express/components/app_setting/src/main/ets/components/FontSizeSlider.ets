import { fp2pxUtil } from '../common/FontUtils';
import { CommonConstants } from '../constants/CommonConstants';
import { FONT_SIZE_LIST, FontSizeEnum } from '../constants/FontOptions';

@ComponentV2
export struct FontSizeSlider {
  @Param currentRatio: number = FontSizeEnum.NORMAL;
  @Param disabled: boolean = false;
  @Param themeColor: ResourceColor = $r('sys.color.brand');
  @Event onRatioChange: (value: FontSizeEnum) => void = () => {
  };
  @Local sliderV: number = 1;

  aboutToAppear(): void {
    this.initSliderValue();
  }

  build() {
    Column() {
      Row() {
        Text('字体大小')
          .fontSize(this.getDescFg(16))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
        Text(this.currentRatioLabel)
          .fontSize(this.getDescFg(14))
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Regular)
      }
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        left: CommonConstants.PADDING_M,
        right: CommonConstants.PADDING_M,
        top: CommonConstants.PADDING_L,
        bottom: CommonConstants.PADDING_L,
      })

      Row({ space: CommonConstants.PADDING_S }) {
        Text('A')
          .fontSize(this.getDescFg(14 * FontSizeEnum.SMALL))
          .fontColor($r('sys.color.font_secondary'))
          .accessibilityLevel('no')
        Slider({
          min: 0,
          max: 3,
          step: 1,
          style: SliderStyle.InSet,
          value: this.sliderV,
        })
          .layoutWeight(1)
          .showSteps(true)
          .enabled(!this.disabled)
          .selectedColor(this.themeColor)
          .opacity(this.disabled ? 0.3 : 1)
          .height(20)
          .margin(CommonConstants.PADDING_M)
          .onChange((value: number) => {
            this.sliderV = value;
            this.onRatioChange(FONT_SIZE_LIST[value].value as number);
          })
        Text('A')
          .fontSize(this.getDescFg(14 * FontSizeEnum.XL))
          .fontColor($r('sys.color.font_secondary'))
          .accessibilityLevel('no')
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding({
        left: CommonConstants.PADDING_XXL,
        right: CommonConstants.PADDING_XXL,
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .borderRadius($r('app.float.xl_radius'))
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .clip(true)
    .padding({
      top: CommonConstants.PADDING_XS,
      bottom: CommonConstants.PADDING_XS,
    })
  }

  initSliderValue() {
    const item = FONT_SIZE_LIST.find(v => v.value === this.currentRatio);
    if (item) {
      this.sliderV = item.id as number;
    }
  }

  getDescFg(fg: number): number | string {
    return fp2pxUtil(fg);
  }

  @Computed
  get currentRatioLabel() {
    return FONT_SIZE_LIST[this.sliderV].label;
  }
}
