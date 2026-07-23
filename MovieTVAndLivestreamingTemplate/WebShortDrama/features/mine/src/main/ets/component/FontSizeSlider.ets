import { fp2pxUtil } from '@agctemplate/widgets';

export interface ISelectOption {
  id: number | string;
  label: string;
  value?: Object;
}

enum FontSizeEnum {
  SMALL = 0.85,
  NORMAL = 1,
  LARGE = 1.15,
  XL = 1.45,
}

const FONT_SIZE_LIST: ISelectOption[] = [
  {
    id: 0,
    value: FontSizeEnum.SMALL,
    label: '小',
  },
  {
    id: 1,
    value: FontSizeEnum.NORMAL,
    label: '标准',
  },
  {
    id: 2,
    value: FontSizeEnum.LARGE,
    label: '大',
  },
  {
    id: 3,
    value: FontSizeEnum.XL,
    label: '特大',
  },
];

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
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        left: 12,
        right: 12,
        top: 16,
        bottom: 16,
      })

      Row({ space: 8 }) {
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
          .margin(12)
          .onChange((value: number) => {
            this.sliderV = value;
            this.onRatioChange(FONT_SIZE_LIST[value].value as number);
          })
        Text('A')
          .fontSize(this.getDescFg(14 * FontSizeEnum.XL))
          .fontColor($r('sys.color.font_secondary'))
          .accessibilityLevel('no')
      }
      .width('100%')
      .padding({
        left: 24,
        right: 24,
      })
    }
    .width('100%')
    .borderRadius(20)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .clip(true)
    .padding({
      top: 4,
      bottom: 4,
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
