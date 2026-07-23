import { FontUtil, WindowUtil } from 'lib_foundation';
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
    this.vm.fontModel.previewRatio = this.vm.currentRatio;
  }

  build() {
    NavDestination() {
      NavHeaderBar({ title: '字号设置' })

      Scroll() {
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
      .layoutWeight(1)
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
    }
    .attributeModifier(this.vm.pageModifier)
    .backgroundColor(this.vm.configInfo.isSheet ? $r('app.color.page_bg') : $r('sys.color.background_secondary'))
    .padding({
      left: 16,
      right: 16,
      top: WindowUtil.getAvoidArea().top,
      bottom: 24,
    })
  }

  @Builder
  coreView() {
    Column({ space: CommonConstants.PADDING_L }) {
      this.previewInfo()
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
        .fontSize(this.vm.fontModel.getPreviewFg(16))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
      Text('预览字体效果')
        .fontSize(this.vm.fontModel.getPreviewFg(14))
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
  adjustBuilder() {
    FontSizeSlider({
      currentRatio: this.vm.currentRatio,
      disabled: this.vm.fontModel.followSystem,
      themeColor: this.vm.configInfo.themeColor,
      onRatioChange: (ratio: number) => {
        this.vm.currentRatio = ratio;
        this.vm.fontModel.previewRatio = ratio;
        FontUtil.setRate(ratio === 1 ? 0 : 1);
      },
    })
  }
}