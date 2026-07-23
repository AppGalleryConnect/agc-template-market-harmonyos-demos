import { GridRowColSetting } from 'lib_common';
import { NavHeaderBar } from 'lib_widget'
import { SettingFontCore } from 'module_setfontsize';
import { SettingFontViewModel } from '../viewmodels/SettingFontVM';

@Builder
export function SettingFontBuilder() {
  SettingFont()
}

@ComponentV2
struct SettingFont {
  @Local vm: SettingFontViewModel = new SettingFontViewModel();

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '字体大小',
      })

      GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
        GridCol({
          span: GridRowColSetting.DEFAULT_CENTER_COL_SPAN,
          offset: GridRowColSetting.DEFAULT_CENTER_COL_OFFSET,
        }) {
          SettingFontCore({
            currentRatio: this.vm.currentRatio,
            breakpoint: this.vm.breakPointModel.currentBreakpoint,
            confirm: (ratio: number) => {
              this.vm.confirm(ratio);
            },
          })
            .layoutWeight(1)
        }
      }
      .layoutWeight(1)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({
      bottom: this.vm.windowModel.windowBottomPadding,
    })
  }
}