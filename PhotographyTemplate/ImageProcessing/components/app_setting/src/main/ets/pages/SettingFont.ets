import { GridRowColSetting } from '../common/GridRowColSetting';
import { FontSizeSlider } from '../components/FontSizeSlider';
import { NavHeaderBar } from '../components/NavHeaderBar';
import { CommonConstants } from '../constants/CommonConstants';
import { SettingFontViewModel } from '../viewmodels/SettingFontVM';

@Builder
export function SettingFontBuilder() {
  SettingFont()
}

@ComponentV2
struct SettingFont {
  @Local vm: SettingFontViewModel = new SettingFontViewModel();

  aboutToAppear(): void {
    this.vm.setUIContext(this.getUIContext());
  }

  build() {
    NavDestination() {
      NavHeaderBar({ title: '字体大小' })

      if (this.vm.configInfo.isSheet) {
        this.coreView()
      } else {
        GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
          GridCol({
            span: GridRowColSetting.DEFAULT_CENTER_COL_SPAN,
            offset: GridRowColSetting.DEFAULT_CENTER_COL_OFFSET,
          }) {
            this.coreView()
          }
        }
      }
    }
    .attributeModifier(this.vm.pageModifier)
    .backgroundColor(this.vm.configInfo.isSheet ? $r('app.color.page_bg') : $r('sys.color.background_secondary'))
  }

  @Builder
  coreView() {
    Column({ space: CommonConstants.PADDING_L }) {
      this.previewInfo()
      this.followSwitch()
      this.adjustBuilder()
    }
    .padding({
      top: CommonConstants.PADDING_M,
    })
  }

  @Builder
  previewInfo() {
    Column({ space: CommonConstants.PADDING_M }) {
      Text('Hello World')
        .fontSize(this.vm.fontModel.getFg(16))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
      Text('预览字体效果')
        .fontSize(this.vm.fontModel.getFg(14))
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Regular)
    }
    .width(CommonConstants.FULL_PERCENT)
    .borderRadius($r('app.float.xl_radius'))
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .justifyContent(FlexAlign.Center)
    .padding(CommonConstants.PADDING_M)
    .constraintSize({
      minHeight: 156,
    })
  }

  @Builder
  followSwitch() {
    Row() {
      Text('跟随系统')
        .fontSize(this.vm.getDescFg(14))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
      Toggle({ type: ToggleType.Switch, isOn: this.vm.fontModel.followSystem })
        .selectedColor(this.vm.configInfo.themeColor)
        .onChange((isOn: boolean) => {
          this.vm.fontModel.followSystem = isOn;
        })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(48)
    .justifyContent(FlexAlign.SpaceBetween)
    .borderRadius($r('app.float.xl_radius'))
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .margin({
      top: CommonConstants.PADDING_S,
    })
    .padding({
      left: CommonConstants.PADDING_M,
      right: CommonConstants.PADDING_M,
    })
  }

  @Builder
  adjustBuilder() {
    FontSizeSlider({
      currentRatio: this.vm.currentRatio,
      disabled: this.vm.fontModel.followSystem,
      themeColor: this.vm.configInfo.themeColor,
      onRatioChange: (ratio: number) => {
        this.vm.currentRatio = ratio;
        this.vm.fontModel.fontSizeRatio = ratio;
      },
    })
  }
}