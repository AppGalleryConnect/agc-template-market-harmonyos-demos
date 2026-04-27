import { AtomicServiceWeb } from '@kit.ArkUI';
import { GridRowColSetting } from '../common/GridRowColSetting';
import { NavHeaderBar } from '../components/NavHeaderBar';
import { SettingH5VM } from '../viewmodels/SettingH5VM';

@Builder
export function SettingH5Builder() {
  SettingH5()
}

@ComponentV2
struct SettingH5 {
  @Local vm: SettingH5VM = new SettingH5VM();

  aboutToAppear(): void {
    this.vm.getParams();
  }

  build() {
    NavDestination() {
      NavHeaderBar()
      if (this.vm.configInfo.isSheet) {
        this.webBuilder()
      } else {
        GridRow(GridRowColSetting.DEFAULT_GRID_ROW_OPTIONS) {
          GridCol({
            span: GridRowColSetting.DEFAULT_CENTER_COL_SPAN,
            offset: GridRowColSetting.DEFAULT_CENTER_COL_OFFSET,
          }) {
            this.webBuilder()
          }
        }
        .layoutWeight(1)
      }
    }
    .attributeModifier(this.vm.pageModifier)
    .backgroundColor(this.pageBg)
  }

  @Builder
  webBuilder() {
    AtomicServiceWeb({
      src: '',
      controller: this.vm.webViewController,
      nestedScroll: {
        scrollForward: NestedScrollMode.SELF_ONLY,
        scrollBackward: NestedScrollMode.SELF_ONLY,
      },
      onControllerAttached: () => {
        this.vm.onControllerAttached();
      },
    })
      .backgroundColor(this.pageBg)
      .layoutWeight(1)
  }

  @Computed
  get pageBg() {
    return this.vm.configInfo.isSheet ? $r('app.color.page_bg') : $r('sys.color.background_secondary')
  }
}
