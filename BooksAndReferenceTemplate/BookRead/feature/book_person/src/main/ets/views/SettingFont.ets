import { FontSizeSlider } from '../comp/FontSizeSlider';
import { SettingFontViewModel } from '../comp/SettingFontVM';
import { NavHeaderBar } from 'common';

@ComponentV2
export struct SettingFont {
  @Local vm: SettingFontViewModel = new SettingFontViewModel();

  aboutToAppear(): void {
    this.vm.setUIContext(this.getUIContext());
  }

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '字体大小',
        hasBackButton: true,
        hasBgColor: true,
        isMainPage: false,
      })
      GridRow({
        columns: {
          sm: 4,
          md: 8,
          lg: 12,
          xl: 12,
        },
        breakpoints: {
          value: ['600vp', '840vp', '1440vp'],
          reference: BreakpointsReference.WindowSize,
        },
        direction: GridRowDirection.Row,
      }) {
        GridCol({
          span: {
            sm: 4,
            md: 8,
            lg: 8,
            xl: 8,
          },
          offset: {
            sm: 0,
            md: 0,
            lg: 2,
            xl: 2,
          },
        }) {
          this.coreView()
        }
      }
      .padding({left: 16, right: 16})
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  coreView() {
    Column({ space: 16 }) {
      this.previewInfo()
      this.followSwitch()
      this.adjustBuilder()
    }
    .padding({
      top: 12,
    })
  }

  @Builder
  previewInfo() {
    Column({ space: 12 }) {
      Text('Hello World')
        .fontSize(this.vm.fontModel.getFg(16))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
      Text('预览字体效果')
        .fontSize(this.vm.fontModel.getFg(14))
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Regular)
    }
    .width('100%')
    .borderRadius(20)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .justifyContent(FlexAlign.Center)
    .padding(12)
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
        .onChange((isOn: boolean) => {
          this.vm.fontModel.followSystem = isOn;
        })
    }
    .width('100%')
    .height(48)
    .justifyContent(FlexAlign.SpaceBetween)
    .borderRadius(20)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .margin({
      top: 8,
    })
    .padding({
      left: 12,
      right: 12,
    })
  }

  @Builder
  adjustBuilder() {
    FontSizeSlider({
      currentRatio: this.vm.currentRatio,
      disabled: this.vm.fontModel.followSystem,
      themeColor: '#EC6E45',
      onRatioChange: (ratio: number) => {
        this.vm.currentRatio = ratio;
        this.vm.fontModel.fontSizeRatio = ratio;
      },
    })
  }
}